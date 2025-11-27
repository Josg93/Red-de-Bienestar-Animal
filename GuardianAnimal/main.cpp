#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQmlContext>
#include <QIcon>
#include "headers/rescuemodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Material");

    app.setOrganizationName("GuardianAnimal");
    app.setOrganizationDomain("guardiananimal.org");

    RescueModel rescueModel;

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("backend", &rescueModel);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("GuardianAnimal", "Main");

    return app.exec();
}
