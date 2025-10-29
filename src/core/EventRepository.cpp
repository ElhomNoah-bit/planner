#include "EventRepository.h"

#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonValue>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QUuid>

#include <algorithm>

namespace {
QString isoString(const QDateTime& dt) {
    if (!dt.isValid()) {
        return QString();
    }
    return dt.toString(Qt::ISODate);
}

QDateTime fromIso(const QString& value) {
    return QDateTime::fromString(value, Qt::ISODate);
}

QString normalizedTerm(const QString& term) {
    QString t = term.trimmed().toLower();
    if (t.isEmpty()) {
        return QString();
    }
    if (!t.contains('%')) {
        t = QStringLiteral("%%1%").arg(t);
    }
    return t;
}
}

EventRepository::EventRepository()
    : m_connectionName(QStringLiteral("planner_events_%1").arg(reinterpret_cast<quintptr>(this), 0, 16)) {
}

EventRepository::~EventRepository() {
    if (!m_sqlAvailable) {
        return;
    }
    if (QSqlDatabase::contains(m_connectionName)) {
        QSqlDatabase db = QSqlDatabase::database(m_connectionName, false);
        if (db.isValid()) {
            db.close();
        }
        QSqlDatabase::removeDatabase(m_connectionName);
    }
}

bool EventRepository::initialize(const QString& storageDir) {
    QDir dir(storageDir);
    if (!dir.exists() && !dir.mkpath(QStringLiteral("."))) {
        qWarning() << "[EventRepository] Unable to create storage dir" << storageDir;
        return false;
    }

    m_dbPath = dir.filePath(QStringLiteral("events.sqlite"));
    m_jsonPath = dir.filePath(QStringLiteral("events.json"));

    QSqlDatabase db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), m_connectionName);
    db.setDatabaseName(m_dbPath);
    if (!db.open()) {
        qWarning() << "[EventRepository] SQLite unavailable, falling back to JSON" << db.lastError().text();
        QSqlDatabase::removeDatabase(m_connectionName);
        m_sqlAvailable = false;

        if (!QFile::exists(m_jsonPath)) {
            QFile file(m_jsonPath);
            if (file.open(QIODevice::WriteOnly)) {
                file.write("[]");
                file.close();
            }
        }
        return true;
    }

    m_sqlAvailable = true;

    QSqlQuery pragma(db);
    pragma.exec(QStringLiteral("PRAGMA journal_mode=WAL"));

    QSqlQuery create(db);
    const QString ddl = QStringLiteral(
        "CREATE TABLE IF NOT EXISTS events ("
        "id TEXT PRIMARY KEY NOT NULL,"
        "title TEXT NOT NULL,"
        "start DATETIME NOT NULL,"
        "end DATETIME,"
        "allDay INTEGER NOT NULL DEFAULT 0,"
        "location TEXT,"
        "notes TEXT,"
        "tags TEXT,"
        "isExam INTEGER NOT NULL DEFAULT 0,"
        "isDone INTEGER NOT NULL DEFAULT 0,"
        "due DATETIME,"
        "colorHint TEXT,"
        "priority INTEGER NOT NULL DEFAULT 0,"
        "createdAt DATETIME NOT NULL,"
        "updatedAt DATETIME NOT NULL"
        ");");
    if (!create.exec(ddl)) {
        qWarning() << "[EventRepository] Failed to create table" << create.lastError();
        m_sqlAvailable = false;
        db.close();
        QSqlDatabase::removeDatabase(m_connectionName);
        if (!QFile::exists(m_jsonPath)) {
            QFile file(m_jsonPath);
            if (file.open(QIODevice::WriteOnly)) {
                file.write("[]");
                file.close();
            }
        }
        return true;
    }

    QSqlQuery idxStart(db);
    idxStart.exec(QStringLiteral("CREATE INDEX IF NOT EXISTS idx_events_start ON events(start);"));
    QSqlQuery idxTags(db);
    idxTags.exec(QStringLiteral("CREATE INDEX IF NOT EXISTS idx_events_tags ON events(tags);"));

    return true;
}

QVector<EventRecord> EventRepository::loadAll(bool onlyOpen) const {
    if (!m_sqlAvailable) {
        return loadFromJson(onlyOpen);
    }
    QSqlDatabase db = database();
    if (!db.isValid()) {
        return {};
    }
    QSqlQuery query(db);
    QString sql = QStringLiteral("SELECT * FROM events");
    if (onlyOpen) {
        sql += QStringLiteral(" WHERE isDone = 0");
    }
    sql += QStringLiteral(" ORDER BY start ASC");
    if (!query.exec(sql)) {
        qWarning() << "[EventRepository] loadAll failed" << query.lastError();
        return {};
    }
    return runQuery(query);
}

