#include <QDebug>
#include <QUrl>
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include "mapmanager.h"
#include "rescuereport.h"
#include <QVariant>


MapManager::MapManager(QObject *parent) : QObject(parent)
{
    m_networkManager = new QNetworkAccessManager(this);
}

void MapManager::updateSortedList()
{
    // ... (la lógica es correcta. Ahora funciona porque RescueReport es copiable)
    m_sortedReports.clear();

    std::priority_queue<RescueReport, std::vector<RescueReport>, ReportComparator> tempQueue = m_priorityQueue;

    while (!tempQueue.empty()) {
        m_sortedReports.append(tempQueue.top());
        tempQueue.pop();
    }
}

// Getter para QML
QVariantList MapManager::sortedReports() const
{
    QVariantList list;
    // Esto funciona SOLO si RescueReport NO hereda de QObject y tiene Q_DECLARE_METATYPE
    for (const RescueReport& report : m_sortedReports) {
        list.append(QVariant::fromValue(report));
    }
    return list;
}
void MapManager::addReport(int id, double lat, double lon, int priority)
{
    RescueReport newReport(id, QGeoCoordinate(lat,lon), priority);
    m_priorityQueue.push(newReport);

    updateSortedList(); // Actualiza la QList para QML
    emit reportsChanged();
    qDebug() << "Report added. Priority:" << priority;
}

void MapManager::calculateRouteToReport(double rescuerLat, double rescuerLon, int reportId)
{
    QGeoCoordinate targetCoord;
    bool found = false;

    for(const RescueReport& report : m_sortedReports)
    {
        if(report.id() == reportId)
        {
            targetCoord = report.coordinate();
            found = true;
            break;
        }
    }

    if(found)
    {
        getRoute(rescuerLat, rescuerLon, targetCoord.latitude(), targetCoord.longitude());
    }
    else
    {
        qDebug() << "Error: Reporte con ID" << reportId << "no encontrado";
    }
}

void MapManager::getRoute(double startLat, double startLon, double endLat, double endLon)
{
    QString urlString = QString("https://maps.googleapis.com/maps/api/directions/json?origin=%1,%2&destination=%3,%4&key=%5")
    .arg(startLat).arg(startLon).arg(endLat).arg(endLon).arg(m_apiKey);

    QNetworkRequest request((QUrl(urlString)));
    QNetworkReply *reply = m_networkManager->get(request);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            // 1. Parse the JSON
            QByteArray responseData = reply->readAll();
            QJsonDocument jsonDoc = QJsonDocument::fromJson(responseData);
            QJsonObject jsonObj = jsonDoc.object();

            // 2. Check status
            if (jsonObj["status"].toString() == "OK") {
                // 3. Extract the "overview_polyline" string
                QJsonArray routes = jsonObj["routes"].toArray();
                QJsonObject route = routes[0].toObject();
                QJsonObject polylineObj = route["overview_polyline"].toObject();
                QString encodedPoints = polylineObj["points"].toString();

                // 4. Decode it into real coordinates
                QList<QGeoCoordinate> path = decodePolyline(encodedPoints);

                // 5. Convert to QVariantList for QML
                QVariantList qmlPath;
                for (const QGeoCoordinate &coord : path) {
                    qmlPath.append(QVariant::fromValue(coord));
                }

                // 6. Send to QML!
                emit routeReady(qmlPath);
                qDebug() << "Route found with" << path.size() << "points. Sent to QML.";

            } else {
                qDebug() << "Google Error:" << jsonObj["status"].toString();
            }
        } else {
            qDebug() << "Network Error:" << reply->errorString();
        }
        reply->deleteLater();
    });
}



// This is the standard algorithm to decode Google's Polyline format
QList<QGeoCoordinate> MapManager::decodePolyline(const QString &encoded)
{
    QList<QGeoCoordinate> points;
    int index = 0, len = encoded.length();
    int lat = 0, lng = 0;

    while (index < len) {
        int b, shift = 0, result = 0;
        do {
            b = encoded[index++].toLatin1() - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        int dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        shift = 0;
        result = 0;
        do {
            b = encoded[index++].toLatin1() - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        int dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        points.append(QGeoCoordinate(lat * 1e-5, lng * 1e-5));
    }
    return points;
}
