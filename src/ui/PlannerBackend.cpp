#include "PlannerBackend.h"

#include <QCoreApplication>
#include <QDateTime>
#include <QDir>
#include <QLocale>
#include <QMap>
#include <QSet>
#include <QStandardPaths>
#include <QTimeZone>

#include <algorithm>

namespace {
const QString kDefaultCategoryColor = QStringLiteral("#2F3645");
QString toIsoDate(const QDate& date) {
    return date.toString(Qt::ISODate);
}

QString toIsoDateTime(const QDateTime& dateTime) {
    if (!dateTime.isValid()) {
        return QString();
    }
    return dateTime.toString(Qt::ISODate);
}

QDate fromIsoDate(const QString& iso) {
    return QDate::fromString(iso, Qt::ISODate);
}

QDateTime fromIsoDateTime(const QString& iso) {
    return QDateTime::fromString(iso, Qt::ISODate);
}

QLocale germanLocale() {
    static const QLocale loc(QLocale::German, QLocale::Germany);
    return loc;
}

int weekStartDay(const QString& setting) {
    if (setting.compare(QStringLiteral("sunday"), Qt::CaseInsensitive) == 0) {
        return Qt::Sunday;
    }
    return Qt::Monday;
}
} // namespace

PlannerBackend::PlannerBackend(QObject* parent)
    : QObject(parent) {
    m_searchQuery = m_state.searchQuery();
    m_viewMode = modeFromString(m_state.viewMode());
    m_selectedDate = QDate::currentDate();

    initializeStorage();
    connect(&m_pomodoro, &PomodoroTimer::tick, this, &PlannerBackend::rebuildPomodoroState);
    connect(&m_pomodoro, &PomodoroTimer::phaseChanged, this, &PlannerBackend::rebuildPomodoroState);
    connect(&m_pomodoro, &PomodoroTimer::runningChanged, this, &PlannerBackend::rebuildPomodoroState);
    connect(&m_pomodoro, &PomodoroTimer::cycleCompleted, this, &PlannerBackend::rebuildPomodoroState);

    reloadEvents();
    rebuildCommands();
    rebuildCategories();
    rebuildSidebar();
    rebuildFocusState();
    rebuildPomodoroState();
    rebuildDueReviews();

    emit selectedDateChanged();
    emit viewModeChanged();
    emit onlyOpenChanged();
    emit zenModeChanged();
    emit darkThemeChanged();
    emit commandsChanged();
    emit categoriesChanged();
    emit todayEventsChanged();
    emit upcomingEventsChanged();
    emit examEventsChanged();
    emit urgentEventsChanged();
    emit focusHistoryChanged();
    emit focusSessionChanged();
    emit focusSessionActiveChanged();
    emit focusStreakChanged();
    emit pomodoroChanged();
    emit dueReviewsChanged();
    emit setupCompletedChanged();
    emit languageChanged();
    emit weekStartChanged();
    emit showWeekNumbersChanged();
    if (!m_searchQuery.isEmpty()) {
        emit searchQueryChanged();
    }
}

bool PlannerBackend::darkTheme() const {
    return m_state.darkTheme();
}

void PlannerBackend::setDarkTheme(bool dark) {
    if (!m_state.setDarkTheme(dark)) {
        return;
    }
    m_state.save();
    emit darkThemeChanged();
}

void PlannerBackend::setSetupCompleted(bool completed) {
    if (!m_state.setSetupCompleted(completed)) {
        return;
    }
    m_state.save();
    emit setupCompletedChanged();
}

void PlannerBackend::setLanguage(const QString& language) {
    if (!m_state.setLanguage(language)) {
        return;
    }
    m_state.save();
    emit languageChanged();
}

void PlannerBackend::setWeekStart(const QString& weekStart) {
    if (!m_state.setWeekStart(weekStart)) {
        return;
    }
    m_state.save();
    emit weekStartChanged();
}

void PlannerBackend::setShowWeekNumbers(bool enabled) {
    if (!m_state.setWeekNumbers(enabled)) {
        return;
    }
    m_state.save();
    emit showWeekNumbersChanged();
}

QString PlannerBackend::selectedDateIso() const {
    return toIsoDate(m_selectedDate);
}

void PlannerBackend::selectDate(const QDate& date) {
    if (!date.isValid() || date == m_selectedDate) {
        return;
    }
    m_selectedDate = date;
    emit selectedDateChanged();
}

QString PlannerBackend::viewModeString() const {
    return modeToString(m_viewMode);
}

void PlannerBackend::setViewMode(ViewMode mode) {
    if (m_viewMode == mode) {
        return;
    }
    m_viewMode = mode;
    m_state.setViewMode(modeToString(mode));
    m_state.save();
    emit viewModeChanged();
}

void PlannerBackend::setViewMode(const QString& mode) {
    setViewModeString(mode);
}

void PlannerBackend::setViewModeString(const QString& mode) {
    setViewMode(modeFromString(mode));
}

void PlannerBackend::setOnlyOpen(bool onlyOpen) {
    if (!m_state.setOnlyOpen(onlyOpen)) {
        return;
    }
    m_state.save();
    reloadEvents();
    rebuildSidebar();
    emit onlyOpenChanged();
}

void PlannerBackend::setZenMode(bool enabled) {
    if (!m_state.setZenMode(enabled)) {
        return;
    }
    m_state.save();
    emit zenModeChanged();
}

