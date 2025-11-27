 #include "rescuemodel.h"
#include <QDebug>
#include <QUuid>
#include <QUrl>
#include <QRegularExpression>
#include <QJSValue>

RescueModel::RescueModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_mapsManager = new GoogleMapsManager(this);
    connect(m_mapsManager, &GoogleMapsManager::routeFound,
            this, &RescueModel::routeReady);

    m_userLocation = QGeoCoordinate(8.605, -71.150);

    refresh();
}

int RescueModel::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent);
    qDebug() << "[rowCount called] Returning:" << m_displayList.count();
    return m_displayList.count();
}

QVariant RescueModel::data(const QModelIndex &index, int role) const {

    if (!index.isValid() || index.row() >= m_displayList.count()) return QVariant();
    const AnimalRecord &record = m_displayList.at(index.row());

    switch (role){

    case AnimalRoles::IdRole: return record.id;
    case AnimalRoles::NameRole: return record.name;
    case AnimalRoles::TypeRole: return record.type;
    case AnimalRoles::AgeRole: return record.age;
    case AnimalRoles::SeverityRole: return record.severity;
    case AnimalRoles::StatusRole: return record.status;
    case AnimalRoles::LocationRole: return record.locationText.isEmpty() ? "Coordenadas GPS" : record.locationText;
    case AnimalRoles::DescriptionRole: return record.description;
    case AnimalRoles::ImageSourceRole: return record.images.isEmpty() ? "" : record.images.first();
    case AnimalRoles::ImagesRole: return record.images;
    case AnimalRoles::OwnerIdRole: return record.ownerId;
    case AnimalRoles::CoordinatesRole: return QVariant::fromValue(record.location);
    case AnimalRoles::ContactPhoneRole: return record.contactPhone;
    case AnimalRoles::ContactEmailRole: return record.contactEmail;
    case AnimalRoles::DistanceRole:

        if (m_userLocation.isValid() && record.isValid()) {
            double dist = m_userLocation.distanceTo(record.location) / 1000.0;
            return QString::number(dist, 'f', 1) + " km";
        }
        return "? km";
    }
    return QVariant();
}

QHash<int, QByteArray> RescueModel::roleNames() const {

    return {
        {   AnimalRoles::IdRole, "id"},
            {AnimalRoles::NameRole, "name"},
            {AnimalRoles::TypeRole, "type"},
            {AnimalRoles::AgeRole, "age"},
            {AnimalRoles::SeverityRole, "severity"},
            {AnimalRoles::StatusRole, "status"},
            {AnimalRoles::LocationRole, "location"},
            {AnimalRoles::DescriptionRole, "description"},
            {AnimalRoles::ImageSourceRole, "imageSource"},
            {AnimalRoles::ImagesRole, "images"},
            {AnimalRoles::OwnerIdRole, "ownerId"},
            {AnimalRoles::DistanceRole, "distance"},
            {AnimalRoles::CoordinatesRole, "coordinate"},
            {AnimalRoles::ContactPhoneRole, "contactPhone"},
            {AnimalRoles::ContactEmailRole, "contactEmail"}
    };
}

// Add this new method
void RescueModel::addAdoption(const QString& name,
                              const QString& type,
                              const QString& age,
                              const QString& sex,
                              bool isSpayed,
                              const QString& description,
                              const QString& contactPhone,
                              const QString& contactEmail,
                              const QVariantList& imageList,
                              const QString& shelterName)
{
    qDebug() << "=== ADD ADOPTION ===";

    AnimalRecord r;
    r.id = QUuid::createUuid().toString();
    r.ownerId = m_currentUserId;
    r.name = name;
    r.type = type;
    r.age = age;
    r.sex = sex;
    r.isSpayed = isSpayed;
    r.description = description;
    r.locationText = shelterName;
    r.status = "adoption";
    r.severity = "LOW";
    r.timestamp = QDateTime::currentDateTime();
    r.location = m_userLocation;

    r.contactPhone = contactPhone;
    r.contactEmail = contactEmail;
;
    for (const QVariant &img : imageList) {
        QString path;
        if (img.canConvert<QUrl>()) {
            path = img.toUrl().toString();
        } else {
            path = img.toString();
        }
        if (!path.isEmpty()
            && !path.startsWith("file:")
            && !path.startsWith("qrc:")
            && !path.startsWith("http")) {
            path = QUrl::fromLocalFile(path).toString();
        }
        if (!path.isEmpty())
            r.images.append(path);
    }

    qDebug() << "Final record - Description:" << r.description;
    qDebug() << "Final record - Images:" << r.images.count();
    qDebug() << "ADD ADOPTION sex=" << sex << "isSpayed=" << isSpayed;


    m_system.addAnimal(r);
    refresh();
}

