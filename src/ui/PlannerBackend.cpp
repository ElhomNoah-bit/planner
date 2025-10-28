#include "PlannerBackend.h"

#include <QDateTime>
#include <QModelIndex>
#include <QDebug>

#include <algorithm>

namespace {
QString toIso(const QDate& date) {
    return date.toString(Qt::ISODate);
}

QDate fromIso(const QString& iso) {
    return QDate::fromString(iso, Qt::ISODate);
}

QString modeToString(PlannerBackend::ViewMode mode) {
    switch (mode) {
    case PlannerBackend::Week:
        return QStringLiteral("week");
    case PlannerBackend::List:
        return QStringLiteral("list");
    case PlannerBackend::Month:
    default:
        return QStringLiteral("month");
    }
}

PlannerBackend::ViewMode stringToMode(QString value) {
    const QString normalized = value.trimmed().toLower();
    if (normalized == QStringLiteral("week")) return PlannerBackend::Week;
    if (normalized == QStringLiteral("list")) return PlannerBackend::List;
    return PlannerBackend::Month;
}
}

PlannerBackend::PlannerBackend(QObject* parent)
    : QObject(parent) {
    m_subjects = m_planner.subjects();
    connect(&m_planner, &PlannerService::dataChanged, this, [this]() {
        loadSubjects();
        reloadExams();
        refreshDayTasks(m_selectedDate);
    });

    m_taskProxy.setSourceModel(&m_taskModel);
    updateProxyFilters();

    const QDate today = QDate::currentDate();
    m_selectedDate = today;
    refreshDayTasks(today);
    reloadExams();

    emit subjectsChanged();
    emit selectedDateChanged();
    emit onlyOpenChanged();
    emit filtersChanged();
    emit viewModeChanged();
    emit darkThemeChanged();
}

bool PlannerBackend::darkTheme() const {
    return m_state.darkTheme();
}

void PlannerBackend::setDarkTheme(bool dark) {
    if (!m_state.setDarkTheme(dark)) return;
    m_state.save();
    emit darkThemeChanged();
}

TaskFilterProxy* PlannerBackend::todayTasks() {
    return &m_taskProxy;
}

ExamModel* PlannerBackend::exams() {
    return &m_examModel;
}

QVariantList PlannerBackend::subjects() const {
    QVariantList list;
    const QSet<QString> active = m_state.subjectFilter();
    for (const auto& subject : m_subjects) {
        QVariantMap entry;
        entry.insert("id", subject.id);
        entry.insert("name", subject.name);
        entry.insert("color", subject.color);
        entry.insert("active", active.contains(subject.id));
        list.append(entry);
    }
    return list;
}

QString PlannerBackend::selectedDateIso() const {
    return toIso(m_selectedDate);
}

void PlannerBackend::selectDate(const QDate& date) {
    if (!date.isValid()) return;
    if (m_selectedDate == date) return;
    m_selectedDate = date;
    refreshDayTasks(m_selectedDate);
    emit selectedDateChanged();
}

QString PlannerBackend::viewModeString() const {
    return modeToString(m_viewMode);
}

void PlannerBackend::setViewMode(ViewMode mode) {
    switch (mode) {
    case Month:
    case Week:
    case List:
        break;
    default:
        mode = Month;
        break;
    }
    if (m_viewMode == mode) return;
    m_viewMode = mode;
    emit viewModeChanged();
    qDebug() << "[PlannerBackend] viewMode ->" << modeToString(m_viewMode);
}

void PlannerBackend::setViewModeString(const QString& mode) {
    setViewMode(stringToMode(mode));
}

void PlannerBackend::setOnlyOpen(bool onlyOpen) {
    if (!m_state.setOnlyOpen(onlyOpen)) return;
    m_state.save();
    updateProxyFilters();
    refreshDayTasks(m_selectedDate);
    emit onlyOpenChanged();
    emit filtersChanged();
    qDebug() << "[PlannerBackend] onlyOpen ->" << m_state.onlyOpen();
}

void PlannerBackend::setSearchQuery(const QString& query) {
    const QString trimmed = query.trimmed();
    if (!m_state.setSearchQuery(trimmed)) return;
    m_state.save();
    updateProxyFilters();
    refreshDayTasks(m_selectedDate);
    emit filtersChanged();
}

void PlannerBackend::setLanguage(const QString& language) {
    if (!m_state.setLanguage(language)) return;
    m_state.save();
    emit settingsChanged();
}

void PlannerBackend::setWeekStart(const QString& weekStart) {
    if (!m_state.setWeekStart(weekStart)) return;
    m_state.save();
    emit settingsChanged();
}