void PlannerBackend::setSearchQuery(const QString& query) {
    const QString trimmed = query.trimmed();
    if (m_searchQuery == trimmed) {
        return;
    }
    m_searchQuery = trimmed;
    m_state.setSearchQuery(trimmed);
    m_state.save();
    emit searchQueryChanged();
}

void PlannerBackend::selectDateIso(const QString& isoDate) {
    selectDate(fromIsoDate(isoDate));
}

void PlannerBackend::jumpToToday() {
    selectDate(QDate::currentDate());
}

QVariant PlannerBackend::addQuickEntry(const QString& text) {
    const QuickAddResult parsed = m_parser.parse(text);
    if (!parsed.success) {
        notify(tr("Eingabe konnte nicht verarbeitet werden"));
        return {};
    }

    EventRecord record = parsed.record;
    if (!m_repository.insert(record)) {
        notify(tr("Speichern fehlgeschlagen"));
        return {};
    }

    qInfo() << "[QuickAdd]" << record.title
            << toIsoDateTime(record.start)
            << toIsoDateTime(record.end)
            << "allDay=" << record.allDay
            << "tags=" << record.tags;

    reloadEvents();
    rebuildSidebar();
    notify(tr("Eintrag gespeichert"));
    return toVariant(record);
}

QVariantList PlannerBackend::search(const QString& query) const {
    const QVector<EventRecord> hits = m_repository.search(query, m_state.onlyOpen());
    QVariantList result;
    result.reserve(hits.size());
    for (const auto& record : hits) {
        result.append(toVariant(record));
    }
    return result;
}

QVariantList PlannerBackend::dayEvents(const QString& isoDate) const {
    const QDate date = fromIsoDate(isoDate);
    if (!date.isValid()) {
        return {};
    }
    return buildDayEvents(date);
}

QVariantList PlannerBackend::weekEvents(const QString& weekStartIso) const {
    QDate anchor = fromIsoDate(weekStartIso);
    if (!anchor.isValid()) {
        anchor = m_selectedDate;
    }
    const int startDay = weekStartDay(m_state.weekStart());
    while (anchor.dayOfWeek() != startDay) {
        anchor = anchor.addDays(-1);
    }
    const QDate end = anchor.addDays(6);

    QVariantList events;
    for (const auto& record : m_cachedEvents) {
        const QDate day = record.start.date();
        if (day < anchor || day > end) {
            continue;
        }
        QVariantMap map = toVariant(record);
        map.insert(QStringLiteral("dayIndex"), anchor.daysTo(day));
        if (record.allDay) {
            map.insert(QStringLiteral("startMinutes"), 0);
            map.insert(QStringLiteral("duration"), 24 * 60);
        } else {
            const int startMinutes = record.start.time().hour() * 60 + record.start.time().minute();
            const int endMinutes = record.end.time().hour() * 60 + record.end.time().minute();
            const int duration = std::max(15, endMinutes - startMinutes);
            map.insert(QStringLiteral("startMinutes"), std::max(0, startMinutes));
            map.insert(QStringLiteral("duration"), duration);
        }
        events.append(map);
    }

    std::sort(events.begin(), events.end(), [](const QVariant& left, const QVariant& right) {
        const QVariantMap l = left.toMap();
        const QVariantMap r = right.toMap();
        if (l.value(QStringLiteral("dayIndex")).toInt() == r.value(QStringLiteral("dayIndex")).toInt()) {
            return l.value(QStringLiteral("startMinutes")).toInt() < r.value(QStringLiteral("startMinutes")).toInt();
        }
        return l.value(QStringLiteral("dayIndex")).toInt() < r.value(QStringLiteral("dayIndex")).toInt();
    });

    return events;
}

QVariantList PlannerBackend::listBuckets() const {
    const QDate today = QDate::currentDate();
    const QDate start = today.addDays(-30);
    const QDate end = today.addDays(30);
    const QLocale loc = germanLocale();

    QMap<QString, QVariantMap> buckets;

    for (const auto& record : m_cachedEvents) {
        const QDate date = record.start.date();
        if (date < start || date > end) {
            continue;
        }
        int weekYear = 0;
        const int weekNumber = date.weekNumber(&weekYear);
        const QString key = QStringLiteral("%1-%2").arg(weekYear).arg(weekNumber, 2, 10, QLatin1Char('0'));

        QVariantMap bucket = buckets.value(key);
        if (bucket.isEmpty()) {
            const int startDay = weekStartDay(m_state.weekStart());
            QDate weekStart = date;
            while (weekStart.dayOfWeek() != startDay) {
                weekStart = weekStart.addDays(-1);
            }
            const QDate weekEnd = weekStart.addDays(6);
            bucket.insert(QStringLiteral("key"), key);
            bucket.insert(QStringLiteral("label"),
                          tr("KW %1 (%2 – %3)")
                              .arg(weekNumber)
                              .arg(loc.toString(weekStart, QStringLiteral("dd.MM.")))
                              .arg(loc.toString(weekEnd, QStringLiteral("dd.MM."))));
            bucket.insert(QStringLiteral("items"), QVariantList());
        }
        QVariantList items = bucket.value(QStringLiteral("items")).toList();
        items.append(toVariant(record));
        // Sort items by priority (high to low) then by start time
        std::sort(items.begin(), items.end(), [](const QVariant& a, const QVariant& b) {
            const QVariantMap aMap = a.toMap();
            const QVariantMap bMap = b.toMap();
            const int aPriority = aMap.value(QStringLiteral("priority")).toInt();
            const int bPriority = bMap.value(QStringLiteral("priority")).toInt();
            if (aPriority != bPriority) {
                return aPriority > bPriority; // Higher priority first
            }
            return aMap.value(QStringLiteral("start")).toString() < bMap.value(QStringLiteral("start")).toString();
        });
        bucket.insert(QStringLiteral("items"), items);
        buckets.insert(key, bucket);
    }

    QVariantList result;
    const auto keys = buckets.keys();
    for (const auto& key : keys) {
        result.append(buckets.value(key));
    }

    std::sort(result.begin(), result.end(), [](const QVariant& a, const QVariant& b) {
        return a.toMap().value(QStringLiteral("key")).toString() < b.toMap().value(QStringLiteral("key")).toString();
    });

    return result;
}

