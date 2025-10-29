#pragma once

#include "AppState.h"
#include "core/CategoryRepository.h"
#include "core/EventRepository.h"
#include "core/FocusSessionRepository.h"
#include "core/QuickAddParser.h"
#include "models/EventModel.h"

#include <QAbstractListModel>
#include <QDate>
#include <QElapsedTimer>
#include <QObject>
#include <QString>
#include <QTimer>
#include <QVariantList>
#include <QVariantMap>
#include <QVector>

class PlannerBackend : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool darkTheme READ darkTheme WRITE setDarkTheme NOTIFY darkThemeChanged)
    Q_PROPERTY(QString selectedDate READ selectedDateIso NOTIFY selectedDateChanged)
    Q_PROPERTY(ViewMode viewMode READ viewMode WRITE setViewMode NOTIFY viewModeChanged)
    Q_PROPERTY(QString viewModeString READ viewModeString WRITE setViewModeString NOTIFY viewModeChanged)
    Q_PROPERTY(bool onlyOpen READ onlyOpen WRITE setOnlyOpen NOTIFY onlyOpenChanged)
    Q_PROPERTY(bool zenMode READ zenMode WRITE setZenMode NOTIFY zenModeChanged)
    Q_PROPERTY(QAbstractListModel* events READ eventsModel NOTIFY eventsChanged)
    Q_PROPERTY(QVariantList today READ todayEvents NOTIFY todayEventsChanged)
    Q_PROPERTY(QVariantList upcoming READ upcomingEvents NOTIFY upcomingEventsChanged)
    Q_PROPERTY(QVariantList exams READ examEvents NOTIFY examEventsChanged)
    Q_PROPERTY(QVariantList commands READ commands NOTIFY commandsChanged)
    Q_PROPERTY(QString searchQuery READ searchQuery WRITE setSearchQuery NOTIFY searchQueryChanged)
    Q_PROPERTY(QVariantList categories READ categories NOTIFY categoriesChanged)
    Q_PROPERTY(bool focusSessionActive READ focusSessionActive NOTIFY focusSessionActiveChanged)
    Q_PROPERTY(int focusElapsedSeconds READ focusElapsedSeconds NOTIFY focusElapsedSecondsChanged)
    Q_PROPERTY(QString activeTaskId READ activeTaskId NOTIFY activeTaskIdChanged)
    Q_PROPERTY(int currentStreak READ currentStreak NOTIFY currentStreakChanged)
    Q_PROPERTY(QVariantList weeklyMinutes READ weeklyMinutes NOTIFY weeklyMinutesChanged)

