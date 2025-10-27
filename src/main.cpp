#include <QCoreApplication>
#include <QDebug>
#include <QFont>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QResource>
#include <QStringList>

#include "ui/PlannerBackend.h"

int main(int argc, char* argv[]) {
    QGuiApplication app(argc, argv);
    QGuiApplication::setOrganizationName("noah");
    QGuiApplication::setOrganizationDomain("planner");
    QGuiApplication::setApplicationName("Noah Planner");

    QQuickStyle::setStyle("Basic");

    const QResource regularResource(QStringLiteral(":/fonts/Inter-Regular.ttf"));
    qDebug() << "Font exists?" << regularResource.isValid();
    const int regularId = QFontDatabase::addApplicationFont(":/fonts/Inter-Regular.ttf");
    const int boldId = QFontDatabase::addApplicationFont(":/fonts/Inter-Bold.ttf");
    if (regularId < 0 || boldId < 0) {
        qWarning() << "Inter font registration failed";
    }

    const QStringList families = QFontDatabase::applicationFontFamilies(regularId);
    const QString fallbackFamily = families.isEmpty() ? QStringLiteral("Inter") : families.first();
    QFont baseFont(fallbackFamily);
    if (!baseFont.family().isEmpty()) {
        QGuiApplication::setFont(baseFont);
    }

    PlannerBackend backend;

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/qt/qml");
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