QVariantMap PlannerBackend::eventById(const QString& id) const {
    if (id.isEmpty()) {
        return {};
    }
    for (const auto& record : m_cachedEvents) {
        if (record.id == id) {
            return toVariant(record);
        }
    }
    return {};
}

void PlannerBackend::setEventDone(const QString& id, bool done) {
    if (id.isEmpty()) {
        return;
    }
    if (!m_repository.setDone(id, done)) {
        notify(tr("Status konnte nicht aktualisiert werden"));
        return;
    }
    reloadEvents();
    rebuildSidebar();
    notify(done ? tr("Als erledigt markiert") : tr("Als offen markiert"));
}

void PlannerBackend::showToast(const QString& message) {
    if (message.trimmed().isEmpty()) {
        return;
    }
    notify(message);
}

void PlannerBackend::initializeStorage() {
    QString base = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (base.isEmpty()) {
        base = QDir(QCoreApplication::applicationDirPath()).filePath(QStringLiteral("data"));
    }
    QDir dir(base);
    if (!dir.exists()) {
        dir.mkpath(QStringLiteral("."));
    }
    m_storageDir = dir.absolutePath();

    if (!m_repository.initialize(m_storageDir)) {
        qWarning() << "[PlannerBackend] Repository initialisation failed for" << m_storageDir;
    }

    if (!m_categoryRepository.initialize(m_storageDir)) {
        qWarning() << "[PlannerBackend] Category repository initialisation failed for" << m_storageDir;
    }

    m_focusRepository.setStorageDirectory(m_storageDir);
    m_reviewService.setDataDirectory(m_storageDir);

    const QString storePath = m_repository.isSqlAvailable() ? m_repository.databasePath() : m_repository.jsonFallbackPath();
    qInfo() << "[PlannerBackend] DB path:" << storePath;
    qInfo() << "[PlannerBackend] Categories path:" << m_categoryRepository.categoriesPath();
}

void PlannerBackend::reloadEvents() {
    m_cachedEvents = m_repository.loadAll(m_state.onlyOpen());
    std::sort(m_cachedEvents.begin(), m_cachedEvents.end(), [](const EventRecord& a, const EventRecord& b) {
        if (a.start == b.start) {
            return a.title.toLower() < b.title.toLower();
        }
        return a.start < b.start;
    });
    m_eventModel.replaceAll(m_cachedEvents);
    emit eventsChanged();
    logEventLoad(m_cachedEvents.size());
}

void PlannerBackend::rebuildSidebar() {
    const QDate today = QDate::currentDate();
    const QDate upcomingEnd = today.addDays(7);

    QVariantList todayItems;
    QVariantList upcomingItems;
    QVariantList examItems;

    for (const auto& record : m_cachedEvents) {
        const QDate eventDate = record.start.date();
        if (eventDate == today) {
            todayItems.append(toVariant(record));
        }
        if (eventDate > today && eventDate <= upcomingEnd) {
            upcomingItems.append(toVariant(record));
        }
        if (record.isExam && eventDate >= today) {
            examItems.append(toVariant(record));
        }
    }

    // Sort by priority (high to low) then by start time
    auto prioritySort = [](const QVariant& a, const QVariant& b) {
        const QVariantMap aMap = a.toMap();
        const QVariantMap bMap = b.toMap();
        const int aPriority = aMap.value(QStringLiteral("priority")).toInt();
        const int bPriority = bMap.value(QStringLiteral("priority")).toInt();
        if (aPriority != bPriority) {
            return aPriority > bPriority; // Higher priority first
        }
        return aMap.value(QStringLiteral("start")).toString() < bMap.value(QStringLiteral("start")).toString();
    };

    std::sort(todayItems.begin(), todayItems.end(), prioritySort);
    std::sort(upcomingItems.begin(), upcomingItems.end(), prioritySort);
    std::sort(examItems.begin(), examItems.end(), prioritySort);

    if (m_today != todayItems) {
        m_today = todayItems;
        emit todayEventsChanged();
    }
    if (m_upcoming != upcomingItems) {
        m_upcoming = upcomingItems;
        emit upcomingEventsChanged();
    }
    if (m_exams != examItems) {
        m_exams = examItems;
        emit examEventsChanged();
    }

    rebuildUrgent(today);
}

