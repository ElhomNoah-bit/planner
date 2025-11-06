#include "QuickAddParser.h"
#include "Priority.h"

#include <QDateTime>
#include <QMap>
#include <QTimeZone>
#include <QVector>

#include <algorithm>

namespace {
QString simplifiedCopy(const QString& input) {
    QString normalized = input;
    normalized.replace('\n', ' ');
    normalized.replace('\t', ' ');
    normalized = normalized.simplified();
    return normalized;
}

QString lowerTrimmed(const QString& value) {
    return value.trimmed().toLower();
}
}

QuickAddResult QuickAddParser::parse(const QString& input, const QDateTime& reference) const {
    QuickAddResult result;
    QString working = simplifiedCopy(input);
    if (working.isEmpty()) {
        result.error = QStringLiteral("empty input");
        return result;
    }

    EventRecord record;
    record.isDone = false;

    record.tags = extractTags(working);
    record.location = extractLocation(working);
    record.priority = extractPriority(working);

    const QDate referenceDate = reference.date();
    const auto dateExtraction = extractDate(working, referenceDate);
    QDate targetDate = dateExtraction.second ? dateExtraction.first : referenceDate;

    const auto timeExtraction = extractTime(working);
    const bool hasTime = timeExtraction.second;
    QTime startTime;
    QTime endTime;
    if (hasTime) {
        startTime = timeExtraction.first.first;
        endTime = timeExtraction.first.second;
    }

    const int durationMinutes = extractDurationMinutes(working);

    working = working.simplified();
    record.title = working.trimmed();

    if (record.title.isEmpty()) {
        result.error = QStringLiteral("missing title");
        return result;
    }

    if (!hasTime && durationMinutes <= 0) {
        record.allDay = true;
        startTime = QTime(0, 0);
        endTime = QTime(23, 59);
    } else {
        record.allDay = false;
        if (!startTime.isValid()) {
            startTime = QTime(reference.time().hour(), reference.time().minute());
            if (!startTime.isValid()) {
                startTime = QTime(9, 0);
            }
        }
        if (!endTime.isValid()) {
            const int spanMinutes = durationMinutes > 0 ? durationMinutes : 60;
            endTime = startTime.addSecs(spanMinutes * 60);
        } else if (durationMinutes > 0 && endTime <= startTime) {
            endTime = startTime.addSecs(durationMinutes * 60);
        }
        if (endTime <= startTime) {
            endTime = startTime.addSecs(60 * 60);
        }
    }

    const QTimeZone tz = QTimeZone::systemTimeZone();
    record.start = QDateTime(targetDate, startTime, tz);
    if (!record.start.isValid()) {
        record.start = QDateTime(targetDate, QTime(9, 0), tz);
    }
    if (record.allDay) {
        record.end = QDateTime(targetDate, QTime(23, 59), tz);
    } else {
        if (endTime <= startTime) {
            record.end = QDateTime(targetDate.addDays(1), endTime, tz);
        } else {
            record.end = QDateTime(targetDate, endTime, tz);
        }
    }
    record.due = record.end;

    for (const QString& tag : record.tags) {
        const QString normalized = tag.trimmed().toLower();
        if (normalized == QStringLiteral("ka") || normalized == QStringLiteral("klassenarbeit")) {
            record.isExam = true;
            break;
        }
    }

    if (record.colorHint.isEmpty() && !record.tags.isEmpty()) {
        record.colorHint = record.tags.first();
    }

    result.success = true;
    result.record = record;
    return result;
}

QStringList QuickAddParser::extractTags(QString& text) {
    QStringList tags;
    QRegularExpression expr(QStringLiteral("\\B#([\\wÄÖÜäöüß]+)"));
    QRegularExpressionMatchIterator it = expr.globalMatch(text);
    QVector<QPair<int, int>> ranges;
    while (it.hasNext()) {
        const QRegularExpressionMatch match = it.next();
        const QString captured = match.captured(1);
        if (!captured.isEmpty()) {
            tags.append(captured);
        }
    ranges.append(QPair<int, int>(match.capturedStart(0), match.capturedLength(0)));
    }
    std::sort(ranges.begin(), ranges.end(), [](const QPair<int, int>& a, const QPair<int, int>& b) {
        return a.first < b.first;
    });
    for (auto itRange = ranges.crbegin(); itRange != ranges.crend(); ++itRange) {
        text.remove(itRange->first, itRange->second);
    }
    text = text.simplified();
    return tags;
}

QString QuickAddParser::extractLocation(QString& text) {
    QRegularExpression expr(QStringLiteral("\\B@([^\\s]+)"));
    QRegularExpressionMatch match = expr.match(text);
    if (!match.hasMatch()) {
        return QString();
    }
    const QString location = match.captured(1);
    text.remove(match.capturedStart(0), match.capturedLength(0));
    text = text.simplified();
    return location;
}

