#ifndef RESCUESYSTEM_H
#define RESCUESYSTEM_H

#include "animalrecord.h"
#include "jobticket.h"
#include "maxheap.h"
#include "kdtree.h"
#include <QHash>
#include <QList>
#include <QString>
#include <QGeoCoordinate>
#include <QSet>
// --- NEW INCLUDES ---
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QFile>
#include <QStandardPaths>
#include <QDir>

class RescueSystem
{
public:
    RescueSystem();

    void addAnimal(const AnimalRecord& record);
    void updateAnimal(const AnimalRecord& record);
    bool removeAnimal(const QString& id);
    AnimalRecord getAnimal(const QString& id) const;

    QList<AnimalRecord> getEmergencyList(int limit = 20);
    QList<AnimalRecord> getNearestNeighbors(const QGeoCoordinate& center, int k = 5);
    QList<AnimalRecord> getAnimalsInRadius(const QGeoCoordinate& center, double radiusKm);
    QList<AnimalRecord> getByStatus(const QString& status);
    void resolveCase(const QString& id, const QString& outcome);
    QList<AnimalRecord> getHistory();

private:
    QHash<QString, AnimalRecord> m_database;
    MaxHeap m_priorityQueue;
    KDTree m_spatialIndex;
    void rebuildIndices();

    // --- PERSISTENCE METHODS ---
    void saveToDisk();
    void loadFromDisk();
};

#endif // RESCUESYSTEM_H