void RescueModel::updateAdoption(const QString& id,
                                 const QString& name,
                                 const QString& type,
                                 const QString& age,
                                 const QString& sex,
                                 bool isSpayed,
                                 const QString& description,
                                 const QString& contactPhone,
                                 const QString& contactEmail,
                                 const QVariantList& imageList,
                                 const QString& shelterName)
{
   // qDebug() << "=== UPDATE ADOPTION (DEBUG MODE) ===";

    AnimalRecord r = m_system.getAnimal(id);
    if (r.id.isEmpty()) {
        //qDebug() << "ERROR: Animal not found!";
        return;
    }

    r.name = name;
    r.type = type;
    r.age = age;
    r.sex = sex;
    r.isSpayed = isSpayed;
    r.description = description;
    r.locationText = shelterName;
    r.contactPhone = contactPhone;
    r.contactEmail = contactEmail;

    -
    QStringList newImages;

    for (const QVariant &img : imageList) {
        QString path;

        if (img.canConvert<QUrl>()) {
            QUrl url = img.toUrl();
            path = url.toString();
            qDebug() << "Processing QUrl image path:" << path;
        }

        else if (img.metaType().id() == qMetaTypeId<QJSValue>()) {
            QJSValue js = img.value<QJSValue>();
            path = js.toString();
            qDebug() << "Processing QJSValue image path:" << path;
        }

        else {
            path = img.toString();
            qDebug() << "Processing string image path:" << path;
        }

        if (!path.isEmpty()
            && !path.startsWith("file:")
            && !path.startsWith("qrc:")
            && !path.startsWith("http")) {
            path = QUrl::fromLocalFile(path).toString();
            qDebug() << "  -> Normalized local file path to URL:" << path;
        }

        if (!path.isEmpty()) {
            newImages.append(path);
        } else {
            qDebug() << "  -> SKIPPED (Empty after processing)";
        }
    }

    if (!newImages.isEmpty()) {
        qDebug() << "Total images actually added:" << newImages.size();
        r.images = newImages;
    } else {
        qDebug() << "No valid new images decoded – keeping existing images.";
    }


    m_system.updateAnimal(r);
    refresh();
}



void RescueModel::addLostFound(const QString &status,
                               const QString &name,
                               const QString &type,
                               const QString &breed,
                               const QString &dateText,
                               const QString &locationText,
                               const QString &contactPhone,
                               const QVariantList &imageList)
{
    qDebug() << "=== ADD LOST/FOUND ===";
    qDebug() << "Status:" << status << "Name:" << name;

    AnimalRecord r;
    r.id = QUuid::createUuid().toString();
    r.ownerId = m_currentUserId;
    r.name = name;
    r.type = type;
    r.breed = breed;
    r.status = status;
    r.severity = "MEDIUM";
    r.timestamp = QDateTime::currentDateTime();
    r.locationText = locationText;
    r.description = "Fecha/hora: " + dateText;
    r.contactPhone = contactPhone;
    r.location = m_userLocation;

    for (const QVariant &img : imageList) {
        QString path;
        if (img.canConvert<QUrl>()) {
            path = img.toUrl().toString();
        } else {
            path = img.toString();
        }
        if (!path.isEmpty()
            && !path.startsWith("file:")
            && !path.startsWith("qrc:")
            && !path.startsWith("http")) {
            path = QUrl::fromLocalFile(path).toString();
        }
        if (!path.isEmpty())
            r.images.append(path);
    }

    m_system.addAnimal(r);
    refresh();
}



void RescueModel::setCurrentUserId(const QString& userId)
{
    m_currentUserId = userId;
    qDebug() << "Backend: User logged in as" << userId;
}

QVariantMap RescueModel::getAnimalDetails(const QString& animalId)
{
    QVariantMap result;
    AnimalRecord animal = m_system.getAnimal(animalId);

    if (!animal.id.isEmpty()) {
        result["id"] = animal.id;
        result["name"] = animal.name;
        result["type"] = animal.type;
        result["age"] = animal.age;
        result["location"] = animal.locationText;
        result["description"] = animal.description;
        result["severity"] = animal.severity;
        result["coordinate"] = QVariant::fromValue(animal.location);
        result["sex"] = animal.sex;
        result["isSpayed"] = animal.isSpayed;
        result["contactPhone"] = animal.contactPhone;
        result["contactEmail"] = animal.contactEmail;
        result["shelterName"] = animal.locationText;

        result["contactPhone"] = animal.contactPhone;
        result["contactEmail"] = animal.contactEmail;

        QStringList formattedImages;
        for (const QString& img : animal.images) {
            QString path = img;
            if (!path.startsWith("file://") && !path.startsWith("http")) {
                path = "file:///" + path;
            }
            formattedImages.append(path);
        }
        result["images"] = formattedImages;
    }
    return result;
}

