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
    m_settings->endGroup();
}

void AppState::save() const {
    m_settings->beginGroup("ui");
    m_settings->setValue("darkTheme", m_darkTheme);
    m_settings->setValue("onlyOpen", m_onlyOpen);
    m_settings->setValue("searchQuery", m_searchQuery);
    m_settings->setValue("subjectFilter", toStringList(m_subjectFilter));
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
