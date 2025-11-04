#include "ScheduleExporter.h"

#include <QDateTime>
#include <QFileInfo>
#include <QPainter>
#include <QPdfWriter>
#include <QMarginsF>
#include <QLocale>
#include <QObject>
#include <QFont>
#include <QtDebug>

#include <algorithm>

namespace {
QString formatDate(const QDate& date) {
    return QLocale(QLocale::German, QLocale::Germany).toString(date, QStringLiteral("ddd, dd.MM."));
}

QString formatTime(const QDateTime& dateTime) {
    if (!dateTime.isValid()) {
        return QString();
    }
    return QLocale(QLocale::German, QLocale::Germany).toString(dateTime.time(), QStringLiteral("HH:mm"));
}

struct DayBucket {
    QDate date;
    QVector<EventRecord> events;
};

QVector<DayBucket> groupByDay(const QVector<EventRecord>& events, const QDate& start, const QDate& end) {
    QVector<DayBucket> buckets;
    QDate cursor = start;
    while (cursor <= end) {
        DayBucket bucket;
        bucket.date = cursor;
        buckets.append(bucket);
        cursor = cursor.addDays(1);
    }

    auto findBucket = [&buckets](const QDate& date) -> DayBucket* {
        for (auto& bucket : buckets) {
            if (bucket.date == date) {
                return &bucket;
            }
        }
        return nullptr;
    };

    for (const auto& event : events) {
        const QDate day = event.start.date();
        if (day < start || day > end) {
            continue;
        }
        if (DayBucket* bucket = findBucket(day)) {
            bucket->events.append(event);
        }
    }

    for (auto& bucket : buckets) {
        std::sort(bucket.events.begin(), bucket.events.end(), [](const EventRecord& a, const EventRecord& b) {
            if (a.start == b.start) {
                return a.title.toLower() < b.title.toLower();
            }
            return a.start < b.start;
        });
    }

    return buckets;
}
}

bool ScheduleExporter::exportRange(const QVector<EventRecord>& events, const QDate& start, const QDate& end, const QString& filePath) const {
    if (!start.isValid() || !end.isValid() || start > end) {
        qWarning() << "[ScheduleExporter] Invalid export range" << start << end;
        return false;
    }

    QPdfWriter writer(filePath);
    writer.setTitle(QStringLiteral("Noah Planner Zeitplan"));
    writer.setCreator(QStringLiteral("Noah Planner"));
    writer.setPageMargins(QMarginsF(18, 18, 18, 18));

    QPainter painter(&writer);
    if (!painter.isActive()) {
        qWarning() << "[ScheduleExporter] Cannot create painter for" << filePath;
        return false;
    }

    QFont headingFont(QStringLiteral("Inter"), 14, QFont::Bold);
    QFont subFont(QStringLiteral("Inter"), 10, QFont::Bold);
    QFont bodyFont(QStringLiteral("Inter"), 10);

    const QVector<DayBucket> buckets = groupByDay(events, start, end);

    const QString headerTitle = QStringLiteral("Planer: %1 – %2").arg(formatDate(start)).arg(formatDate(end));
    painter.setFont(headingFont);
    painter.drawText(QPointF(0, 20), headerTitle);

    int yOffset = 40;
    const int lineHeight = 18;
    const int columnGap = 260;
    int column = 0;

    for (const auto& bucket : buckets) {
        if (column >= 2) {
            writer.newPage();
            column = 0;
            yOffset = 40;
            painter.setFont(headingFont);
            painter.drawText(QPointF(0, 20), headerTitle);
        }

        const int xBase = column * columnGap;
        painter.setFont(subFont);
        painter.drawText(QPointF(xBase, yOffset), formatDate(bucket.date));
        yOffset += lineHeight;

        painter.setFont(bodyFont);
        if (bucket.events.isEmpty()) {
            painter.drawText(QPointF(xBase, yOffset), QObject::tr("Keine Einträge"));
            yOffset += lineHeight;
        } else {
            for (const auto& event : bucket.events) {
                const QString time = event.allDay ? QObject::tr("Ganztägig")
                                                  : QStringLiteral("%1 - %2").arg(formatTime(event.start)).arg(formatTime(event.end));
                const QString text = QStringLiteral("• %1 (%2)").arg(event.title, time);
                painter.drawText(QPointF(xBase, yOffset), text);
                yOffset += lineHeight;
            }
        }

        yOffset += lineHeight;
        column += 1;

        if (yOffset > writer.height() - 80) {
            writer.newPage();
            column = 0;
            yOffset = 40;
            painter.setFont(headingFont);
            painter.drawText(QPointF(0, 20), headerTitle);
        }
    }

    painter.end();
    return true;
}

bool ScheduleExporter::exportWeek(const QVector<EventRecord>& events, const QDate& weekStart, const QString& filePath) const {
    if (!weekStart.isValid()) {
        return false;
    }
    return exportRange(events, weekStart, weekStart.addDays(6), filePath);
}

bool ScheduleExporter::exportMonth(const QVector<EventRecord>& events, int year, int month, const QString& filePath) const {
    if (year < 1970 || year > 2999 || month < 1 || month > 12) {
        return false;
    }
    const QDate start(year, month, 1);
    const QDate end(year, month, start.daysInMonth());
    return exportRange(events, start, end, filePath);
}
