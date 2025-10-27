#include <QCoreApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

#include "ui/PlannerBackend.h"

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    QGuiApplication::setOrganizationName("noah");
    QGuiApplication::setOrganizationDomain("planner");
    QGuiApplication::setApplicationName("Noah Planner");

    QQuickStyle::setStyle("Basic");

    PlannerBackend backend;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("PlannerBackend", &backend);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app,
                     [](QObject* obj, const QUrl& objUrl) {
                         if (!obj && objUrl.isEmpty()) {
                             QCoreApplication::exit(-1);
                         }
                     },
                     Qt::QueuedConnection);
    engine.loadFromModule("NoahPlanner", "App");

    return app.exec();
}
