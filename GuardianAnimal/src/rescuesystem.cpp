#include "rescuesystem.h"
#include <QDebug>

RescueSystem::RescueSystem() {

    loadFromDisk();
}

void RescueSystem::addAnimal(const AnimalRecord& record)
{
    qDebug() << "[RescueSystem] Adding animal:" << record.id;
    m_database.insert(record.id, record);

    JobTicket ticket;
    ticket.animalId = record.id;
    ticket.location = record.location;
    ticket.timestamp = record.timestamp.toMSecsSinceEpoch();

    if (record.severity == "HIGH") ticket.severity = 100;
    else if (record.severity == "MEDIUM") ticket.severity = 50;
    else ticket.severity = 10;

    if (record.status == "emergency" || record.status == "lost") {
        m_priorityQueue.insert(ticket);
    }

    m_spatialIndex.insert(ticket);
    qDebug() << "  Added to database and spatial structures";

    saveToDisk();
}

void RescueSystem::updateAnimal(const AnimalRecord& record)
{
    qDebug() << "[RescueSystem] Updating animal:" << record.id;

    if (!m_database.contains(record.id)) {
        qDebug() << "  ERROR: Animal not in database!";
        return;
    }

    m_database.insert(record.id, record);

    saveToDisk();
}

AnimalRecord RescueSystem::getAnimal(const QString& id) const
{
    return m_database.value(id);
}

QList<AnimalRecord> RescueSystem::getEmergencyList(int limit)
{
    QList<AnimalRecord> result;
    std::vector<JobTicket> sorted = m_priorityQueue.getSortedList();

    QSet<QString> seenIds;
    int count = 0;

    for (const JobTicket& ticket : sorted) {
        if (count >= limit) break;

        if (seenIds.contains(ticket.animalId)) continue;
        seenIds.insert(ticket.animalId);

        if (m_database.contains(ticket.animalId)) {
            AnimalRecord r = m_database.value(ticket.animalId);
            if (r.status != "resolved" && r.status != "adopted") {
                result.append(r);
                count++;
            }
        }
    }
    return result;
}

QList<AnimalRecord> RescueSystem::getNearestNeighbors(const QGeoCoordinate& center, int k)
{
    QList<AnimalRecord> result;
    std::vector<QString> ids = m_spatialIndex.findNearest(center, k * 3);

    QSet<QString> seenIds;

    for (const QString& id : ids) {
        if (result.count() >= k) break;

        if (seenIds.contains(id)) continue;
        seenIds.insert(id);

        if (m_database.contains(id)) {
            AnimalRecord r = m_database.value(id);
            if (r.status != "resolved" && r.status != "adopted") {
                result.append(r);
            }
        }
    }
    return result;
}

QList<AnimalRecord> RescueSystem::getAnimalsInRadius(const QGeoCoordinate& center, double radiusKm)
{
    QList<AnimalRecord> result;
    std::vector<QString> ids = m_spatialIndex.rangeSearch(center, radiusKm);

    QSet<QString> seenIds;

    for (const QString& id : ids) {
        if (seenIds.contains(id)) continue;
        seenIds.insert(id);

        if (m_database.contains(id)) {
            AnimalRecord r = m_database.value(id);
            if (r.status != "resolved" && r.status != "adopted") {
                result.append(r);
            }
        }
    }
    return result;
}

QList<AnimalRecord> RescueSystem::getByStatus(const QString& status)
{
    QList<AnimalRecord> result;
    for (const AnimalRecord& record : m_database) {
        if (record.status == status) {
            result.append(record);
        }
    }
    return result;
}

bool RescueSystem::removeAnimal(const QString& id)
{
    return m_database.remove(id) > 0;
}

void RescueSystem::resolveCase(const QString& id, const QString& outcome)
{
    if (m_database.contains(id)) {

        if (outcome.contains("Adoptado", Qt::CaseInsensitive) ||
            outcome.contains("Adoption", Qt::CaseInsensitive)) {
            m_database[id].status = "adopted";
        }
        else if (outcome.contains("Reunido", Qt::CaseInsensitive) ||
                 outcome.contains("Casa", Qt::CaseInsensitive)) { // "Ya en casa"
            m_database[id].status = "reunited";
        }
        else {
            m_database[id].status = "resolved";
        }

        saveToDisk();
        m_database[id].description += " [Final: " + outcome + "]";

    }
}

QList<AnimalRecord> RescueSystem::getHistory()
{
    QList<AnimalRecord> history;
    for (const AnimalRecord& r : m_database) {
        if (r.status == "resolved" || r.status == "adopted") {
            history.append(r);
        }
    }

    std::sort(history.begin(), history.end(), [](const AnimalRecord& a, const AnimalRecord& b){
        return a.timestamp > b.timestamp;
    });

    return history;
}

    void RescueSystem::saveToDisk()
{
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(path);
    if (!dir.exists()) dir.mkpath("."); // Create folder if missing

    QString filePath = path + "/guardian_data.json";
    QFile file(filePath);

    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "Could not open file for saving:" << filePath;
        return;
    }

    QJsonArray mainArray;
    for (auto it = m_database.begin(); it != m_database.end(); ++it) {
        QJsonObject obj;
        it.value().write(obj); // Use the helper we wrote
        mainArray.append(obj);
    }

    QJsonDocument doc(mainArray);
    file.write(doc.toJson());
    file.close();
    qDebug() << "Saved" << mainArray.size() << "records to" << filePath;
}

void RescueSystem::loadFromDisk()
{
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QString filePath = path + "/guardian_data.json";
    QFile file(filePath);

    if (!file.exists()) {
        qDebug() << "No save file found. Starting fresh.";
        return;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Could not open file for reading:" << filePath;
        return;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonDocument doc(QJsonDocument::fromJson(data));
    QJsonArray mainArray = doc.array();

    qDebug() << "Loading" << mainArray.size() << "records from disk...";

    // 4. REHYDRATION LOOP
    for (const auto &val : mainArray) {
        AnimalRecord r;
        r.read(val.toObject());

        addAnimal(r);
    }
    qDebug() << "Rehydration complete.";
}