void RescueModel::addReport(const QString& type, const QString& severity,
                            const QString& locationText, const QString& description,
                            const QString& imagePath, const QGeoCoordinate& gps)
{
    AnimalRecord r;
    r.id = QUuid::createUuid().toString();
    r.type = type;
    r.severity = severity;
    r.locationText = locationText;
    r.description = description;
    r.status = "emergency";
    r.timestamp = QDateTime::currentDateTime();
    r.ownerId = m_currentUserId;

    if (!imagePath.isEmpty()) r.images.append(imagePath);


    if (gps.isValid()) {
        r.location = gps;
        m_system.addAnimal(r);
        refresh();
        return;
    }


    QRegularExpression re("([-+]?\\d*\\.\\d+).*?([-+]?\\d*\\.\\d+)");
    QRegularExpressionMatch match = re.match(locationText);

    if (match.hasMatch()) {
        double lat = match.captured(1).toDouble();
        double lon = match.captured(2).toDouble();
        r.location = QGeoCoordinate(lat, lon);

        if (r.location.isValid()) {
            m_system.addAnimal(r);
            refresh();
            return;
        }
    }

    //qDebug() << "Geocoding address via Google: " << locationText;
    auto connection = std::make_shared<QMetaObject::Connection>();
    *connection = connect(m_mapsManager, &GoogleMapsManager::coordinatesFound,
                          [this, r, connection](QGeoCoordinate coord) mutable {
                              r.location = coord;
                              m_system.addAnimal(r);
                              refresh();
                              QObject::disconnect(*connection);
                          });

    m_mapsManager->getCoordinates(locationText);
}

void RescueModel::requestRouteToAnimal(const QString& animalId)
{

    qDebug() << "=== requestRouteToAnimal ===";
    qDebug() << "Animal ID:" << animalId;

    AnimalRecord animal = m_system.getAnimal(animalId);

    qDebug() << "Animal found:" << !animal.id.isEmpty();

    if (!animal.id.isEmpty()) {
        qDebug() << "Animal name:" << animal.name;
        qDebug() << "Animal location valid?" << animal.location.isValid();
        qDebug() << "Animal coords:" << animal.location.latitude() << animal.location.longitude();
    }

    qDebug() << "User location valid?" << m_userLocation.isValid();
    qDebug() << "User coords:" << m_userLocation.latitude() << m_userLocation.longitude();

    if (animal.isValid() && m_userLocation.isValid()) {
        qDebug() << "✅ Requesting route from Google Maps...";
        m_mapsManager->getRoute(m_userLocation, animal.location);
    }
    else {
        qDebug() << "❌ Cannot request route - invalid locations";
    }
}

void RescueModel::setViewMode(const QString& mode) {

    if (m_currentMode == mode) return;

    m_currentMode = mode;

    refresh();

}


