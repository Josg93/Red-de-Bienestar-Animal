#ifndef JOBTICKET_H
#define JOBTICKET_H

#include <QString>
#include <QDateTime>
#include <QGeoCoordinate>

struct JobTicket {
    QString animalId;
    int severity;
    qint64 timestamp;
    QGeoCoordinate location;


    bool operator<(const JobTicket& other) const {

        if (severity != other.severity) {
            // If 'this' severity is smaller, it goes down.
            return severity < other.severity;
        }

        return timestamp > other.timestamp;
    }
};

#endif // JOBTICKET_H