void PlannerBackend::rebuildCommands() {
    QVariantList list;

    const auto add = [&](const QString& id, const QString& title, const QString& hint) {
        QVariantMap map;
        map.insert(QStringLiteral("id"), id);
        map.insert(QStringLiteral("title"), title);
        map.insert(QStringLiteral("hint"), hint);
        list.append(map);
    };

    add(QStringLiteral("go-today"), tr("Zu heute springen"), tr("Fokus auf das heutige Datum"));
    add(QStringLiteral("new-item"), tr("Schnellerfassung öffnen"), tr("Neuen Eintrag anlegen"));
    add(QStringLiteral("view-month"), tr("Ansicht: Monat"), QString());
    add(QStringLiteral("view-week"), tr("Ansicht: Woche"), QString());
    add(QStringLiteral("view-list"), tr("Ansicht: Liste"), QString());
    add(QStringLiteral("toggle-open"), tr("Nur offene umschalten"), QString());
    add(QStringLiteral("toggle-zen"), tr("Zen-Modus umschalten"), tr("Fokus auf den ausgewählten Tag"));
    add(QStringLiteral("open-settings"), tr("Einstellungen öffnen"), QString());
    add(QStringLiteral("start-focus"), tr("Fokus-Sitzung starten"), tr("Beginnt eine 25-Minuten-Sitzung"));
    add(QStringLiteral("open-pomodoro"), tr("Pomodoro öffnen"), tr("Zeigt den Fokus-Timer"));
    add(QStringLiteral("export-week"), tr("Woche exportieren"), tr("Erstellt eine PDF der Woche"));
    add(QStringLiteral("export-month"), tr("Monat exportieren"), tr("Erstellt eine PDF des Monats"));
    add(QStringLiteral("open-reviews"), tr("Reviews öffnen"), tr("Spaced Repetition Reviews verwalten"));

    if (m_commands != list) {
        m_commands = list;
        emit commandsChanged();
    }
}

QVariantMap PlannerBackend::toVariant(const EventRecord& record) const {
    QVariantMap map;
    const QLocale loc = germanLocale();
    map.insert(QStringLiteral("id"), record.id);
    map.insert(QStringLiteral("title"), record.title);
    map.insert(QStringLiteral("start"), toIsoDateTime(record.start));
    map.insert(QStringLiteral("end"), toIsoDateTime(record.end));
    map.insert(QStringLiteral("allDay"), record.allDay);
    map.insert(QStringLiteral("location"), record.location);
    map.insert(QStringLiteral("notes"), record.notes);
    map.insert(QStringLiteral("tags"), QVariant::fromValue(record.tags));
    map.insert(QStringLiteral("isExam"), record.isExam);
    map.insert(QStringLiteral("isDone"), record.isDone);
    map.insert(QStringLiteral("due"), toIsoDateTime(record.due));
    map.insert(QStringLiteral("colorHint"), record.colorHint);
    map.insert(QStringLiteral("priority"), record.priority);
    map.insert(QStringLiteral("day"), toIsoDate(record.start.date()));
    map.insert(QStringLiteral("weekdayLabel"), loc.toString(record.start.date(), QStringLiteral("ddd")));
    map.insert(QStringLiteral("dateLabel"), loc.toString(record.start.date(), QStringLiteral("dd.MM.yyyy")));
    if (record.allDay) {
        map.insert(QStringLiteral("startTimeLabel"), tr("Ganztägig"));
        map.insert(QStringLiteral("endTimeLabel"), QString());
    } else {
        map.insert(QStringLiteral("startTimeLabel"), loc.toString(record.start.time(), QStringLiteral("HH:mm")));
        map.insert(QStringLiteral("endTimeLabel"), loc.toString(record.end.time(), QStringLiteral("HH:mm")));
    }
    map.insert(QStringLiteral("overdue"),
               record.due.isValid() && record.due < QDateTime::currentDateTime());
    map.insert(QStringLiteral("categoryId"), record.categoryId);
    map.insert(QStringLiteral("source"), record.source);
    map.insert(QStringLiteral("externalId"), record.externalId);
    map.insert(QStringLiteral("eventType"), record.eventType);

    QString resolvedCategoryColor = kDefaultCategoryColor;
    if (!record.categoryId.isEmpty()) {
        Category cat = m_categoryRepository.findById(record.categoryId);
        if (cat.isValid() && cat.color.isValid()) {
            resolvedCategoryColor = cat.color.name();
        }
    }
    map.insert(QStringLiteral("categoryColor"), resolvedCategoryColor);

    const int severity = deadlineSeverity(record, QDate::currentDate());
    map.insert(QStringLiteral("deadlineLevel"), severity);
    map.insert(QStringLiteral("deadlineSeverity"), severityLabel(severity));

    return map;
}

QVariantList PlannerBackend::buildDayEvents(const QDate& date) const {
    QVariantList list;
    for (const auto& record : m_cachedEvents) {
        if (record.start.date() != date) {
            continue;
        }
        list.append(toVariant(record));
    }
    std::sort(list.begin(), list.end(), [](const QVariant& a, const QVariant& b) {
        const QVariantMap left = a.toMap();
        const QVariantMap right = b.toMap();
        if (left.value(QStringLiteral("allDay")).toBool() != right.value(QStringLiteral("allDay")).toBool()) {
            return right.value(QStringLiteral("allDay")).toBool();
        }
        return left.value(QStringLiteral("start")).toString() < right.value(QStringLiteral("start")).toString();
    });
    return list;
}

