#include "animalrecord.h"
#include <QJsonObject>
#include <QJsonArray>

void AnimalRecord::read(const QJsonObject &json)
{
    id = json["id"].toString();
    ownerId = json["ownerId"].toString();
    name = json["name"].toString();
    type = json["type"].toString();
    breed = json["breed"].toString();
    age = json["age"].toString();
    sex = json["sex"].toString();
    isSpayed = json["isSpayed"].toBool();

    status = json["status"].toString();
    severity = json["severity"].toString();


    if (json.contains("timestamp")) {
        timestamp = QDateTime::fromString(json["timestamp"].toString(), Qt::ISODate);
    } else {
        timestamp = QDateTime::currentDateTime();
    }

    requests = json["requests"].toInt();
    locationText = json["locationText"].toString();
    contactPhone = json["contactPhone"].toString();
    contactEmail = json["contactEmail"].toString();
    description = json["description"].toString();


    if (json.contains("location")) {
        QJsonObject locObj = json["location"].toObject();
        location.setLatitude(locObj["lat"].toDouble());
        location.setLongitude(locObj["lon"].toDouble());
    }


    images.clear();
    if (json.contains("images")) {
        QJsonArray imgArray = json["images"].toArray();
        for (const auto &val : imgArray) {
            images.append(val.toString());
        }
    }
}

void AnimalRecord::write(QJsonObject &json) const
{
    json["id"] = id;
    json["ownerId"] = ownerId;
    json["name"] = name;
    json["type"] = type;
    json["breed"] = breed;
    json["age"] = age;
    json["sex"] = sex;
    json["isSpayed"] = isSpayed;
    json["status"] = status;
    json["severity"] = severity;
    json["timestamp"] = timestamp.toString(Qt::ISODate);
    json["requests"] = requests;
    json["locationText"] = locationText;
    json["contactPhone"] = contactPhone;
    json["contactEmail"] = contactEmail;
    json["description"] = description;

    QJsonObject locObj;
    locObj["lat"] = location.latitude();
    locObj["lon"] = location.longitude();
    json["location"] = locObj;

    // Save Images
    QJsonArray imgArray;
    for (const QString &img : images) {
        imgArray.append(img);
    }
    json["images"] = imgArray;
}
