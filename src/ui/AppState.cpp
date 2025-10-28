#include "AppState.h"

#include <QSettings>

namespace {
QStringList toStringList(const QSet<QString>& values) {
    QStringList list;
    list.reserve(values.size());
    for (const auto& v : values) list.append(v);
    return list;
}
}

AppState::AppState()
    : m_settings(new QSettings("noah", "planner")) {
    load();
}

AppState::~AppState() {
    save();
    delete m_settings;
}

void AppState::load() {
    m_settings->beginGroup("ui");
    m_darkTheme = m_settings->value("darkTheme", true).toBool();
    m_onlyOpen = m_settings->value("onlyOpen", false).toBool();
    m_searchQuery = m_settings->value("searchQuery", QString()).toString();
    const QStringList subjects = m_settings->value("subjectFilter").toStringList();
    m_subjectFilter = QSet<QString>(subjects.begin(), subjects.end());
    m_language = m_settings->value("language", QStringLiteral("de")).toString();
    m_weekStart = m_settings->value("weekStart", QStringLiteral("monday")).toString();
    m_weekNumbers = m_settings->value("weekNumbers", false).toBool();
    const QString persistedView = m_settings->value("viewMode", QStringLiteral("month")).toString();
    if (!persistedView.isEmpty()) {
        m_viewMode = persistedView;
    }
    m_settings->endGroup();
}

void AppState::save() const {
    m_settings->beginGroup("ui");
    m_settings->setValue("darkTheme", m_darkTheme);
    m_settings->setValue("onlyOpen", m_onlyOpen);
    m_settings->setValue("searchQuery", m_searchQuery);
    m_settings->setValue("subjectFilter", toStringList(m_subjectFilter));
    m_settings->setValue("language", m_language);
    m_settings->setValue("weekStart", m_weekStart);
    m_settings->setValue("weekNumbers", m_weekNumbers);
    m_settings->setValue("viewMode", m_viewMode);
    m_settings->endGroup();
    m_settings->sync();
}

bool AppState::setDarkTheme(bool dark) {
    if (m_darkTheme == dark) return false;
    m_darkTheme = dark;
    return true;
}

bool AppState::setOnlyOpen(bool onlyOpen) {
    if (m_onlyOpen == onlyOpen) return false;
    m_onlyOpen = onlyOpen;
    return true;
}

bool AppState::setSearchQuery(const QString& query) {
    if (m_searchQuery == query) return false;
    m_searchQuery = query;
    return true;
}

bool AppState::setSubjectFilter(const QSet<QString>& subjects) {
    if (m_subjectFilter == subjects) return false;
    m_subjectFilter = subjects;
    return true;
}

bool AppState::setLanguage(const QString& language) {
    const QString normalized = language.trimmed().toLower();
    if (normalized.isEmpty()) return false;
    if (m_language == normalized) return false;
    m_language = normalized;
    return true;
}

bool AppState::setWeekStart(const QString& weekStart) {
    const QString normalized = weekStart.trimmed().toLower();
    if (normalized != QStringLiteral("monday") && normalized != QStringLiteral("sunday")) return false;
    if (m_weekStart == normalized) return false;
    m_weekStart = normalized;
    return true;
}

bool AppState::setWeekNumbers(bool enabled) {
    if (m_weekNumbers == enabled) return false;
    m_weekNumbers = enabled;
    return true;
}

bool AppState::setViewMode(const QString& mode) {
    const QString normalized = mode.trimmed().toLower();
    if (normalized.isEmpty()) return false;
    if (normalized != QStringLiteral("month") && normalized != QStringLiteral("week") && normalized != QStringLiteral("list")) {
        return false;
    }
    if (m_viewMode == normalized) return false;
    m_viewMode = normalized;
    return true;
}