QVariantList PlannerBackend::buildRangeEvents(const QDate& start, const QDate& end) const {
    QVariantList list;
    for (const auto& record : m_cachedEvents) {
        const QDate date = record.start.date();
        if (date < start || date > end) {
            continue;
        }
        list.append(toVariant(record));
    }
    std::sort(list.begin(), list.end(), [](const QVariant& a, const QVariant& b) {
        const QVariantMap left = a.toMap();
        const QVariantMap right = b.toMap();
        return left.value(QStringLiteral("start")).toString() < right.value(QStringLiteral("start")).toString();
    });
    return list;
}

PlannerBackend::ViewMode PlannerBackend::modeFromString(const QString& mode) const {
    const QString normalized = mode.trimmed().toLower();
    if (normalized == QStringLiteral("week")) {
        return ViewMode::Week;
    }
    if (normalized == QStringLiteral("list")) {
        return ViewMode::List;
    }
    return ViewMode::Month;
}

QString PlannerBackend::modeToString(ViewMode mode) const {
    switch (mode) {
    case ViewMode::Week:
        return QStringLiteral("week");
    case ViewMode::List:
        return QStringLiteral("list");
    case ViewMode::Month:
    default:
        return QStringLiteral("month");
    }
}

void PlannerBackend::logEventLoad(int count) const {
    qInfo() << "[PlannerBackend] events loaded:" << count;
}

void PlannerBackend::notify(const QString& message) {
    emit toastRequested(message);
}

int PlannerBackend::deadlineSeverity(const EventRecord& record, const QDate& today) const {
    QDate targetDate;
    if (record.due.isValid()) {
        targetDate = record.due.date();
    } else if (record.start.isValid()) {
        targetDate = record.start.date();
    }

    if (!targetDate.isValid() || !today.isValid()) {
        return 0;
    }

    const int diff = today.daysTo(targetDate);
    if (diff < 0) {
        return 3;
    }
    if (diff == 0) {
        return 2;
    }
    if (diff <= 2) {
        return 1;
    }
    return 0;
}

QString PlannerBackend::severityLabel(int severity) const {
    switch (severity) {
    case 3:
        return QStringLiteral("overdue");
    case 2:
        return QStringLiteral("danger");
    case 1:
        return QStringLiteral("warn");
    default:
        return QStringLiteral("none");
    }
}

void PlannerBackend::rebuildUrgent(const QDate& today) {
    QVariantList urgent;
    for (const auto& record : m_cachedEvents) {
        const int severity = deadlineSeverity(record, today);
        if (severity <= 0) {
            continue;
        }
        QVariantMap map = toVariant(record);
        map.insert(QStringLiteral("deadlineLevel"), severity);
        map.insert(QStringLiteral("deadlineSeverity"), severityLabel(severity));
        urgent.append(map);
    }

    std::sort(urgent.begin(), urgent.end(), [](const QVariant& a, const QVariant& b) {
        const QVariantMap left = a.toMap();
        const QVariantMap right = b.toMap();
        const int leftSeverity = left.value(QStringLiteral("deadlineLevel")).toInt();
        const int rightSeverity = right.value(QStringLiteral("deadlineLevel")).toInt();
        if (leftSeverity != rightSeverity) {
            return leftSeverity > rightSeverity;
        }
        const QDateTime leftDue = QDateTime::fromString(left.value(QStringLiteral("due")).toString(), Qt::ISODate);
        const QDateTime rightDue = QDateTime::fromString(right.value(QStringLiteral("due")).toString(), Qt::ISODate);
        if (leftDue.isValid() && rightDue.isValid()) {
            return leftDue < rightDue;
        }
        return left.value(QStringLiteral("title")).toString() < right.value(QStringLiteral("title")).toString();
    });

    if (m_urgent != urgent) {
        m_urgent = urgent;
        emit urgentEventsChanged();
    }
}

void PlannerBackend::rebuildFocusState() {
    const bool previousActive = m_focusSession.value(QStringLiteral("active")).toBool();
    QVariantMap session;
    const bool active = m_focusRepository.hasActiveSession();
    if (active) {
        const QDateTime start = m_focusRepository.activeSessionStart();
        const QDateTime now = QDateTime::currentDateTime();
        const int elapsed = start.isValid() ? static_cast<int>(start.secsTo(now) / 60) : 0;
        const double progress = m_focusGoalMinutes > 0
                ? std::clamp(static_cast<double>(elapsed) / static_cast<double>(m_focusGoalMinutes), 0.0, 1.0)
                : 0.0;
        session.insert(QStringLiteral("active"), true);
        session.insert(QStringLiteral("start"), toIsoDateTime(start));
        session.insert(QStringLiteral("elapsedMinutes"), elapsed);
        session.insert(QStringLiteral("goalMinutes"), m_focusGoalMinutes);
        session.insert(QStringLiteral("progress"), progress);
        session.insert(QStringLiteral("remainingMinutes"), std::max(0, m_focusGoalMinutes - elapsed));
    } else {
        session.insert(QStringLiteral("active"), false);
        const QVector<FocusSession> sessions = m_focusRepository.sessions();
        if (!sessions.isEmpty()) {
            const FocusSession last = sessions.last();
            session.insert(QStringLiteral("lastStart"), toIsoDateTime(last.start()));
            session.insert(QStringLiteral("lastEnd"), toIsoDateTime(last.end()));
            session.insert(QStringLiteral("lastMinutes"), last.durationMinutes());
            session.insert(QStringLiteral("lastCompleted"), last.completed());
        }
        session.insert(QStringLiteral("goalMinutes"), m_focusGoalMinutes);
    }

    if (m_focusSession != session) {
        m_focusSession = session;
        emit focusSessionChanged();
    }

    const bool newActive = session.value(QStringLiteral("active")).toBool();
    if (newActive != previousActive) {
        emit focusSessionActiveChanged();
    }

    const QVector<FocusSession> allSessions = m_focusRepository.sessions();
    const QDate today = QDate::currentDate();
    const int days = 14;
    QMap<QDate, int> minutes;
    QSet<QDate> completedDays;
    for (const auto& item : allSessions) {
        if (!item.date().isValid()) {
            continue;
        }
        minutes[item.date()] += item.durationMinutes();
        if (item.completed()) {
            completedDays.insert(item.date());
        }
    }

    QVariantList history;
    const QDate start = today.addDays(-(days - 1));
    for (int i = 0; i < days; ++i) {
        const QDate date = start.addDays(i);
        QVariantMap map;
        map.insert(QStringLiteral("date"), toIsoDate(date));
        map.insert(QStringLiteral("minutes"), minutes.value(date));
        map.insert(QStringLiteral("completed"), completedDays.contains(date));
        history.append(map);
    }

    if (m_focusHistory != history) {
        m_focusHistory = history;
        emit focusHistoryChanged();
    }

    const int streak = m_focusRepository.currentStreak(today);
    if (streak != m_focusStreak) {
        m_focusStreak = streak;
        emit focusStreakChanged();
    }
}