int QuickAddParser::extractPriority(QString& text) {
    const auto removeMatch = [&](const QRegularExpressionMatch& match) {
        text.remove(match.capturedStart(0), match.capturedLength(0));
        text = text.trimmed();
    };

    {
        QRegularExpression keywordExpr(QStringLiteral("\\!\\s*(high|medium|low)\\s*$"), QRegularExpression::CaseInsensitiveOption);
        QRegularExpressionMatch match = keywordExpr.match(text);
        if (match.hasMatch()) {
            const QString token = match.captured(1).toLower();
            removeMatch(match);
            if (token == QStringLiteral("high")) {
                return static_cast<int>(Priority::High);
            }
            if (token == QStringLiteral("medium")) {
                return static_cast<int>(Priority::Medium);
            }
            if (token == QStringLiteral("low")) {
                return static_cast<int>(Priority::Low);
            }
        }
    }

    {
        QRegularExpression legacyExpr(QStringLiteral("(\\!{1,3})\\s*$"));
        QRegularExpressionMatch match = legacyExpr.match(text);
        if (match.hasMatch()) {
            const int count = match.captured(1).length();
            removeMatch(match);
            if (count >= 3) {
                return static_cast<int>(Priority::High);
            }
            if (count == 2) {
                return static_cast<int>(Priority::Medium);
            }
            return static_cast<int>(Priority::Low);
        }
    }

    return static_cast<int>(Priority::Low);
}

QPair<QDate, bool> QuickAddParser::extractDate(QString& text, const QDate& referenceDate) {
    const auto removeMatch = [&](const QRegularExpressionMatch& match) {
        text.remove(match.capturedStart(0), match.capturedLength(0));
        text = text.simplified();
    };

    // ISO date yyyy-mm-dd with optional prefix (e.g. "on 2024-07-20")
    {
        QRegularExpression expr(QStringLiteral("\\b(?:on\\s+|am\\s+)?(\\d{4})-(\\d{1,2})-(\\d{1,2})\\b"),
                                  QRegularExpression::CaseInsensitiveOption);
        QRegularExpressionMatch match = expr.match(text);
        if (match.hasMatch()) {
            const int year = match.captured(1).toInt();
            const int month = match.captured(2).toInt();
            const int day = match.captured(3).toInt();
            const QDate date(year, month, day);
            if (date.isValid()) {
                removeMatch(match);
                return {date, true};
            }
        }
    }

    // Explicit date dd.mm or dd.mm.yyyy
    {
        QRegularExpression expr(QStringLiteral("\\b(\\d{1,2})\\.(\\d{1,2})(?:\\.(\\d{2,4}))?\\b"));
        QRegularExpressionMatch match = expr.match(text);
        if (match.hasMatch()) {
            int day = match.captured(1).toInt();
            int month = match.captured(2).toInt();
            int year = match.captured(3).isEmpty() ? referenceDate.year() : match.captured(3).toInt();
            if (year < 100) {
                year += 2000;
            }
            const QDate date(year, month, day);
            if (date.isValid()) {
                removeMatch(match);
                return {date, true};
            }
        }
    }

    // "in X Tagen"
    {
    QRegularExpression expr(QStringLiteral("\\bin\\s+(\\d+)\\s+(tag|tage|tagen)\\b"));
    QRegularExpressionMatch match = expr.match(text);
        if (match.hasMatch()) {
            const int days = match.captured(1).toInt();
            const QDate date = referenceDate.addDays(days);
            removeMatch(match);
            return {date, true};
        }
    }

    // "in X Wochen"
    {
        QRegularExpression expr(QStringLiteral("\\bin\\s+(\\d+)\\s+(woche|wochen)\\b"));
        QRegularExpressionMatch match = expr.match(text);
        if (match.hasMatch()) {
            const int weeks = match.captured(1).toInt();
            const QDate date = referenceDate.addDays(weeks * 7);
            removeMatch(match);
            return {date, true};
        }
    }

    // "nächsten Mo"
    {
        QRegularExpression expr(QStringLiteral("\\bn[aä]chsten?\\s+(mo|montag|di|dienstag|mi|mittwoch|do|donnerstag|fr|freitag|sa|samstag|so|sonntag)\\b"),
                                 QRegularExpression::CaseInsensitiveOption);
        QRegularExpressionMatch match = expr.match(text);
        if (match.hasMatch()) {
            const QString token = match.captured(1);
            const QDate date = resolveRelativeDate(token, referenceDate);
            if (date.isValid()) {
                removeMatch(match);
                return {date, true};
            }
        }
    }

    // heute / morgen / übermorgen
    {
        QRegularExpression expr(QStringLiteral("\\b(heute|morgen|übermorgen|uebermorgen)\\b"), QRegularExpression::CaseInsensitiveOption);
        QRegularExpressionMatch match = expr.match(text);
        if (match.hasMatch()) {
            const QString token = match.captured(1);
            const QDate date = resolveRelativeDate(token, referenceDate);
            if (date.isValid()) {
                removeMatch(match);
                return {date, true};
            }
        }
    }

    return {referenceDate, false};
}

