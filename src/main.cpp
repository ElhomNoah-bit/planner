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
    const QUrl url(QStringLiteral("qrc:/NoahPlanner/App.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app,
                     [url](QObject* obj, const QUrl& objUrl) {
                         if (!obj && url == objUrl) {
                             QCoreApplication::exit(-1);
                         }
                     },
                     Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