void PlannerBackend::rebuildPomodoroState() {
    QVariantMap state;
    state.insert(QStringLiteral("running"), m_pomodoro.isRunning());
    state.insert(QStringLiteral("remainingSeconds"), m_pomodoro.remainingSeconds());
    state.insert(QStringLiteral("completedCycles"), m_pomodoro.completedCycles());
    state.insert(QStringLiteral("focusMinutes"), m_pomodoro.focusMinutes());
    state.insert(QStringLiteral("breakMinutes"), m_pomodoro.breakMinutes());
    state.insert(QStringLiteral("longBreakMinutes"), m_pomodoro.longBreakMinutes());
    state.insert(QStringLiteral("cyclesBeforeLongBreak"), m_pomodoro.cyclesBeforeLongBreak());

    QString phaseId;
    QString phaseLabel;
    switch (m_pomodoro.phase()) {
    case PomodoroTimer::Phase::Focus:
        phaseId = QStringLiteral("focus");
        phaseLabel = tr("Fokus");
        break;
    case PomodoroTimer::Phase::ShortBreak:
        phaseId = QStringLiteral("short-break");
        phaseLabel = tr("Kurzpause");
        break;
    case PomodoroTimer::Phase::LongBreak:
        phaseId = QStringLiteral("long-break");
        phaseLabel = tr("Langpause");
        break;
    case PomodoroTimer::Phase::Idle:
    default:
        phaseId = QStringLiteral("idle");
        phaseLabel = tr("Bereit");
        break;
    }

    const int remainingSeconds = m_pomodoro.remainingSeconds();
    const int minutes = remainingSeconds / 60;
    const int seconds = remainingSeconds % 60;
    state.insert(QStringLiteral("phase"), phaseId);
    state.insert(QStringLiteral("phaseLabel"), phaseLabel);
    state.insert(QStringLiteral("remainingMinutes"), minutes);
    state.insert(QStringLiteral("remainingDisplay"), QStringLiteral("%1:%2")
                                                     .arg(minutes, 2, 10, QLatin1Char('0'))
                                                     .arg(seconds, 2, 10, QLatin1Char('0')));

    if (state != m_pomodoroState) {
        m_pomodoroState = state;
        emit pomodoroChanged();
    }
}

QVariantList PlannerBackend::listCategories() const {
    return m_categories;
}

bool PlannerBackend::addCategory(const QString& id, const QString& name, const QString& color) {
    if (id.isEmpty() || name.isEmpty()) {
        notify(tr("ID und Name sind erforderlich"));
        return false;
    }
    
    Category cat;
    cat.id = id;
    cat.name = name;
    cat.color = QColor(color);
    
    if (!m_categoryRepository.insert(cat)) {
        notify(tr("Kategorie konnte nicht hinzugefügt werden"));
        return false;
    }
    
    rebuildCategories();
    notify(tr("Kategorie \"%1\" hinzugefügt").arg(name));
    return true;
}

bool PlannerBackend::updateCategory(const QString& id, const QString& name, const QString& color) {
    if (id.isEmpty() || name.isEmpty()) {
        notify(tr("ID und Name sind erforderlich"));
        return false;
    }
    
    Category cat;
    cat.id = id;
    cat.name = name;
    cat.color = QColor(color);
    
    if (!m_categoryRepository.update(cat)) {
        notify(tr("Kategorie konnte nicht aktualisiert werden"));
        return false;
    }
    
    rebuildCategories();
    notify(tr("Kategorie \"%1\" aktualisiert").arg(name));
    return true;
}

bool PlannerBackend::removeCategory(const QString& id) {
    if (id.isEmpty()) {
        return false;
    }
    
    if (!m_categoryRepository.remove(id)) {
        notify(tr("Kategorie konnte nicht entfernt werden"));
        return false;
    }
    
    rebuildCategories();
    notify(tr("Kategorie entfernt"));
    return true;
}

