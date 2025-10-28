#pragma once

#include <QSet>
#include <QString>

class QSettings;

class AppState {
public:
    AppState();
    ~AppState();

    AppState(const AppState&) = delete;
    AppState& operator=(const AppState&) = delete;
    AppState(AppState&&) = delete;
    AppState& operator=(AppState&&) = delete;

    void load();
    void save() const;

    bool darkTheme() const { return m_darkTheme; }
    bool setDarkTheme(bool dark);

    bool onlyOpen() const { return m_onlyOpen; }
    bool setOnlyOpen(bool onlyOpen);

    QString searchQuery() const { return m_searchQuery; }
    bool setSearchQuery(const QString& query);

    QSet<QString> subjectFilter() const { return m_subjectFilter; }
    bool setSubjectFilter(const QSet<QString>& subjects);

    QString viewMode() const { return m_viewMode; }
    bool setViewMode(const QString& mode);

    QString language() const { return m_language; }
    bool setLanguage(const QString& language);

    QString weekStart() const { return m_weekStart; }
    bool setWeekStart(const QString& weekStart);

    bool weekNumbers() const { return m_weekNumbers; }
    bool setWeekNumbers(bool enabled);

private:
    mutable QSettings* m_settings;
    bool m_darkTheme = true;
    bool m_onlyOpen = false;
    QString m_searchQuery;
    QSet<QString> m_subjectFilter;
    QString m_language = QStringLiteral("de");
    QString m_weekStart = QStringLiteral("monday");
    bool m_weekNumbers = false;
    QString m_viewMode = QStringLiteral("month");
};