public:
    explicit PlannerBackend(QObject* parent = nullptr);

    enum class ViewMode { Month = 0, Week = 1, List = 2 };
    Q_ENUM(ViewMode)

    bool darkTheme() const;
    void setDarkTheme(bool dark);

    QString selectedDateIso() const;
    void selectDate(const QDate& date);

    ViewMode viewMode() const { return m_viewMode; }
    QString viewModeString() const;
    void setViewMode(ViewMode mode);
    void setViewModeString(const QString& mode);

    bool onlyOpen() const { return m_state.onlyOpen(); }
    void setOnlyOpen(bool onlyOpen);

    bool zenMode() const { return m_state.zenMode(); }
    void setZenMode(bool enabled);

    QString searchQuery() const { return m_searchQuery; }
    void setSearchQuery(const QString& query);

    QAbstractListModel* eventsModel() { return &m_eventModel; }
    QVariantList todayEvents() const { return m_today; }
    QVariantList upcomingEvents() const { return m_upcoming; }
    QVariantList examEvents() const { return m_exams; }
    QVariantList commands() const { return m_commands; }
    QVariantList categories() const { return m_categories; }
    
    bool focusSessionActive() const { return m_focusSessionActive; }
    int focusElapsedSeconds() const { return m_focusElapsedSeconds; }
    QString activeTaskId() const { return m_activeTaskId; }
    int currentStreak() const { return m_currentStreak; }
    QVariantList weeklyMinutes() const { return m_weeklyMinutes; }

    Q_INVOKABLE void selectDateIso(const QString& isoDate);
    Q_INVOKABLE void setViewMode(const QString& mode);
    Q_INVOKABLE void setOnlyOpenQml(bool value) { setOnlyOpen(value); }
    Q_INVOKABLE void jumpToToday();
    Q_INVOKABLE QVariant addQuickEntry(const QString& text);
    Q_INVOKABLE QVariantList search(const QString& query) const;
    Q_INVOKABLE QVariantList dayEvents(const QString& isoDate) const;
    Q_INVOKABLE QVariantList weekEvents(const QString& weekStartIso) const;
    Q_INVOKABLE QVariantList listBuckets() const;
    Q_INVOKABLE QVariantMap eventById(const QString& id) const;
    Q_INVOKABLE void setEventDone(const QString& id, bool done);
    Q_INVOKABLE void showToast(const QString& message);
    Q_INVOKABLE QVariantList listCategories() const;
    Q_INVOKABLE bool addCategory(const QString& id, const QString& name, const QString& color);
    Q_INVOKABLE bool updateCategory(const QString& id, const QString& name, const QString& color);
    Q_INVOKABLE bool removeCategory(const QString& id);
    Q_INVOKABLE bool setEntryCategory(const QString& entryId, const QString& categoryId);
    Q_INVOKABLE bool startFocus(const QString& taskId);
    Q_INVOKABLE bool stopFocus();
    Q_INVOKABLE bool pauseFocus();
    Q_INVOKABLE bool resumeFocus();
    Q_INVOKABLE QVariantList getFocusHistory(const QString& startDate, const QString& endDate) const;
    Q_INVOKABLE int getTodayFocusMinutes() const;

signals:
    void darkThemeChanged();
    void selectedDateChanged();
    void viewModeChanged();
    void onlyOpenChanged();
    void zenModeChanged();
    void eventsChanged();
    void todayEventsChanged();
    void upcomingEventsChanged();
    void examEventsChanged();
    void commandsChanged();
    void searchQueryChanged();
    void categoriesChanged();
    void toastRequested(const QString& message);
    void focusSessionActiveChanged();
    void focusElapsedSecondsChanged();
    void activeTaskIdChanged();
    void currentStreakChanged();
    void weeklyMinutesChanged();
    void focusTick(int elapsedSeconds);

private:
    EventRepository m_repository;
    CategoryRepository m_categoryRepository;
    FocusSessionRepository m_focusSessionRepository;
    EventModel m_eventModel;
    QuickAddParser m_parser;
    AppState m_state;

    QString m_storageDir;
    QDate m_selectedDate;
    ViewMode m_viewMode = ViewMode::Month;
    QString m_searchQuery;
    QVector<EventRecord> m_cachedEvents;
    QVariantList m_today;
    QVariantList m_upcoming;
    QVariantList m_exams;
    QVariantList m_commands;
    QVariantList m_categories;
    
    // Focus session state
    bool m_focusSessionActive = false;
    bool m_focusPaused = false;
    int m_focusElapsedSeconds = 0;
    QString m_activeTaskId;
    QString m_activeSessionId;
    QElapsedTimer m_focusTimer;
    QTimer* m_focusTickTimer;
    int m_currentStreak = 0;
    QVariantList m_weeklyMinutes;
    static constexpr int DAILY_THRESHOLD_MINUTES = 30;  // Minimum minutes for streak

    void initializeStorage();
    void reloadEvents();
    void rebuildSidebar();
    void rebuildCommands();
    void rebuildCategories();
    void updateStreak();
    void updateWeeklyMinutes();
    void saveFocusSession();
    QVariantMap toVariant(const EventRecord& record) const;
    QVector<EventRecord> filteredEvents() const;
    QVariantList buildDayEvents(const QDate& date) const;
    QVariantList buildRangeEvents(const QDate& start, const QDate& end) const;
    ViewMode modeFromString(const QString& mode) const;
    QString modeToString(ViewMode mode) const;
    void logEventLoad(int count) const;
    void notify(const QString& message);
};