bool PlannerBackend::setEntryCategory(const QString& entryId, const QString& categoryId) {
    if (entryId.isEmpty()) {
        return false;
    }
    
    // Find the event
    EventRecord record;
    bool found = false;
    for (const auto& ev : m_cachedEvents) {
        if (ev.id == entryId) {
            record = ev;
            found = true;
            break;
        }
    }
    
    if (!found) {
        notify(tr("Eintrag nicht gefunden"));
        return false;
    }
    
    record.categoryId = categoryId;
    
    if (!m_repository.update(record)) {
        notify(tr("Kategorie konnte nicht zugewiesen werden"));
        return false;
    }
    
    reloadEvents();
    rebuildSidebar();
    
    if (categoryId.isEmpty()) {
        notify(tr("Kategorie entfernt"));
    } else {
        Category cat = m_categoryRepository.findById(categoryId);
        notify(tr("Kategorie \"%1\" zugewiesen").arg(cat.name));
    }
    
    return true;
}

bool PlannerBackend::moveEntry(const QString& entryId, const QString& newStartIso, const QString& newEndIso) {
    if (entryId.isEmpty() || newStartIso.isEmpty() || newEndIso.isEmpty()) {
        notify(tr("Ungültige Parameter für Verschieben"));
        return false;
    }
    
    // Find the event
    EventRecord record;
    bool found = false;
    for (const auto& ev : m_cachedEvents) {
        if (ev.id == entryId) {
            record = ev;
            found = true;
            break;
        }
    }
    
    if (!found) {
        notify(tr("Eintrag nicht gefunden"));
        return false;
    }
    
    // Save old values for undo
    const QString oldStartIso = toIsoDateTime(record.start);
    const QString oldEndIso = toIsoDateTime(record.end);
    
    // Parse new date/time
    QDateTime newStart = fromIsoDateTime(newStartIso);
    QDateTime newEnd = fromIsoDateTime(newEndIso);
    
    if (!newStart.isValid() || !newEnd.isValid()) {
        qWarning() << "[moveEntry] Invalid dates:" << newStartIso << newEndIso;
        notify(tr("Ungültiges Datum/Uhrzeit"));
        return false;
    }
    
    // Validate that end is after start
    if (newEnd <= newStart) {
        qWarning() << "[moveEntry] End time must be after start time";
        notify(tr("Endzeitpunkt muss nach Startzeitpunkt liegen"));
        return false;
    }
    
    // Update the record
    record.start = newStart;
    record.end = newEnd;
    
    // Persist the change
    if (!m_repository.update(record)) {
        notify(tr("Verschieben fehlgeschlagen"));
        return false;
    }
    
    // Reload and notify
    reloadEvents();
    rebuildSidebar();
    
    // Emit signal for undo support (ToastHost will show the undo snackbar)
    emit entryMoved(entryId, oldStartIso, oldEndIso);

    return true;
}

bool PlannerBackend::focusSessionActive() const {
    return m_focusRepository.hasActiveSession();
}

void PlannerBackend::startFocusSession(int minutes) {
    if (minutes > 0) {
        m_focusGoalMinutes = minutes;
    }
    if (!m_focusRepository.startSession(QDateTime::currentDateTime())) {
        notify(tr("Fokus-Sitzung läuft bereits"));
        return;
    }
    rebuildFocusState();
}

void PlannerBackend::stopFocusSession(bool completed) {
    const FocusSession session = m_focusRepository.finishSession(QDateTime::currentDateTime(), completed);
    if (!session.isValid()) {
        notify(tr("Keine laufende Fokus-Sitzung"));
        return;
    }
    if (completed) {
        notify(tr("Fokus-Sitzung abgeschlossen: %1 Minuten").arg(session.durationMinutes()));
    } else {
        notify(tr("Fokus-Sitzung beendet"));
    }
    rebuildFocusState();
}

void PlannerBackend::cancelFocusSession() {
    if (!m_focusRepository.hasActiveSession()) {
        return;
    }
    m_focusRepository.cancelActiveSession();
    rebuildFocusState();
    notify(tr("Fokus-Sitzung verworfen"));
}

void PlannerBackend::refreshFocusHistory() {
    rebuildFocusState();
}

void PlannerBackend::startPomodoro() {
    m_pomodoro.start();
    rebuildPomodoroState();
}

void PlannerBackend::stopPomodoro() {
    m_pomodoro.stop();
    rebuildPomodoroState();
}

void PlannerBackend::skipPomodoroPhase() {
    m_pomodoro.skipPhase();
    rebuildPomodoroState();
}

bool PlannerBackend::exportWeekPdf(const QString& filePath, const QString& weekStartIso) {
    if (filePath.trimmed().isEmpty()) {
        notify(tr("Kein Speicherort angegeben"));
        return false;
    }

    QDate start = fromIsoDate(weekStartIso);
    if (!start.isValid()) {
        start = m_selectedDate;
    }
    if (!start.isValid()) {
        start = QDate::currentDate();
    }

    const int startOfWeek = weekStartDay(m_state.weekStart());
    while (start.dayOfWeek() != startOfWeek) {
        start = start.addDays(-1);
    }

    const bool ok = m_exporter.exportWeek(m_cachedEvents, start, filePath);
    if (ok) {
        notify(tr("PDF exportiert"));
    } else {
        notify(tr("Export fehlgeschlagen"));
    }
    return ok;
}