QVector<EventRecord> EventRepository::loadBetween(const QDate& start, const QDate& end, bool onlyOpen) const {
    if (!m_sqlAvailable) {
        return loadRangeFromJson(start, end, onlyOpen);
    }
    QSqlDatabase db = database();
    if (!db.isValid()) {
        return {};
    }
    QSqlQuery query(db);
    QString sql = QStringLiteral("SELECT * FROM events WHERE date(start) BETWEEN :start AND :end");
    if (onlyOpen) {
        sql += QStringLiteral(" AND isDone = 0");
    }
    sql += QStringLiteral(" ORDER BY start ASC");
    if (!query.prepare(sql)) {
        qWarning() << "[EventRepository] loadBetween prepare failed" << query.lastError();
        return {};
    }
    query.bindValue(QStringLiteral(":start"), start.toString(Qt::ISODate));
    query.bindValue(QStringLiteral(":end"), end.toString(Qt::ISODate));
    if (!query.exec()) {
        qWarning() << "[EventRepository] loadBetween exec failed" << query.lastError();
        return {};
    }
    return runQuery(query);
}

QVector<EventRecord> EventRepository::search(const QString& term, bool onlyOpen) const {
    if (!m_sqlAvailable) {
        return searchInJson(term, onlyOpen);
    }
    const QString likeTerm = normalizedTerm(term);
    QSqlDatabase db = database();
    if (!db.isValid()) {
        return {};
    }
    QSqlQuery query(db);
    QString sql = QStringLiteral("SELECT * FROM events WHERE 1=1");
    if (!likeTerm.isEmpty()) {
        sql += QStringLiteral(" AND (lower(title) LIKE :term OR lower(location) LIKE :term OR lower(tags) LIKE :term)");
    }
    if (onlyOpen) {
        sql += QStringLiteral(" AND isDone = 0");
    }
    sql += QStringLiteral(" ORDER BY start ASC");
    if (!query.prepare(sql)) {
        qWarning() << "[EventRepository] search prepare failed" << query.lastError();
        return {};
    }
    if (!likeTerm.isEmpty()) {
        query.bindValue(QStringLiteral(":term"), likeTerm);
    }
    if (!query.exec()) {
        qWarning() << "[EventRepository] search exec failed" << query.lastError();
        return {};
    }
    return runQuery(query);
}

bool EventRepository::insert(EventRecord& record) {
    if (!m_sqlAvailable) {
        return insertJson(record);
    }
    QSqlDatabase db = database();
    if (!db.isValid()) {
        return false;
    }
    if (record.id.isEmpty()) {
        record.id = QUuid::createUuid().toString(QUuid::WithoutBraces);
    }
    const QDateTime now = QDateTime::currentDateTimeUtc();
    const QString tagJson = QJsonDocument(QJsonArray::fromStringList(record.tags)).toJson(QJsonDocument::Compact);

    QSqlQuery query(db);
    const QString sql = QStringLiteral(
        "INSERT INTO events (id, title, start, end, allDay, location, notes, tags, isExam, isDone, due, colorHint, priority, createdAt, updatedAt) "
        "VALUES (:id, :title, :start, :end, :allDay, :location, :notes, :tags, :isExam, :isDone, :due, :colorHint, :priority, :createdAt, :updatedAt)");
    if (!query.prepare(sql)) {
        qWarning() << "[EventRepository] insert prepare failed" << query.lastError();
        return false;
    }
    const QString startIso = isoString(record.start);
    const QString endIso = record.end.isValid() ? isoString(record.end) : QString();
    query.bindValue(QStringLiteral(":id"), record.id);
    query.bindValue(QStringLiteral(":title"), record.title);
    query.bindValue(QStringLiteral(":start"), startIso);
    query.bindValue(QStringLiteral(":end"), endIso.isEmpty() ? QVariant() : QVariant(endIso));
    query.bindValue(QStringLiteral(":allDay"), record.allDay ? 1 : 0);
    query.bindValue(QStringLiteral(":location"), record.location);
    query.bindValue(QStringLiteral(":notes"), record.notes);
    query.bindValue(QStringLiteral(":tags"), tagJson);
    query.bindValue(QStringLiteral(":isExam"), record.isExam ? 1 : 0);
    query.bindValue(QStringLiteral(":isDone"), record.isDone ? 1 : 0);
    const QString dueIso = record.due.isValid() ? isoString(record.due) : QString();
    query.bindValue(QStringLiteral(":due"), dueIso.isEmpty() ? QVariant() : QVariant(dueIso));
    query.bindValue(QStringLiteral(":colorHint"), record.colorHint);
    query.bindValue(QStringLiteral(":priority"), record.priority);
    query.bindValue(QStringLiteral(":createdAt"), isoString(now));
    query.bindValue(QStringLiteral(":updatedAt"), isoString(now));

    if (!query.exec()) {
        qWarning() << "[EventRepository] insert exec failed" << query.lastError();
        return false;
    }
    return true;
}

