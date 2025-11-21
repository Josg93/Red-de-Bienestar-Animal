#ifndef RESCUEREPORT_H
#define RESCUEREPORT_H // FIX 1: Macro was RESCUEReport_H. Changed 'e' to 'E' for consistency.

#include <QGeoCoordinate>
#include <QMetaType> // Para Q_GADGET y Q_DECLARE_METATYPE

// ¡IMPORTANTE! NO HEREDA DE QObject. Solo usa Q_GADGET.
class RescueReport
{
    Q_GADGET

    Q_PROPERTY(int id READ id CONSTANT)
    Q_PROPERTY(QGeoCoordinate coordinate READ coordinate CONSTANT)
    Q_PROPERTY(int priority READ priority CONSTANT)

public:
    // Constructor por defecto
    RescueReport() : m_id(-1), m_priority(-1) {} // m_coordinate will be default constructed.

    // Constructor principal
    RescueReport(int id, const QGeoCoordinate &coord, int priority)
        : m_id(id), m_coordinate(coord), m_priority(priority) {}

    // No es estrictamente necesario, pero ayuda a la claridad:
    // Aseguramos que la clase sea copiable y movible (default).
    RescueReport(const RescueReport& other) = default;
    RescueReport& operator=(const RescueReport& other) = default;

    // Getters
    int id() const { return m_id; }
    QGeoCoordinate coordinate() const { return m_coordinate; }
    int priority() const { return m_priority; }

private:
    int m_id;
    QGeoCoordinate m_coordinate;
    int m_priority; // FIX 2: Changed type from QGeoCoordinate to int.
};

// 1. Esto permite que el MOC procese el Q_GADGET.
// 2. Permite que QVariant::fromValue funcione...
Q_DECLARE_METATYPE(RescueReport)

#endif // RESCUEREPORT_H
