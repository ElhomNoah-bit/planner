#pragma once

#include "AppState.h"
#include "core/CategoryRepository.h"
#include "core/EventRepository.h"
#include "core/QuickAddParser.h"
#include "models/EventModel.h"

#include <QAbstractListModel>
#include <QDate>
#include <QObject>
#include <QString>
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
    Q_INVOKABLE bool moveEntry(const QString& entryId, const QString& newStartIso, const QString& newEndIso);

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
    void entryMoved(const QString& entryId, const QString& oldStartIso, const QString& oldEndIso);

private:
    EventRepository m_repository;
    CategoryRepository m_categoryRepository;
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

    void initializeStorage();
    void reloadEvents();
    void rebuildSidebar();
    void rebuildCommands();
    void rebuildCategories();
    QVariantMap toVariant(const EventRecord& record) const;
    QVector<EventRecord> filteredEvents() const;
    QVariantList buildDayEvents(const QDate& date) const;
    QVariantList buildRangeEvents(const QDate& start, const QDate& end) const;
    ViewMode modeFromString(const QString& mode) const;
    QString modeToString(ViewMode mode) const;
    void logEventLoad(int count) const;
    void notify(const QString& message);
};