void RescueModel::refresh()
{
    qDebug() << "\n========== REFRESH START ==========";
    qDebug() << "Mode:" << m_currentMode;

    beginResetModel();
    m_displayList.clear();


    if (m_currentMode == "emergency") {
        QList<AnimalRecord> candidates;

        // A. Spatial Filter (K-D Tree)
        if (m_filterByRadius) {
            // "Range Search": Strict radius (e.g., 5km)
            candidates = m_system.getAnimalsInRadius(m_userLocation, m_searchRadius);
        } else {
            // "KNN Search": Nearest 20 neighbors (ignores distance limit)
            candidates = m_system.getNearestNeighbors(m_userLocation, 50);
        }

        // B. Filter by Status "emergency"
        QList<AnimalRecord> emergencyCases;
        for (const AnimalRecord& record : candidates) {
            if (record.status == "emergency") {
                emergencyCases.append(record);
            }
        }

        // C. Composite Sort (Severity -> Distance -> Time)
        std::sort(emergencyCases.begin(), emergencyCases.end(),
                  [this](const AnimalRecord& a, const AnimalRecord& b){
                      // 1. Severity (High > Medium > Low)
                      int sevA = (a.severity == "HIGH") ? 100 : (a.severity == "MEDIUM" ? 50 : 10);
                      int sevB = (b.severity == "HIGH") ? 100 : (b.severity == "MEDIUM" ? 50 : 10);
                      if (sevA != sevB) return sevA > sevB;

                      // 2. Distance (Closer wins)
                      if (m_userLocation.isValid() && a.location.isValid() && b.location.isValid()) {
                          double distA = a.location.distanceTo(m_userLocation);
                          double distB = b.location.distanceTo(m_userLocation);

                          if (std::abs(distA - distB) > 100.0) return distA < distB;
                      }

                      // 3. Timestamp (Older/FIFO wins to prevent starvation)
                      return a.timestamp < b.timestamp;
                  });

        m_displayList = emergencyCases;
    }

    // --- 2. ADOPTION MODE (Active Adoptions) ---
    else if (m_currentMode == "adoption") {
        QList<AnimalRecord> candidates;

        if (m_filterByRadius) {
            candidates = m_system.getAnimalsInRadius(m_userLocation, m_searchRadius);
        } else {
            candidates = m_system.getNearestNeighbors(m_userLocation, 20);
        }

        QList<AnimalRecord> filtered;
        for (const AnimalRecord &r : candidates) {
            if (r.status != "adoption")
                continue;

            // 1) Name search
            if (!m_searchQuery.isEmpty()) {
                if (!r.name.contains(m_searchQuery, Qt::CaseInsensitive))
                    continue;
            }

            // 2) Species filter ("Todos" = no filter)
            if (!m_speciesFilter.isEmpty() && m_speciesFilter != "Todos") {
                if (!r.type.compare(m_speciesFilter, Qt::CaseInsensitive) == 0)
                    continue;
            }

            filtered.append(r);
        }

        m_displayList = filtered;
    }

    // --- 3. LOST MODE ---
    else if (m_currentMode == "lost") {
        QList<AnimalRecord> candidates;

        // Spatial pre-filter (same pattern as adoption/emergency)
        if (m_filterByRadius) {
            candidates = m_system.getAnimalsInRadius(m_userLocation, m_searchRadius);
        } else {
            candidates = m_system.getNearestNeighbors(m_userLocation, 50);
        }

        QList<AnimalRecord> filtered;
        for (const AnimalRecord &r : candidates) {
            if (r.status != "lost")
                continue;

            // Species filter ("Todos" = no filter)
            if (!m_speciesFilter.isEmpty() && m_speciesFilter != "Todos") {
                if (r.type.compare(m_speciesFilter, Qt::CaseInsensitive) != 0)
                    continue;
            }

            // Search across name / breed / location
            if (!m_searchQuery.isEmpty()) {
                QString haystack = r.name + " " + r.breed + " " + r.locationText;
                if (!haystack.contains(m_searchQuery, Qt::CaseInsensitive))
                    continue;
            }

            filtered.append(r);
        }

        std::sort(filtered.begin(), filtered.end(),
                  [](const AnimalRecord& a, const AnimalRecord& b){
                      return a.timestamp > b.timestamp;   // newest first
                  });

        m_displayList = filtered;
    }

    // --- 4. HISTORY MODE ---
    else if (m_currentMode == "history") {
        // Get full history from system
        QList<AnimalRecord> history = m_system.getHistory();

        // Filter: Only show "resolved" (Medical/Rescue cases), NOT adoptions
        for (const AnimalRecord& r : history) {
            if (r.status == "resolved") {
                m_displayList.append(r);
            }
        }

        // Sort by Newest Resolution
        std::sort(m_displayList.begin(), m_displayList.end(), [](const AnimalRecord& a, const AnimalRecord& b){
            return a.timestamp > b.timestamp;
        });
    }

    // --- 6. REUNITED MODE (Lost & Found Success Stories) ---
    else if (m_currentMode == "reunited") {
        // Get all records
        QList<AnimalRecord> all = m_system.getByStatus("reunited");

        // Sort by newest resolution first
        std::sort(all.begin(), all.end(), [](const AnimalRecord& a, const AnimalRecord& b){
            return a.timestamp > b.timestamp;
        });

        m_displayList = all;
    }

    // --- 5. HAPPY TAILS MODE (Adoptions Only) ---
    else if (m_currentMode == "happy_tails") {
        // Filter: Only show "adopted"
        m_displayList = m_system.getByStatus("adopted");

        // Sort by Newest Adoption
        std::sort(m_displayList.begin(), m_displayList.end(), [](const AnimalRecord& a, const AnimalRecord& b){
            return a.timestamp > b.timestamp;
        });
    }

    // --- 6. FOUND MODE ---
    else if (m_currentMode == "found") {
        QList<AnimalRecord> candidates;

        if (m_filterByRadius) {
            candidates = m_system.getAnimalsInRadius(m_userLocation, m_searchRadius);
        } else {
            candidates = m_system.getNearestNeighbors(m_userLocation, 50);
        }

        QList<AnimalRecord> filtered;
        for (const AnimalRecord &r : candidates) {
            if (r.status != "found")
                continue;

            if (!m_speciesFilter.isEmpty() && m_speciesFilter != "Todos") {
                if (r.type.compare(m_speciesFilter, Qt::CaseInsensitive) != 0)
                    continue;
            }

            if (!m_searchQuery.isEmpty()) {
                QString haystack = r.name + " " + r.breed + " " + r.locationText;
                if (!haystack.contains(m_searchQuery, Qt::CaseInsensitive))
                    continue;
            }

            filtered.append(r);
        }

        std::sort(filtered.begin(), filtered.end(),
                  [](const AnimalRecord& a, const AnimalRecord& b){
                      return a.timestamp > b.timestamp;
                  });

        m_displayList = filtered;
    }

    qDebug() << "→ FINAL displayList count:" << m_displayList.count();
    endResetModel();
    qDebug() << "========== REFRESH END ==========\n";
}


