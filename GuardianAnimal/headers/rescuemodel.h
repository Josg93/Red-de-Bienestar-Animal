#ifndef RESCUEMODEL_H
#define RESCUEMODEL_H

#include <QAbstractListModel>
#include <QGeoCoordinate>
#include "RescueSystem.h"
#include "AnimalRoles.h"
#include "GoogleMapsManager.h"

class RescueModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool filterByRadius READ filterByRadius WRITE setFilterByRadius NOTIFY filterChanged)
    Q_PROPERTY(double searchRadius READ searchRadius WRITE setSearchRadius NOTIFY filterChanged)
    Q_PROPERTY(QGeoCoordinate userLocation READ userLocation WRITE setUserLocation NOTIFY locationChanged)
    Q_PROPERTY(QString currentUserId READ currentUserId CONSTANT)
    Q_PROPERTY(QString searchQuery READ searchQuery WRITE setSearchQuery NOTIFY filterChanged)
    Q_PROPERTY(QString speciesFilter READ speciesFilter WRITE setSpeciesFilter NOTIFY filterChanged)

public:
    explicit RescueModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    // --- ADOPTION METHODS ---
    Q_INVOKABLE void addAdoption(const QString &name,
                                 const QString &type,
                                 const QString &age,
                                 const QString &sex,
                                 bool isSpayed,
                                 const QString &description,
                                 const QString &contactPhone,
                                 const QString &contactEmail,
                                 const QVariantList &imageList,
                                 const QString &shelterName);

    Q_INVOKABLE void updateAdoption(const QString &id,
                                    const QString &name,
                                    const QString &type,
                                    const QString &age,
                                    const QString &sex,
                                    bool isSpayed,
                                    const QString &description,
                                    const QString &contactPhone,
                                    const QString &contactEmail,
                                    const QVariantList &imageList,
                                    const QString &shelterName);



    Q_INVOKABLE void addLostFound(const QString &status,
                                  const QString &name,
                                  const QString &type,
                                  const QString &breed,
                                  const QString &dateText,
                                  const QString &locationText,
                                  const QString &contactPhone,
                                  const QVariantList &images);



    Q_INVOKABLE QVariantMap getAnimalDetails(const QString& animalId);
    Q_INVOKABLE void addReport(const QString& type, const QString& severity,
                               const QString& locationText, const QString& description,
                               const QString& imagePath, const QGeoCoordinate& gps);
    Q_INVOKABLE void setViewMode(const QString& mode);
    Q_INVOKABLE void updateUserPosition(double lat, double lon);
    Q_INVOKABLE void setCurrentUserId(const QString& userId);
    Q_INVOKABLE void requestRouteToAnimal(const QString& animalId);
    Q_INVOKABLE void resolveCase(const QString& id, const QString& outcome);
    Q_INVOKABLE QVariantList checkDuplicates(const QString& animalType,
                                             double lat, double lon,
                                             double radiusKm);

    QString speciesFilter() const { return m_speciesFilter; }
    QString searchQuery() const { return m_searchQuery; }
    QString currentUserId() const { return m_currentUserId; }
    bool filterByRadius() const { return m_filterByRadius; }
    double searchRadius() const { return m_searchRadius; }
    QGeoCoordinate userLocation() const { return m_userLocation; }
    void refresh();

public slots:
    void setFilterByRadius(bool enable);
    void setSearchRadius(double km);
    void setUserLocation(const QGeoCoordinate& location);
    void setSearchQuery(const QString &query);
    void setSpeciesFilter(const QString &species);

signals:
    void filterChanged();
    void locationChanged();
    void routeReady(QVariantList path, QString distance, QString duration);

private:
    RescueSystem m_system;
    QList<AnimalRecord> m_displayList;
    GoogleMapsManager* m_mapsManager;
    QString m_currentUserId;
    QString m_currentMode = "emergency";
    bool m_filterByRadius = false;
    double m_searchRadius = 10.0;
    QGeoCoordinate m_userLocation;
    QString m_searchQuery;
    QString m_speciesFilter;
};

#endif // RESCUEMODEL_H