bool EventRepository::setDone(const QString& id, bool done) {
    if (!m_sqlAvailable) {
        return setDoneJson(id, done);
    }
    QSqlDatabase db = database();
    if (!db.isValid()) {
        return false;
    }
    QSqlQuery query(db);
    if (!query.prepare(QStringLiteral("UPDATE events SET isDone = :done, updatedAt = :updatedAt WHERE id = :id"))) {
        qWarning() << "[EventRepository] setDone prepare failed" << query.lastError();
        return false;
    }
    query.bindValue(QStringLiteral(":done"), done ? 1 : 0);
    query.bindValue(QStringLiteral(":updatedAt"), isoString(QDateTime::currentDateTimeUtc()));
    query.bindValue(QStringLiteral(":id"), id);
    if (!query.exec()) {
        qWarning() << "[EventRepository] setDone exec failed" << query.lastError();
        return false;
    }
    return query.numRowsAffected() > 0;
}

bool EventRepository::update(const EventRecord& record) {
    if (!m_sqlAvailable) {
        return updateJson(record);
    }
    QSqlDatabase db = database();
    if (!db.isValid()) {
        return false;
    }
    QSqlQuery query(db);
    if (!query.prepare(QStringLiteral(
            "UPDATE events SET title=:title, start=:start, end=:end, allDay=:allDay, location=:location, notes=:notes, tags=:tags,"
            " isExam=:isExam, isDone=:isDone, due=:due, colorHint=:colorHint, priority=:priority, updatedAt=:updatedAt WHERE id=:id"))) {
        qWarning() << "[EventRepository] update prepare failed" << query.lastError();
        return false;
    }
    query.bindValue(QStringLiteral(":title"), record.title);
    query.bindValue(QStringLiteral(":start"), isoString(record.start));
    query.bindValue(QStringLiteral(":end"), record.end.isValid() ? QVariant(isoString(record.end)) : QVariant());
    query.bindValue(QStringLiteral(":allDay"), record.allDay ? 1 : 0);
    query.bindValue(QStringLiteral(":location"), record.location);
    query.bindValue(QStringLiteral(":notes"), record.notes);
    query.bindValue(QStringLiteral(":tags"), QJsonDocument(QJsonArray::fromStringList(record.tags)).toJson(QJsonDocument::Compact));
    query.bindValue(QStringLiteral(":isExam"), record.isExam ? 1 : 0);
    query.bindValue(QStringLiteral(":isDone"), record.isDone ? 1 : 0);
    query.bindValue(QStringLiteral(":due"), record.due.isValid() ? QVariant(isoString(record.due)) : QVariant());
    query.bindValue(QStringLiteral(":colorHint"), record.colorHint);
    query.bindValue(QStringLiteral(":priority"), record.priority);
    query.bindValue(QStringLiteral(":updatedAt"), isoString(QDateTime::currentDateTimeUtc()));
    query.bindValue(QStringLiteral(":id"), record.id);
    if (!query.exec()) {
        qWarning() << "[EventRepository] update exec failed" << query.lastError();
        return false;
    }
    return query.numRowsAffected() > 0;
}

bool EventRepository::remove(const QString& id) {
    if (!m_sqlAvailable) {
        return removeJson(id);
    }
    QSqlDatabase db = database();
    if (!db.isValid()) {
        return false;
    }
    QSqlQuery query(db);
    if (!query.prepare(QStringLiteral("DELETE FROM events WHERE id = :id"))) {
        qWarning() << "[EventRepository] remove prepare failed" << query.lastError();
        return false;
    }
    query.bindValue(QStringLiteral(":id"), id);
    if (!query.exec()) {
        qWarning() << "[EventRepository] remove exec failed" << query.lastError();
        return false;
    }
    return query.numRowsAffected() > 0;
}

