#include "PlannerBackend.h"
#include "core/ScheduleExporter.h"

#include <QCoreApplication>
#include <QDateTime>
#include <QDir>
#include <QLocale>
#include <QMap>
#include <QStandardPaths>
#include <QTimeZone>

#include <algorithm>

namespace {
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
    reloadEvents();
    rebuildCommands();
    rebuildCategories();
    rebuildSidebar();

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
    add(QStringLiteral("export-week"), tr("Woche als PDF exportieren"), tr("Aktuell angezeigte Woche exportieren"));
    add(QStringLiteral("export-month"), tr("Monat als PDF exportieren"), tr("Aktuell angezeigten Monat exportieren"));
    add(QStringLiteral("open-settings"), tr("Einstellungen öffnen"), QString());

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
    
    // Add category color if category is assigned
    if (!record.categoryId.isEmpty()) {
        Category cat = m_categoryRepository.findById(record.categoryId);
        if (cat.isValid()) {
            map.insert(QStringLiteral("categoryColor"), cat.color.name());
        }
    }
    
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

bool PlannerBackend::exportWeekPdf(const QString& weekStartIso, const QString& filePath)
{
    QDate weekStart = fromIsoDate(weekStartIso);
    if (!weekStart.isValid()) {
        m_lastExportError = "Invalid week start date";
        notify("Export fehlgeschlagen: Ungültiges Datum");
        return false;
    }

    ScheduleExporter exporter;
    bool success = exporter.exportWeek(weekStart, filePath, &m_repository, &m_categoryRepository);
    
    if (success) {
        m_lastExportError.clear();
        notify(QString("Wochenplan exportiert: %1").arg(filePath));
    } else {
        m_lastExportError = exporter.lastError();
        notify(QString("Export fehlgeschlagen: %1").arg(m_lastExportError));
    }

    return success;
}

bool PlannerBackend::exportMonthPdf(const QString& monthIso, const QString& filePath)
{
    QDate month = fromIsoDate(monthIso);
    if (!month.isValid()) {
        m_lastExportError = "Invalid month date";
        notify("Export fehlgeschlagen: Ungültiges Datum");
        return false;
    }

    ScheduleExporter exporter;
    bool success = exporter.exportMonth(month, filePath, &m_repository, &m_categoryRepository);
    
    if (success) {
        m_lastExportError.clear();
        notify(QString("Monatsplan exportiert: %1").arg(filePath));
    } else {
        m_lastExportError = exporter.lastError();
        notify(QString("Export fehlgeschlagen: %1").arg(m_lastExportError));
    }

    return success;
}

QString PlannerBackend::lastExportError() const
{
    return m_lastExportError;
}
