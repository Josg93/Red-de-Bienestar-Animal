#ifndef MAPMANAGER_H
#define MAPMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QGeoCoordinate>
#include <QVariant>
#include <QList>

#include <QCoreApplication>
#include <QDebug>
#include <QByteArray>
#include <QString>


#include <queue>
#include "rescuereport.h"

struct ReportComparator {
    bool operator()(const RescueReport& a, const RescueReport& b) const {
        return a.priority() > b.priority();
    }
};

struct DistanceComparator {
    bool operator()(const std::pair<double, RescueReport>& a, const std::pair<double, RescueReport>& b) const {
        // 'true' significa que 'a' tiene menor prioridad (va abajo). Max-Heap: Ordena por el MAYOR
        return a.first < b.first;
    }
};

class MapManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList sortedReports READ sortedReports NOTIFY reportsChanged)
public:
    explicit MapManager(QObject *parent = nullptr);

    Q_INVOKABLE void getRoute(double startLat, double startLon, double endLat, double endLon);

    Q_INVOKABLE void addReport(int id, double lat, double lon, int priority);

    Q_INVOKABLE void calculateRouteToReport(double rescuerLat, double rescuerLon, int reportId);

    //Q_INVOKABLE void updateNearestReports(double rescuerLat, double rescuerLon, int k = 5);

    QVariantList sortedReports() const;
signals:
    // This signal will send the list of points to QML
    void routeReady(QVariantList path);
    void reportsChanged();

private:
    QNetworkAccessManager *m_networkManager;

    QByteArray apiKeyBytes =qgetenv("GOOGLE_MAPS_API_KEY");
    const QString m_apiKey = QString(apiKeyBytes); // API key
    // Helper function to decode Google's weird string
    QList<QGeoCoordinate> decodePolyline(const QString &encodedString);

    //cola de prioridad para los reportes lista auxiliar: Necesaria para exponer a QML (no se puede iterar sobre std::priority_queue)
    std::priority_queue<RescueReport, std::vector<RescueReport>, ReportComparator> m_priorityQueue;
    QList<RescueReport> m_sortedReports;
    void updateSortedList();
};

#endif // MAPMANAGER_H