QSqlDatabase EventRepository::database() const {
    return QSqlDatabase::database(m_connectionName, false);
}

QVector<EventRecord> EventRepository::runQuery(QSqlQuery& query) const {
    QVector<EventRecord> results;
    while (query.next()) {
        results.append(recordFromQuery(query));
    }
    return results;
}

EventRecord EventRepository::recordFromQuery(const QSqlQuery& query) {
    EventRecord record;
    record.id = query.value(QStringLiteral("id")).toString();
    record.title = query.value(QStringLiteral("title")).toString();
    record.start = fromIso(query.value(QStringLiteral("start")).toString());
    record.end = fromIso(query.value(QStringLiteral("end")).toString());
    record.allDay = query.value(QStringLiteral("allDay")).toInt() == 1;
    record.location = query.value(QStringLiteral("location")).toString();
    record.notes = query.value(QStringLiteral("notes")).toString();
    const QString tagsJson = query.value(QStringLiteral("tags")).toString();
    if (!tagsJson.isEmpty()) {
        const QJsonDocument doc = QJsonDocument::fromJson(tagsJson.toUtf8());
        if (doc.isArray()) {
            const QJsonArray arr = doc.array();
            for (const auto& value : arr) {
                record.tags.append(value.toString());
            }
        }
    }
    record.isExam = query.value(QStringLiteral("isExam")).toInt() == 1;
    record.isDone = query.value(QStringLiteral("isDone")).toInt() == 1;
    record.due = fromIso(query.value(QStringLiteral("due")).toString());
    record.colorHint = query.value(QStringLiteral("colorHint")).toString();
    record.priority = query.value(QStringLiteral("priority")).toInt();
    return record;
}

QVector<EventRecord> EventRepository::loadFromJson(bool onlyOpen) const {
    const QJsonArray array = readJsonArray();
    QVector<EventRecord> records;
    records.reserve(array.size());
    for (const auto& value : array) {
        if (!value.isObject()) {
            continue;
        }
        EventRecord record = recordFromJson(value.toObject());
        if (onlyOpen && record.isDone) {
            continue;
        }
        records.append(record);
    }
    std::sort(records.begin(), records.end(), [](const EventRecord& a, const EventRecord& b) {
        return a.start < b.start;
    });
    return records;
}

QVector<EventRecord> EventRepository::loadRangeFromJson(const QDate& start, const QDate& end, bool onlyOpen) const {
    const QJsonArray array = readJsonArray();
    QVector<EventRecord> records;
    for (const auto& value : array) {
        if (!value.isObject()) {
            continue;
        }
        EventRecord record = recordFromJson(value.toObject());
        if (!record.start.isValid()) {
            continue;
        }
        const QDate d = record.start.date();
        if (d < start || d > end) {
            continue;
        }
        if (onlyOpen && record.isDone) {
            continue;
        }
        records.append(record);
    }
    std::sort(records.begin(), records.end(), [](const EventRecord& a, const EventRecord& b) {
        return a.start < b.start;
    });
    return records;
}

QVector<EventRecord> EventRepository::searchInJson(const QString& term, bool onlyOpen) const {
    const QString needle = term.trimmed().toLower();
    const QJsonArray array = readJsonArray();
    QVector<EventRecord> records;
    for (const auto& value : array) {
        if (!value.isObject()) {
            continue;
        }
        EventRecord record = recordFromJson(value.toObject());
        if (onlyOpen && record.isDone) {
            continue;
        }
        const QString haystack = QStringList({record.title.toLower(), record.location.toLower(), record.tags.join(" ").toLower()}).join(' ');
        if (!needle.isEmpty() && !haystack.contains(needle)) {
            continue;
        }
        records.append(record);
    }
    std::sort(records.begin(), records.end(), [](const EventRecord& a, const EventRecord& b) {
        return a.start < b.start;
    });
    return records;
}

bool EventRepository::writeJsonArray(const QJsonArray& array) const {
    QFile file(m_jsonPath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        qWarning() << "[EventRepository] Unable to write JSON store" << m_jsonPath;
        return false;
    }
    file.write(QJsonDocument(array).toJson(QJsonDocument::Compact));
    file.close();
    return true;
}