void PlannerBackend::setShowWeekNumbers(bool enabled) {
    if (!m_state.setWeekNumbers(enabled)) return;
    m_state.save();
    emit settingsChanged();
}

void PlannerBackend::selectDateIso(const QString& isoDate) {
    selectDate(fromIso(isoDate));
}

void PlannerBackend::refreshToday() {
    selectDate(QDate::currentDate());
}

void PlannerBackend::toggleTaskDone(int proxyRow, bool done) {
    if (proxyRow < 0) return;
    const QModelIndex proxyIndex = m_taskProxy.index(proxyRow, 0);
    if (!proxyIndex.isValid()) return;
    const QModelIndex sourceIndex = m_taskProxy.mapToSource(proxyIndex);
    if (!sourceIndex.isValid()) return;

    const int planIndex = sourceIndex.data(TaskModel::PlanIndexRole).toInt();
    m_planner.setDone(m_selectedDate, planIndex, done);
    m_taskModel.setDone(sourceIndex.row(), done);
    refreshDayTasks(m_selectedDate);
    notify(done ? tr("Aufgabe erledigt") : tr("Als offen markiert"));
}

QVariantList PlannerBackend::dayEvents(const QString& isoDate) const {
    const QDate date = fromIso(isoDate);
    if (!date.isValid()) return {};
    const QVector<Task> tasks = applyFilters(m_planner.generateDay(date));
    return serializeTasks(tasks);
}

QVariantMap PlannerBackend::daySummary(const QString& isoDate) const {
    const QDate date = fromIso(isoDate);
    QVariantMap out;
    if (!date.isValid()) return out;

    const QVector<Task> tasks = applyFilters(m_planner.generateDay(date));
    const int total = tasks.size();
    const int done = std::count_if(tasks.begin(), tasks.end(), [](const Task& task) { return task.done; });
    out.insert("total", total);
    out.insert("done", done);
    out.insert("remaining", std::max(0, total - done));
    out.insert("progress", total == 0 ? 0.0 : static_cast<double>(done) / static_cast<double>(total));
    return out;
}

void PlannerBackend::toggleSubject(const QString& subjectId) {
    QSet<QString> current = m_state.subjectFilter();
    if (current.contains(subjectId)) {
        current.remove(subjectId);
    } else {
        current.insert(subjectId);
    }
    if (!m_state.setSubjectFilter(current)) return;
    m_state.save();
    updateProxyFilters();
    refreshDayTasks(m_selectedDate);
    emit subjectsChanged();
    emit filtersChanged();
}

void PlannerBackend::setSubjectFilter(const QStringList& subjectIds) {
    QSet<QString> set(subjectIds.constBegin(), subjectIds.constEnd());
    if (!m_state.setSubjectFilter(set)) return;
    m_state.save();
    updateProxyFilters();
    refreshDayTasks(m_selectedDate);
    emit subjectsChanged();
    emit filtersChanged();
}

QStringList PlannerBackend::subjectFilter() const {
    return QStringList(m_state.subjectFilter().constBegin(), m_state.subjectFilter().constEnd());
}

QVariantMap PlannerBackend::subjectById(const QString& id) const {
    QVariantMap out;
    auto findSubject = [&]() -> Subject {
        for (const auto& subject : m_subjects) {
            if (subject.id == id) return subject;
        }
        Subject fallback;
        fallback.id = id;
        fallback.name = id;
        fallback.color = QColor("#4C4C4C");
        return fallback;
    };
    const Subject subject = findSubject();
    out.insert("id", subject.id);
    out.insert("name", subject.name);
    out.insert("color", subject.color);
    return out;
}

QColor PlannerBackend::subjectColor(const QString& id) const {
    for (const auto& subject : m_subjects) {
        if (subject.id == id) return subject.color;
    }
    return QColor("#4C4C4C");
}

QVariantList PlannerBackend::weekEvents(const QString& weekStartIso) const {
    QVariantList events;
    const QDate start = fromIso(weekStartIso);
    if (!start.isValid()) return events;

    const QDate weekStart = start.addDays(-(start.dayOfWeek() - Qt::Monday));
    for (int dayOffset = 0; dayOffset < 7; ++dayOffset) {
        const QDate day = weekStart.addDays(dayOffset);
        const QVector<Task> tasks = applyFilters(m_planner.generateDay(day));
        int minutesCursor = 8 * 60;
        for (const auto& task : tasks) {
            QVariantMap item;
            item.insert("iso", toIso(day));
            item.insert("dayIndex", dayOffset);
            item.insert("startMinutes", minutesCursor);
            item.insert("duration", task.durationMinutes);
            item.insert("title", task.title);
            item.insert("subjectId", task.subjectId);
            item.insert("color", task.color);
            item.insert("done", task.done);
            item.insert("planIndex", task.planIndex);
            events.append(item);
            minutesCursor += task.durationMinutes + 10;
        }
    }
    return events;
}

