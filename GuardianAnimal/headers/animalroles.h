#ifndef ANIMALROLES_H
#define ANIMALROLES_H

#include <QObject>
#include <QtQml/qqmlregistration.h>

namespace AnimalRoles {

Q_NAMESPACE
QML_NAMED_ELEMENT(AnimalRoles)

enum Roles {
    IdRole = Qt::UserRole + 1,
    NameRole,
    TypeRole,
    BreedRole,
    AgeRole,
    LocationRole,
    DistanceRole,
    SeverityRole,
    StatusRole,
    ImageSourceRole,
    ImagesRole,
    OwnerIdRole,
    DescriptionRole,
    CoordinatesRole,
    ContactPhoneRole,
    ContactEmailRole
};
Q_ENUM_NS(Roles)

} // namespace AnimalRoles

#endif // ANIMALROLES_H

