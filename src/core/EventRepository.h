#pragma once

#include "models/EventModel.h"

#include <QDate>
#include <QJsonArray>
#include <QJsonObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QString>
#include <QVector>

class EventRepository {
public:
    EventRepository();
    ~EventRepository();

    bool initialize(const QString& storageDir);

    QVector<EventRecord> loadAll(bool onlyOpen) const;
    QVector<EventRecord> loadBetween(const QDate& start, const QDate& end, bool onlyOpen) const;
    QVector<EventRecord> search(const QString& term, bool onlyOpen) const;

    bool insert(EventRecord& record);
    bool setDone(const QString& id, bool done);
    bool update(const EventRecord& record);
    bool remove(const QString& id);

    bool isSqlAvailable() const { return m_sqlAvailable; }
    QString databasePath() const { return m_dbPath; }
    QString jsonFallbackPath() const { return m_jsonPath; }

private:
    QString m_connectionName;
    QString m_dbPath;
    QString m_jsonPath;
    bool m_sqlAvailable = false;

    QSqlDatabase database() const;
    QVector<EventRecord> runQuery(QSqlQuery& query) const;
    static EventRecord recordFromQuery(const QSqlQuery& query);

    QVector<EventRecord> loadFromJson(bool onlyOpen) const;
    QVector<EventRecord> loadRangeFromJson(const QDate& start, const QDate& end, bool onlyOpen) const;
    QVector<EventRecord> searchInJson(const QString& term, bool onlyOpen) const;
    bool writeJsonArray(const QJsonArray& array) const;
    QJsonArray readJsonArray() const;
    bool insertJson(EventRecord& record);
    bool setDoneJson(const QString& id, bool done);
    bool updateJson(const EventRecord& record);
    bool removeJson(const QString& id);

    static QJsonObject recordToJson(const EventRecord& record);
    static EventRecord recordFromJson(const QJsonObject& object);
    
    static int computePriority(const EventRecord& record, const QDate& currentDate);
};
