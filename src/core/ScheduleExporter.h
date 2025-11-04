#pragma once

#include "models/EventModel.h"

#include <QDate>
#include <QString>
#include <QVector>

class ScheduleExporter {
public:
    bool exportRange(const QVector<EventRecord>& events, const QDate& start, const QDate& end, const QString& filePath) const;
    bool exportWeek(const QVector<EventRecord>& events, const QDate& weekStart, const QString& filePath) const;
    bool exportMonth(const QVector<EventRecord>& events, int year, int month, const QString& filePath) const;
};