QVariantList PlannerBackend::listBuckets() const {
    QVariantList buckets;
    const QDate today = QDate::currentDate();

    struct Bucket {
        QString key;
        QString label;
        QDate start;
        QDate end;
    };

    const QList<Bucket> defs = {
        {"today", tr("Heute"), today, today},
        {"tomorrow", tr("Morgen"), today.addDays(1), today.addDays(1)},
        {"week", tr("Diese Woche"), today.addDays(2), today.addDays(6)},
        {"later", tr("Später"), today.addDays(7), today.addDays(30)}
    };

    for (const auto& def : defs) {
        QVariantMap bucket;
        bucket.insert("key", def.key);
        bucket.insert("label", def.label);

        QVariantList items;
        for (QDate d = def.start; d <= def.end; d = d.addDays(1)) {
            const QVector<Task> tasks = applyFilters(m_planner.generateDay(d));
            for (const auto& task : tasks) {
                QVariantMap item;
                item.insert("iso", toIso(d));
                item.insert("title", task.title);
                item.insert("goal", task.goal);
                item.insert("subjectId", task.subjectId);
                item.insert("color", task.color);
                item.insert("done", task.done);
                item.insert("duration", task.durationMinutes);
                item.insert("planIndex", task.planIndex);
                items.append(item);
            }
        }
        bucket.insert("items", items);
        buckets.append(bucket);
    }

    return buckets;
}

void PlannerBackend::quickAdd(const QString& input) {
    const QString trimmed = input.trimmed();
    if (trimmed.isEmpty()) return;

    // Placeholder implementation until task authoring is connected to the core planner.
    notify(tr("Hinzugefügt"));
}

void PlannerBackend::showToast(const QString& message) {
    if (message.trimmed().isEmpty()) return;
    notify(message);
}

void PlannerBackend::loadSubjects() {
    m_subjects = m_planner.subjects();
    emit subjectsChanged();
}

void PlannerBackend::refreshDayTasks(const QDate& date) {
    const QVector<Task> tasks = filteredTasks(m_planner.generateDay(date));
    m_taskModel.replaceAll(tasks);
    m_taskProxy.invalidate();
    emit tasksChanged();
}

QVector<Task> PlannerBackend::filteredTasks(const QVector<Task>& tasks) const {
    QVector<Task> result;
    result.reserve(tasks.size());
    for (const auto& task : tasks) {
        if (!m_state.subjectFilter().isEmpty() && !m_state.subjectFilter().contains(task.subjectId)) {
            continue;
        }
        if (m_state.onlyOpen() && task.done) {
            continue;
        }
        if (!m_state.searchQuery().isEmpty()) {
            const QString query = m_state.searchQuery();
            if (!task.title.contains(query, Qt::CaseInsensitive) && !task.goal.contains(query, Qt::CaseInsensitive)) {
                continue;
            }
        }
        result.append(task);
    }
    return result;
}

QVector<Task> PlannerBackend::applyFilters(const QVector<Task>& tasks) const {
    return filteredTasks(tasks);
}

QVariantList PlannerBackend::serializeTasks(const QVector<Task>& tasks) const {
    QVariantList out;
    for (const auto& task : tasks) {
        QVariantMap item;
        item.insert("id", task.id);
        item.insert("title", task.title);
        item.insert("goal", task.goal);
        item.insert("subjectId", task.subjectId);
        item.insert("color", task.color);
        item.insert("done", task.done);
        item.insert("duration", task.durationMinutes);
        item.insert("planIndex", task.planIndex);
        out.append(item);
    }
    return out;
}

void PlannerBackend::reloadExams() {
    QVector<Exam> data = QVector<Exam>::fromList(m_planner.exams());
    std::sort(data.begin(), data.end(), [](const Exam& a, const Exam& b) {
        return a.date < b.date;
    });
    m_examModel.replaceAll(data);
    emit examsChanged();
}

void PlannerBackend::updateProxyFilters() {
    m_taskProxy.setSubjectFilter(m_state.subjectFilter());
    m_taskProxy.setOnlyOpen(m_state.onlyOpen());
    m_taskProxy.setSearchQuery(m_state.searchQuery());
}

void PlannerBackend::notify(const QString& message) {
    emit toastRequested(message);
}
