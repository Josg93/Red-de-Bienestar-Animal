#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <mapmanager.h>
#include "rescuereport.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Material");
    // 1. REGISTRO META-TYPE: Necesario para que QVariant pueda contener RescueReport
    qRegisterMetaType<RescueReport>("RescueReport");


    // 2. REGISTRO QML: Para que QML sepa el tipo de dato
    qmlRegisterUncreatableType<RescueReport>("mapmanager", 1, 0, "RescueReport", "RescueReport is a data-only type.");

    qmlRegisterType<MapManager>("mapmanager", 1, 0, "MapManager");

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Proyecto", "Main");

    return app.exec();
}