QPair<QPair<QTime, QTime>, bool> QuickAddParser::extractTime(QString& text) {
    const auto removeMatch = [&](const QRegularExpressionMatch& match) {
        text.remove(match.capturedStart(0), match.capturedLength(0));
        text = text.simplified();
    };

    // Range with keywords (from 17:00 to 18:30 / von 17 bis 18)
    {
        QRegularExpression expr(QStringLiteral("\\b(?:from|von)\\s+(\\d{1,2})(?::(\\d{2}))?\\s*(?:to|bis)\\s*(\\d{1,2})(?::(\\d{2}))?\\b"),
                                 QRegularExpression::CaseInsensitiveOption);
        QRegularExpressionMatch match = expr.match(text);
        if (match.hasMatch()) {
            const int startHour = match.captured(1).toInt();
            const int startMinute = match.captured(2).isEmpty() ? 0 : match.captured(2).toInt();
            const int endHour = match.captured(3).toInt();
            const int endMinute = match.captured(4).isEmpty() ? 0 : match.captured(4).toInt();
            const QTime start(startHour, startMinute);
            const QTime end(endHour, endMinute);
            if (start.isValid() && end.isValid()) {
                removeMatch(match);
                return {{start, end}, true};
            }
        }
    }

    // Range with colon 17:00-18:30
    {
        QRegularExpression expr(QStringLiteral("\\b(\\d{1,2}):(\\d{2})\\s*[-–]\\s*(\\d{1,2}):(\\d{2})\\b"));
        QRegularExpressionMatch match = expr.match(text);
        if (match.hasMatch()) {
            const QTime start(match.captured(1).toInt(), match.captured(2).toInt());
            const QTime end(match.captured(3).toInt(), match.captured(4).toInt());
            if (start.isValid() && end.isValid()) {
                removeMatch(match);
                return {{start, end}, true};
            }
        }
    }

    // Range without colon 17-18
    {
        QRegularExpression expr(QStringLiteral("\\b(\\d{1,2})\\s*[-–]\\s*(\\d{1,2})\\b"));
        QRegularExpressionMatch match = expr.match(text);
        if (match.hasMatch()) {
            const int startHour = match.captured(1).toInt();
            const int endHour = match.captured(2).toInt();
            const QTime start(startHour, 0);
            const QTime end(endHour, 0);
            if (start.isValid() && end.isValid()) {
                removeMatch(match);
                return {{start, end}, true};
            }
        }
    }

    // Single time 17:00
    {
        QRegularExpression expr(QStringLiteral("\\b(\\d{1,2}):(\\d{2})\\b"));
        QRegularExpressionMatch match = expr.match(text);
        if (match.hasMatch()) {
            const QTime start(match.captured(1).toInt(), match.captured(2).toInt());
            if (start.isValid()) {
                removeMatch(match);
                return {{start, QTime()}, true};
            }
        }
    }

    return {{QTime(), QTime()}, false};
}

int QuickAddParser::extractDurationMinutes(QString& text) {
    QRegularExpression expr(QStringLiteral("\\b(\\d+)(h|std|stunden|m|min|minute|minuten)\\b"), QRegularExpression::CaseInsensitiveOption);
    QRegularExpressionMatch match = expr.match(text);
    if (!match.hasMatch()) {
        return 0;
    }
    const int value = match.captured(1).toInt();
    QString unit = match.captured(2).toLower();
    int minutes = 0;
    if (unit.startsWith('h') || unit.startsWith("std")) {
        minutes = value * 60;
    } else {
        minutes = value;
    }
    text.remove(match.capturedStart(0), match.capturedLength(0));
    text = text.simplified();
    return minutes;
}

QDate QuickAddParser::resolveRelativeDate(const QString& token, const QDate& referenceDate) {
    const QString lower = lowerTrimmed(token);
    if (lower.isEmpty()) {
        return referenceDate;
    }
    if (lower == QStringLiteral("heute")) {
        return referenceDate;
    }
    if (lower == QStringLiteral("morgen")) {
        return referenceDate.addDays(1);
    }
    if (lower == QStringLiteral("übermorgen") || lower == QStringLiteral("uebermorgen")) {
        return referenceDate.addDays(2);
    }

    const QMap<QString, int> dayOfWeek = {
        {QStringLiteral("mo"), Qt::Monday},
        {QStringLiteral("montag"), Qt::Monday},
        {QStringLiteral("di"), Qt::Tuesday},
        {QStringLiteral("dienstag"), Qt::Tuesday},
        {QStringLiteral("mi"), Qt::Wednesday},
        {QStringLiteral("mittwoch"), Qt::Wednesday},
        {QStringLiteral("do"), Qt::Thursday},
        {QStringLiteral("donnerstag"), Qt::Thursday},
        {QStringLiteral("fr"), Qt::Friday},
        {QStringLiteral("freitag"), Qt::Friday},
        {QStringLiteral("sa"), Qt::Saturday},
        {QStringLiteral("samstag"), Qt::Saturday},
        {QStringLiteral("so"), Qt::Sunday},
        {QStringLiteral("sonntag"), Qt::Sunday}
    };
    if (dayOfWeek.contains(lower)) {
        const int target = dayOfWeek.value(lower);
        const int current = referenceDate.dayOfWeek();
        int diff = target - current;
        if (diff <= 0) {
            diff += 7;
        }
        return referenceDate.addDays(diff);
    }
    return referenceDate;
}
