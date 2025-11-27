#include "googlemapsmanager.h"
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

GoogleMapsManager::GoogleMapsManager(QObject *parent) : QObject(parent) {}

void GoogleMapsManager::getCoordinates(const QString& address)
{
    QUrl url("https://maps.googleapis.com/maps/api/geocode/json");
    QUrlQuery query;
    query.addQueryItem("address", address);
    query.addQueryItem("key", API_KEY);
    url.setQuery(query);

    QNetworkRequest request(url);
    QNetworkReply* reply = m_networkManager.get(request);
    connect(reply, &QNetworkReply::finished, [this, reply](){ onGeocodeReply(reply); });
}

void GoogleMapsManager::onGeocodeReply(QNetworkReply* reply)
{
    reply->deleteLater();
    if (reply->error()) {
        emit errorOccurred("Network Error");
        return;
    }

    auto json = QJsonDocument::fromJson(reply->readAll()).object();
    auto results = json["results"].toArray();

    if (!results.isEmpty()) {
        auto location = results[0].toObject()["geometry"].toObject()["location"].toObject();
        double lat = location["lat"].toDouble();
        double lng = location["lng"].toDouble();
        emit coordinatesFound(QGeoCoordinate(lat, lng));
    } else {
        emit errorOccurred("Address not found");
    }
}

void GoogleMapsManager::getRoute(const QGeoCoordinate& start, const QGeoCoordinate& end)
{

    if (start.distanceTo(end) < 20.0) {
        qDebug() << "Start and End are the same. Skipping API request.";

        // Create a dummy path with just the end point
        QVariantList path;
        path.append(QVariant::fromValue(end));

        // Emit "0 distance" immediately
        emit routeFound(path, "0 m", "0 min");
        return;
    }

    QString urlString = QString("https://maps.googleapis.com/maps/api/directions/json?origin=%1,%2&destination=%3,%4&key=%5")
    .arg(start.latitude()).arg(start.longitude())
        .arg(end.latitude()).arg(end.longitude())
        .arg(API_KEY);

    qDebug() << "Requesting route from Google Maps:";
    qDebug() << "  From:" << start.latitude() << start.longitude();
    qDebug() << "  To:" << end.latitude() << end.longitude();

    QUrl url(urlString);
    QNetworkRequest request(url);
    QNetworkReply* reply = m_networkManager.get(request);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        onRouteReply(reply);
    });
}



void GoogleMapsManager::onRouteReply(QNetworkReply* reply)
{
    reply->deleteLater();

    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << "Network error:" << reply->errorString();
        emit errorOccurred(reply->errorString());
        return;
    }

    QByteArray responseData = reply->readAll();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(responseData);
    QJsonObject jsonObj = jsonDoc.object();

    qDebug() << "=== Google Directions API Response ===";
    qDebug() << "Status:" << jsonObj["status"].toString();

    if (jsonObj["status"].toString() == "OK") {
        QJsonArray routes = jsonObj["routes"].toArray();
        if (routes.isEmpty()) {
            qDebug() << "No routes found";
            emit errorOccurred("No routes found");
            return;
        }

        QJsonObject route = routes[0].toObject();
        QJsonArray legs = route["legs"].toArray();

        if (legs.isEmpty()) {
            qDebug() << "No legs in route";
            emit errorOccurred("Invalid route data");
            return;
        }

        QJsonObject leg = legs[0].toObject();
        QString dist = leg["distance"].toObject()["text"].toString();
        QString time = leg["duration"].toObject()["text"].toString();

        // Get the encoded polyline
        QJsonObject polylineObj = route["overview_polyline"].toObject();
        QString encodedPoints = polylineObj["points"].toString();

        qDebug() << "Encoded polyline length:" << encodedPoints.length();

        // Decode polyline into coordinates
        QList<QGeoCoordinate> pathCoords = decodePolyline(encodedPoints);

        qDebug() << "Decoded" << pathCoords.size() << "points";
        qDebug() << "Distance:" << dist << "Duration:" << time;

        // Convert to QVariantList for QML
        QVariantList path;
        for (const QGeoCoordinate &coord : pathCoords) {
            path.append(QVariant::fromValue(coord));
        }

        emit routeFound(path, dist, time);
    } else {
        QString error = jsonObj["status"].toString();
        qDebug() << "Google API Error:" << error;
        emit errorOccurred("Route error: " + error);
    }
}

// Decode Google's Polyline format
QList<QGeoCoordinate> GoogleMapsManager::decodePolyline(const QString &encoded)
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
