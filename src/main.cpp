#include <QApplication>
#include <QCoreApplication>
#include <QDebug>
#include <QFont>
#include <QFontDatabase>
#include <QFontInfo>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QStringList>
#include "ui/PlannerBackend.h"

static void registerFonts() {
    const auto addFont = [](const QString& filename) {
        const QString resourcePath = QStringLiteral(":/fonts/%1").arg(filename);
        const int fontId = QFontDatabase::addApplicationFont(resourcePath);
        if (fontId == -1) {
            qWarning() << "Failed to load font" << filename;
        } else {
            qInfo() << "Loaded font" << filename << QFontDatabase::applicationFontFamilies(fontId);
        }
        return fontId;
    };

    addFont(QStringLiteral("Inter-Regular.ttf"));
    addFont(QStringLiteral("Inter-Bold.ttf"));

    if (QFontDatabase::families().contains(QStringLiteral("Inter"))) {
        qInfo() << "Inter font available after registration";
    }

    QFont appFont(QStringLiteral("Inter"));
    if (!QFontInfo(appFont).exactMatch()) {
        qWarning() << "Inter not available, falling back to Noto Sans / DejaVu Sans";
        appFont = QFont(QStringLiteral("Noto Sans"));
        if (!QFontInfo(appFont).exactMatch()) {
            appFont = QFont(QStringLiteral("DejaVu Sans"));
        }
    }

    appFont.setStyleName(QStringLiteral("Regular"));
    QApplication::setFont(appFont);
}

int main(int argc, char* argv[]) {
    QApplication app(argc, argv);
    QApplication::setOrganizationName("noah");
    QApplication::setOrganizationDomain("planner");
    QApplication::setApplicationName("Noah Planner");

    QQuickStyle::setStyle("Basic");

    registerFonts();

    PlannerBackend backend;

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/qt/qml");
    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml");
    engine.rootContext()->setContextProperty("planner", &backend);
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