QJsonArray EventRepository::readJsonArray() const {
    QFile file(m_jsonPath);
    if (!file.exists()) {
        return QJsonArray();
    }
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "[EventRepository] Unable to read JSON store" << m_jsonPath;
        return QJsonArray();
    }
    const QByteArray data = file.readAll();
    file.close();
    const QJsonDocument doc = QJsonDocument::fromJson(data);
    if (!doc.isArray()) {
        return QJsonArray();
    }
    return doc.array();
}

bool EventRepository::insertJson(EventRecord& record) {
    if (record.id.isEmpty()) {
        record.id = QUuid::createUuid().toString(QUuid::WithoutBraces);
    }
    QJsonArray array = readJsonArray();
    array.append(recordToJson(record));
    return writeJsonArray(array);
}

bool EventRepository::setDoneJson(const QString& id, bool done) {
    QJsonArray array = readJsonArray();
    bool changed = false;
    for (int i = 0; i < array.size(); ++i) {
        QJsonObject obj = array.at(i).toObject();
        if (obj.value(QStringLiteral("id")).toString() == id) {
            obj.insert(QStringLiteral("isDone"), done);
            array.replace(i, obj);
            changed = true;
            break;
        }
    }
    if (!changed) {
        return false;
    }
    return writeJsonArray(array);
}

bool EventRepository::updateJson(const EventRecord& record) {
    QJsonArray array = readJsonArray();
    bool changed = false;
    for (int i = 0; i < array.size(); ++i) {
        QJsonObject obj = array.at(i).toObject();
        if (obj.value(QStringLiteral("id")).toString() == record.id) {
            array.replace(i, recordToJson(record));
            changed = true;
            break;
        }
    }
    if (!changed) {
        return false;
    }
    return writeJsonArray(array);
}

bool EventRepository::removeJson(const QString& id) {
    QJsonArray array = readJsonArray();
    QJsonArray updated;
    bool removed = false;
    for (const auto& value : array) {
        if (!value.isObject()) {
            continue;
        }
        const QJsonObject obj = value.toObject();
        if (obj.value(QStringLiteral("id")).toString() == id) {
            removed = true;
            continue;
        }
        updated.append(obj);
    }
    if (!removed) {
        return false;
    }
    return writeJsonArray(updated);
}

QJsonObject EventRepository::recordToJson(const EventRecord& record) {
    QJsonObject obj;
    obj.insert(QStringLiteral("id"), record.id);
    obj.insert(QStringLiteral("title"), record.title);
    obj.insert(QStringLiteral("start"), isoString(record.start));
    obj.insert(QStringLiteral("end"), isoString(record.end));
    obj.insert(QStringLiteral("allDay"), record.allDay);
    obj.insert(QStringLiteral("location"), record.location);
    obj.insert(QStringLiteral("notes"), record.notes);
    obj.insert(QStringLiteral("tags"), QJsonArray::fromStringList(record.tags));
    obj.insert(QStringLiteral("isExam"), record.isExam);
    obj.insert(QStringLiteral("isDone"), record.isDone);
    obj.insert(QStringLiteral("due"), isoString(record.due));
    obj.insert(QStringLiteral("colorHint"), record.colorHint);
    obj.insert(QStringLiteral("priority"), record.priority);
    obj.insert(QStringLiteral("categoryId"), record.categoryId);
    return obj;
}

EventRecord EventRepository::recordFromJson(const QJsonObject& object) {
    EventRecord record;
    record.id = object.value(QStringLiteral("id")).toString();
    record.title = object.value(QStringLiteral("title")).toString();
    record.start = fromIso(object.value(QStringLiteral("start")).toString());
    record.end = fromIso(object.value(QStringLiteral("end")).toString());
    record.allDay = object.value(QStringLiteral("allDay")).toBool();
    record.location = object.value(QStringLiteral("location")).toString();
    record.notes = object.value(QStringLiteral("notes")).toString();
    const QJsonValue tagValue = object.value(QStringLiteral("tags"));
    if (tagValue.isArray()) {
        const QJsonArray arr = tagValue.toArray();
        for (const auto& value : arr) {
            record.tags.append(value.toString());
        }
    }
    record.isExam = object.value(QStringLiteral("isExam")).toBool();
    record.isDone = object.value(QStringLiteral("isDone")).toBool();
    record.due = fromIso(object.value(QStringLiteral("due")).toString());
    record.colorHint = object.value(QStringLiteral("colorHint")).toString();
    record.priority = object.value(QStringLiteral("priority")).toInt();
    record.categoryId = object.value(QStringLiteral("categoryId")).toString();
    return record;
}