bool PlannerBackend::exportMonthPdf(const QString& filePath, const QString& monthIso) {
    if (filePath.trimmed().isEmpty()) {
        notify(tr("Kein Speicherort angegeben"));
        return false;
    }

    QDate anchor = fromIsoDate(monthIso);
    if (!anchor.isValid()) {
        anchor = m_selectedDate;
    }
    if (!anchor.isValid()) {
        anchor = QDate::currentDate();
    }

    const bool ok = m_exporter.exportMonth(m_cachedEvents, anchor.year(), anchor.month(), filePath);
    if (ok) {
        notify(tr("Monats-PDF exportiert"));
    } else {
        notify(tr("Export fehlgeschlagen"));
    }
    return ok;
}

void PlannerBackend::rebuildCategories() {
    QVector<Category> cats = m_categoryRepository.loadAll();
    QVariantList list;

    for (const auto& cat : cats) {
        QVariantMap map;
        map.insert(QStringLiteral("id"), cat.id);
        map.insert(QStringLiteral("name"), cat.name);
        map.insert(QStringLiteral("color"), cat.color.name());
        list.append(map);
    }
    
    if (m_categories != list) {
        m_categories = list;
        emit categoriesChanged();
    }
}

// Spaced Repetition Methods

QString PlannerBackend::addReview(const QString& subjectId, const QString& topic) {
    QString reviewId = m_reviewService.addReview(subjectId, topic);
    rebuildDueReviews();
    notify(tr("Review hinzugefügt"));
    return reviewId;
}

bool PlannerBackend::recordReview(const QString& reviewId, int quality) {
    if (!m_reviewService.recordReview(reviewId, quality)) {
        notify(tr("Review konnte nicht gespeichert werden"));
        return false;
    }
    rebuildDueReviews();
    notify(tr("Review aufgezeichnet"));
    return true;
}

bool PlannerBackend::removeReview(const QString& reviewId) {
    if (!m_reviewService.removeReview(reviewId)) {
        return false;
    }
    rebuildDueReviews();
    notify(tr("Review entfernt"));
    return true;
}

QVariantList PlannerBackend::getReviewsForSubject(const QString& subjectId) const {
    QList<Review> reviews = m_reviewService.reviewsForSubject(subjectId);
    QVariantList result;
    
    for (const auto& review : reviews) {
        QVariantMap map;
        map["id"] = review.id;
        map["subjectId"] = review.subjectId;
        map["topic"] = review.topic;
        map["lastReviewDate"] = review.lastReviewDate.toString(Qt::ISODate);
        map["nextReviewDate"] = review.nextReviewDate.toString(Qt::ISODate);
        map["repetitionNumber"] = review.repetitionNumber;
        map["easeFactor"] = review.easeFactor;
        map["intervalDays"] = review.intervalDays;
        map["quality"] = review.quality;
        map["isDue"] = review.nextReviewDate <= QDate::currentDate();
        result.append(map);
    }
    
    return result;
}

QVariantList PlannerBackend::getAllReviews() const {
    QList<Review> reviews = m_reviewService.reviews();
    QVariantList result;
    
    for (const auto& review : reviews) {
        QVariantMap map;
        map["id"] = review.id;
        map["subjectId"] = review.subjectId;
        map["topic"] = review.topic;
        map["lastReviewDate"] = review.lastReviewDate.toString(Qt::ISODate);
        map["nextReviewDate"] = review.nextReviewDate.toString(Qt::ISODate);
        map["repetitionNumber"] = review.repetitionNumber;
        map["easeFactor"] = review.easeFactor;
        map["intervalDays"] = review.intervalDays;
        map["quality"] = review.quality;
        map["isDue"] = review.nextReviewDate <= QDate::currentDate();
        result.append(map);
    }
    
    return result;
}

QVariantList PlannerBackend::getReviewsOnDate(const QString& isoDate) const {
    QDate date = QDate::fromString(isoDate, Qt::ISODate);
    if (!date.isValid()) {
        return QVariantList();
    }
    
    QList<Review> reviews = m_reviewService.reviewsOnDate(date);
    QVariantList result;
    
    for (const auto& review : reviews) {
        QVariantMap map;
        map["id"] = review.id;
        map["subjectId"] = review.subjectId;
        map["topic"] = review.topic;
        map["lastReviewDate"] = review.lastReviewDate.toString(Qt::ISODate);
        map["nextReviewDate"] = review.nextReviewDate.toString(Qt::ISODate);
        map["repetitionNumber"] = review.repetitionNumber;
        map["easeFactor"] = review.easeFactor;
        map["intervalDays"] = review.intervalDays;
        map["quality"] = review.quality;
        result.append(map);
    }
    
    return result;
}

void PlannerBackend::setReviewInitialInterval(int days) {
    m_reviewService.setInitialInterval(days);
}

void PlannerBackend::refreshReviews() {
    rebuildDueReviews();
}

void PlannerBackend::rebuildDueReviews() {
    QList<Review> due = m_reviewService.dueReviews();
    QVariantList list;
    
    for (const auto& review : due) {
        QVariantMap map;
        map["id"] = review.id;
        map["subjectId"] = review.subjectId;
        map["topic"] = review.topic;
        map["lastReviewDate"] = review.lastReviewDate.toString(Qt::ISODate);
        map["nextReviewDate"] = review.nextReviewDate.toString(Qt::ISODate);
        map["repetitionNumber"] = review.repetitionNumber;
        map["easeFactor"] = review.easeFactor;
        map["intervalDays"] = review.intervalDays;
        map["quality"] = review.quality;
        list.append(map);
    }
    
    if (m_dueReviews != list) {
        m_dueReviews = list;
        emit dueReviewsChanged();
    }
}