void RescueModel::setFilterByRadius(bool enable) { m_filterByRadius = enable; emit filterChanged(); refresh(); }

void RescueModel::setSearchRadius(double km) { m_searchRadius = km; emit filterChanged(); refresh(); }

void RescueModel::setUserLocation(const QGeoCoordinate& location) {

    m_userLocation = location;
    emit locationChanged();
    refresh();
}

void RescueModel::setSearchQuery(const QString &query)
{
    if (m_searchQuery == query)
        return;

    m_searchQuery = query;
    emit filterChanged();
    refresh();
}

void RescueModel::setSpeciesFilter(const QString &species)
{
    if (m_speciesFilter == species)
        return;
    m_speciesFilter = species;
    emit filterChanged();
    refresh();
}

void RescueModel::updateUserPosition(double lat, double lon) {

    setUserLocation(QGeoCoordinate(lat, lon));
}

QVariantList RescueModel::checkDuplicates(const QString& animalType,
                                          double lat, double lon,
                                          double radiusKm)
{

    QGeoCoordinate center(lat, lon);
    QVariantList results;

    if (!center.isValid()) {
        qDebug() << "Invalid coordinates for duplicate check";
        return results;
    }

    // Step 1: Get spatial candidates (K-D Tree)
    QList<AnimalRecord> nearby = m_system.getAnimalsInRadius(center, radiusKm);

    qDebug() << "=== Duplicate Check ===";
    qDebug() << "Searching for:" << animalType << "near" << lat << lon;
    qDebug() << "Found" << nearby.count() << "animals within" << radiusKm << "km";

    // Step 2: Semantic filtering
    QDateTime now = QDateTime::currentDateTime();

    for (const AnimalRecord& record : nearby) {

        // Skip if wrong animal type
        if (!record.type.contains(animalType, Qt::CaseInsensitive)) {
            continue;
        }

        qint64 hoursSince = record.timestamp.secsTo(now) / 3600;
        if (hoursSince > 24) {
            continue;
        }

        double distKm = center.distanceTo(record.location) / 1000.0;
        int score = 100;


        score -= static_cast<int>(distKm * 100);
        if (score < 0) score = 0;
        QVariantMap match;
        match["id"] = record.id;
        match["type"] = record.type;
        match["name"] = record.name;
        match["location"] = record.locationText;
        match["distance"] = QString::number(distKm, 'f', 2) + " km";
        match["severity"] = record.severity;
        match["timeAgo"] = QString::number(hoursSince) + "h ago";
        match["score"] = score;
        match["description"] = record.description;

        results.append(match);

        qDebug() << "  MATCH:" << record.type << record.name

                 << distKm << "km" << hoursSince << "h ago"

                 << "Score:" << score;
    }


    std::sort(results.begin(), results.end(),
              [](const QVariant& a, const QVariant& b) {
                  return a.toMap()["score"].toInt() > b.toMap()["score"].toInt();
              });
    return results;
}

void RescueModel::resolveCase(const QString& id, const QString& outcome)
{
    m_system.resolveCase(id, outcome);
    refresh();
}



/

