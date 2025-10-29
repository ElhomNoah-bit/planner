#pragma once

#include "FocusSession.h"

#include <QDate>
#include <QJsonArray>
#include <QJsonObject>
#include <QMap>
#include <QString>
#include <QVector>

class FocusSessionRepository {
public:
    FocusSessionRepository();

    bool initialize(const QString& storageDir);

    QVector<FocusSession> loadAll() const;
    QVector<FocusSession> loadByDate(const QDate& date) const;
    QVector<FocusSession> loadBetween(const QDate& start, const QDate& end) const;
    FocusSession loadById(const QString& id) const;

    bool insert(FocusSession& session);
    bool update(const FocusSession& session);
    bool remove(const QString& id);

    int getTotalMinutesForDate(const QDate& date) const;
    QMap<QDate, int> getWeeklyMinutes(const QDate& weekStart) const;
    
    QString jsonPath() const { return m_jsonPath; }

private:
    QString m_jsonPath;

    QJsonArray readJsonArray() const;
    bool writeJsonArray(const QJsonArray& array) const;
    
    static QJsonObject sessionToJson(const FocusSession& session);
    static FocusSession sessionFromJson(const QJsonObject& object);
};
