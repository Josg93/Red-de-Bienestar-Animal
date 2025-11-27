#ifndef ANIMALRECORD_H
#define ANIMALRECORD_H

#include <QString>
#include <QStringList>
#include <QGeoCoordinate>
#include <QDateTime>
#include <QJsonObject>

struct AnimalRecord {
    // IDs
    QString id;
    QString ownerId;

    // Basic Info
    QString name;
    QString type;
    QString breed;
    QString age;
    QString sex;
    bool isSpayed = false; // Default to false for safety

    // Status & Priority
    QString status;
    QString severity;
    QDateTime timestamp;
    int requests = 0;

    // Location
    QGeoCoordinate location;
    QString locationText;

    // Contact
    QString contactPhone;
    QString contactEmail;
    QString description;

    // Media
    QStringList images;

    // Calculated field (Ignored in JSON)
    double distanceToUser = -1.0;

    bool isValid() const { return location.isValid(); }

    // --- SERIALIZATION METHODS (NEW) ---
    void read(const QJsonObject &json);
    void write(QJsonObject &json) const;
};

#endif // ANIMALRECORD_H
