#include "ThemeManager.h"

#include <QApplication>
#include <QFile>
#include <QPalette>
#include <QStyle>
#include <QStyleFactory>

namespace {
QString stylesheetPathFor(ThemeManager::Theme theme) {
    switch (theme) {
    case ThemeManager::Theme::Light:
        return ":/ui/styles/light.qss";
    case ThemeManager::Theme::Dark:
    default:
        return ":/ui/styles/dark.qss";
    }
}
}

ThemeManager::ThemeManager(QObject* parent)
    : QObject(parent) {
}

void ThemeManager::apply(Theme theme) {
    const bool changed = (m_current != theme) || !m_initialized;
    m_current = theme;

    applyPalette(theme);
    applyStylesheet(theme);

    if (!m_initialized) m_initialized = true;
    if (changed) emit themeChanged(theme);
}

void ThemeManager::applyPalette(Theme theme) {
    QPalette palette;

    if (theme == Theme::Dark) {
        palette.setColor(QPalette::Window, QColor("#0B0F1A"));
        palette.setColor(QPalette::WindowText, QColor("#E6EDF7"));
        palette.setColor(QPalette::Base, QColor("#111827"));
        palette.setColor(QPalette::AlternateBase, QColor("#141C2C"));
        palette.setColor(QPalette::Text, QColor("#E6EDF7"));
        palette.setColor(QPalette::Button, QColor("#141C2C"));
        palette.setColor(QPalette::ButtonText, QColor("#E6EDF7"));
        palette.setColor(QPalette::Highlight, QColor("#0A84FF"));
        palette.setColor(QPalette::HighlightedText, QColor("#FFFFFF"));
    } else {
    palette = QApplication::style()->standardPalette();
        palette.setColor(QPalette::Highlight, QColor("#0A84FF"));
        palette.setColor(QPalette::HighlightedText, QColor("#FFFFFF"));
    }

    QApplication::setPalette(palette);
}

void ThemeManager::applyStylesheet(Theme theme) {
    const QString path = stylesheetPathFor(theme);
    QFile file(path);

    if (!file.open(QIODevice::ReadOnly)) {
        if (qApp) qApp->setStyleSheet(QString());
        return;
    }

    const QString stylesheet = QString::fromUtf8(file.readAll());
    if (qApp) qApp->setStyleSheet(stylesheet);
}
