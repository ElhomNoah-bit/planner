#pragma once

#include "models/EventModel.h"

#include <QDate>
#include <QDateTime>
#include <QPair>
#include <QRegularExpression>
#include <QString>

struct QuickAddResult {
    bool success = false;
    QString error;
    EventRecord record;
};

class QuickAddParser {
public:
    QuickAddResult parse(const QString& input, const QDateTime& reference = QDateTime::currentDateTime()) const;

private:
    static QStringList extractTags(QString& text);
    static QString extractLocation(QString& text);
    static int extractPriority(QString& text);
    static QPair<QDate, bool> extractDate(QString& text, const QDate& referenceDate);
    static QPair<QPair<QTime, QTime>, bool> extractTime(QString& text);
    static int extractDurationMinutes(QString& text);
    static QDate resolveRelativeDate(const QString& token, const QDate& referenceDate);
};
