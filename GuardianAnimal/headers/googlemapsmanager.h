#ifndef GOOGLEMAPSMANAGER_H
#define GOOGLEMAPSMANAGER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QGeoCoordinate>

class GoogleMapsManager : public QObject
{
    Q_OBJECT
public:
    explicit GoogleMapsManager(QObject *parent = nullptr);

    void getCoordinates(const QString& address);
    void getRoute(const QGeoCoordinate& start, const QGeoCoordinate& end);

signals:
    void coordinatesFound(QGeoCoordinate coord);
    void routeFound(QVariantList path, QString distance, QString duration);
    void errorOccurred(QString message);

private slots:
    void onGeocodeReply(QNetworkReply* reply);
    void onRouteReply(QNetworkReply* reply);

private:
    QNetworkAccessManager m_networkManager;
    const QString API_KEY = "API_KEY";


    QList<QGeoCoordinate> decodePolyline(const QString &encodedString);
};

#endif // GOOGLEMAPSMANAGER_H

