#include "IcsImportService.h"

#include "CategoryRepository.h"

#include <QCryptographicHash>
#include <QDebug>
#include <QHash>
#include <QMap>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QSettings>
#include <QTimeZone>
#include <QUrl>
#include <QVariant>
#include <QVector>

#include <utility>

namespace {
const QString kSettingsGroup = QStringLiteral("integrations/untisIcs");
const QString kSourceKey = QStringLiteral("untis:ics");
const int kAutoSyncIntervalMs = 6 * 60 * 60 * 1000; // 6 hours
const QString kDefaultCategoryId = QStringLiteral("untis");
const QString kDefaultCategoryName = QStringLiteral("Untis");
const QString kDefaultCategoryColor = QStringLiteral("#1A2B4D");

struct IcsProperty {
    QString name;
    QMap<QString, QString> params;
    QString value;
};

QString decodeText(const QString& value) {
    QString decoded = value;
    decoded.replace(QStringLiteral("\\n"), QStringLiteral("\n"));
    decoded.replace(QStringLiteral("\\,"), QStringLiteral(","));
    decoded.replace(QStringLiteral("\\;"), QStringLiteral(";"));
    decoded.replace(QStringLiteral("\\\\"), QStringLiteral("\\"));
    return decoded.trimmed();
}

IcsProperty parsePropertyLine(const QString& line) {
    IcsProperty prop;
    const int colon = line.indexOf(QLatin1Char(':'));
    if (colon < 0) {
        prop.name = line.trimmed().toUpper();
        return prop;
    }
    const QString header = line.left(colon);
    prop.value = line.mid(colon + 1).trimmed();

    const QStringList segments = header.split(QLatin1Char(';'));
    if (segments.isEmpty()) {
        return prop;
    }
    prop.name = segments.first().trimmed().toUpper();
    for (int i = 1; i < segments.size(); ++i) {
        const QString segment = segments.at(i);
        const int eq = segment.indexOf(QLatin1Char('='));
        if (eq < 0) {
            continue;
        }
        const QString key = segment.left(eq).trimmed().toUpper();
        const QString value = segment.mid(eq + 1).trimmed();
        prop.params.insert(key, value);
    }
    return prop;
}

QDateTime parseDateTimeProperty(const IcsProperty& prop, bool* allDayFlag) {
    QString value = prop.value.trimmed();
    if (value.isEmpty()) {
        return {};
    }
    bool localAllDay = false;
    if (prop.params.value(QStringLiteral("VALUE")).compare(QStringLiteral("DATE"), Qt::CaseInsensitive) == 0) {
        localAllDay = true;
    }
    if (value.size() == 8) {
        localAllDay = true;
    }

    QDateTime result;
    QDate date = QDate::fromString(value.left(8), QStringLiteral("yyyyMMdd"));
    if (!date.isValid()) {
        return {};
    }

    if (localAllDay) {
        if (allDayFlag) {
            *allDayFlag = true;
        }
        result = QDateTime(date, QTime(0, 0), Qt::LocalTime);
        return result.toLocalTime();
    }

    QString timePart = value.mid(9);
    bool isUtc = false;
    if (timePart.endsWith(QLatin1Char('Z'))) {
        isUtc = true;
        timePart.chop(1);
    }

    QTime time = QTime::fromString(timePart.left(6), QStringLiteral("hhmmss"));
    if (!time.isValid()) {
        time = QTime::fromString(timePart.left(4), QStringLiteral("hhmm"));
    }
    if (!time.isValid()) {
        return {};
    }

    if (prop.params.contains(QStringLiteral("TZID"))) {
        const QTimeZone zone(prop.params.value(QStringLiteral("TZID")).toUtf8());
        if (zone.isValid()) {
            result = QDateTime(date, time, zone);
        }
    }

    if (!result.isValid()) {
        result = QDateTime(date, time, isUtc ? Qt::UTC : Qt::LocalTime);
    }

    return result.toLocalTime();
}
}

IcsImportService::IcsImportService(EventRepository* repository,
                                   CategoryRepository* categoryRepository,
                                   QObject* parent)
    : QObject(parent)
    , m_repository(repository)
    , m_categoryRepository(categoryRepository) {
    m_autoTimer.setSingleShot(false);
    m_autoTimer.setInterval(kAutoSyncIntervalMs);
    m_autoTimer.setTimerType(Qt::VeryCoarseTimer);
    QObject::connect(&m_autoTimer, &QTimer::timeout, this, &IcsImportService::syncNow);

    loadState();
    scheduleAutoSync();
}

QVariantMap IcsImportService::status() const {
    QVariantMap map;
    map.insert(QStringLiteral("url"), m_url);
    map.insert(QStringLiteral("autoSync"), m_autoSync);
    map.insert(QStringLiteral("syncing"), m_syncing);
    map.insert(QStringLiteral("lastError"), m_lastError);
    map.insert(QStringLiteral("linkValid"), m_linkValid);
    map.insert(QStringLiteral("hasUrl"), !m_url.isEmpty());
    if (m_lastSync.isValid()) {
        map.insert(QStringLiteral("lastSync"), m_lastSync);
        map.insert(QStringLiteral("lastSyncIso"), m_lastSync.toString(Qt::ISODate));
    }
    if (m_autoTimer.isActive()) {
        map.insert(QStringLiteral("nextSyncMs"), m_autoTimer.remainingTime());
    }
    return map;
}

void IcsImportService::setUrl(const QString& url) {
    const QString trimmed = url.trimmed();
    if (trimmed == m_url) {
        return;
    }
    if (!trimmed.isEmpty()) {
        const QUrl parsed(trimmed);
        if (!parsed.isValid() || parsed.scheme().isEmpty()) {
            m_lastError = tr("Die angegebene ICS-URL ist ungültig.");
            m_linkValid = false;
            emit statusChanged();
            return;
        }
    }
    m_url = trimmed;
    m_linkValid = true;
    m_lastError.clear();
    saveState();
    scheduleAutoSync();
    emit statusChanged();
}

void IcsImportService::setAutoSync(bool enabled) {
    if (m_autoSync == enabled) {
        return;
    }
    m_autoSync = enabled;
    saveState();
    scheduleAutoSync();
    emit statusChanged();
}

void IcsImportService::syncNow() {
    if (m_syncing) {
        return;
    }
    if (m_url.isEmpty()) {
        m_lastError = tr("Bitte zuerst eine ICS-URL hinterlegen.");
        m_linkValid = false;
        emit statusChanged();
        return;
    }

    const QUrl target(m_url);
    if (!target.isValid()) {
        m_lastError = tr("Die gespeicherte ICS-URL konnte nicht gelesen werden.");
        m_linkValid = false;
        emit statusChanged();
        return;
    }

    ensureUntisCategory();

    m_syncing = true;
    m_lastError.clear();
    emit statusChanged();

    QNetworkRequest request(target);
    request.setHeader(QNetworkRequest::UserAgentHeader, QStringLiteral("NoahPlanner/2.0"));
    request.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::NoLessSafeRedirectPolicy);
    auto reply = m_network.get(request);
    QObject::connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        handleReply(reply);
    });
}

void IcsImportService::disconnect(bool keepEvents) {
    if (!keepEvents && m_repository) {
        if (m_repository->removeBySource(kSourceKey)) {
            emit eventsUpdated();
        }
    }
    m_url.clear();
    m_autoSync = false;
    m_lastSync = QDateTime();
    m_lastError.clear();
    m_linkValid = true;
    m_autoTimer.stop();
    saveState();
    emit statusChanged();
}

void IcsImportService::loadState() {
    QSettings settings;
    settings.beginGroup(kSettingsGroup);
    m_url = settings.value(QStringLiteral("url")).toString();
    m_autoSync = settings.value(QStringLiteral("autoSync"), false).toBool();
    const QString lastSyncIso = settings.value(QStringLiteral("lastSync")).toString();
    if (!lastSyncIso.isEmpty()) {
        m_lastSync = QDateTime::fromString(lastSyncIso, Qt::ISODate);
    }
    m_lastError = settings.value(QStringLiteral("lastError")).toString();
    m_linkValid = settings.value(QStringLiteral("linkValid"), true).toBool();
    settings.endGroup();
}

void IcsImportService::saveState() const {
    QSettings settings;
    settings.beginGroup(kSettingsGroup);
    settings.setValue(QStringLiteral("url"), m_url);
    settings.setValue(QStringLiteral("autoSync"), m_autoSync);
    if (m_lastSync.isValid()) {
        settings.setValue(QStringLiteral("lastSync"), m_lastSync.toString(Qt::ISODate));
    } else {
        settings.remove(QStringLiteral("lastSync"));
    }
    settings.setValue(QStringLiteral("lastError"), m_lastError);
    settings.setValue(QStringLiteral("linkValid"), m_linkValid);
    settings.endGroup();
}

void IcsImportService::scheduleAutoSync() {
    if (!m_autoSync || m_url.isEmpty()) {
        m_autoTimer.stop();
        return;
    }
    if (!m_autoTimer.isActive()) {
        m_autoTimer.start();
    }
}

void IcsImportService::handleReply(QNetworkReply* reply) {
    if (!reply) {
        completeSync(false, tr("Netzwerkantwort fehlt."));
        return;
    }

    const QVariant statusAttr = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
    const int statusCode = statusAttr.isValid() ? statusAttr.toInt() : 0;

    if (reply->error() != QNetworkReply::NoError) {
        const QString errorText = reply->errorString();
        if (statusCode == 401 || statusCode == 403 || statusCode == 404) {
            m_linkValid = false;
        }
        reply->deleteLater();
        completeSync(false, errorText);
        return;
    }

    const QByteArray payload = reply->readAll();
    reply->deleteLater();
    QVector<ParsedEvent> parsed = parseIcs(payload);

    QHash<QString, EventRecord> existing;
    if (m_repository) {
        const QVector<EventRecord> bySource = m_repository->findBySource(kSourceKey);
        for (const auto& record : bySource) {
            if (!record.externalId.isEmpty()) {
                existing.insert(record.externalId, record);
            }
        }
    }

    bool changed = false;
    for (const auto& input : parsed) {
        EventRecord record = buildRecord(input);
        if (!record.start.isValid()) {
            continue;
        }
        const QString externalId = record.externalId;
        if (externalId.isEmpty()) {
            continue;
        }
        auto it = existing.find(externalId);
        if (it != existing.end()) {
            record.id = it->id;
            record.isDone = it->isDone;
            if (!it->categoryId.isEmpty()) {
                record.categoryId = it->categoryId;
            }
            if (!m_repository->update(record)) {
                qWarning() << "[IcsImportService] Failed to update event" << record.id;
            } else {
                changed = true;
            }
            existing.erase(it);
        } else {
            if (m_repository && m_repository->insert(record)) {
                changed = true;
            }
        }
    }

    for (auto it = existing.cbegin(); it != existing.cend(); ++it) {
        if (m_repository && m_repository->remove(it->id)) {
            changed = true;
        }
    }

    if (changed) {
        emit eventsUpdated();
    }

    completeSync(true);
}

void IcsImportService::completeSync(bool success, const QString& errorMessage) {
    m_syncing = false;
    if (success) {
        m_lastSync = QDateTime::currentDateTimeUtc();
        m_lastError.clear();
        m_linkValid = true;
    } else {
        if (!errorMessage.isEmpty()) {
            m_lastError = errorMessage;
        }
    }
    saveState();
    emit statusChanged();
    scheduleAutoSync();
}

void IcsImportService::ensureUntisCategory() {
    if (!m_categoryRepository) {
        return;
    }
    Category existing = m_categoryRepository->findById(kDefaultCategoryId);
    if (existing.isValid()) {
        return;
    }
    Category cat;
    cat.id = kDefaultCategoryId;
    cat.name = kDefaultCategoryName;
    cat.color = QColor(kDefaultCategoryColor);
    if (!m_categoryRepository->insert(cat)) {
        qWarning() << "[IcsImportService] Unable to create Untis category";
    }
}

QVector<IcsImportService::ParsedEvent> IcsImportService::parseIcs(const QByteArray& payload) const {
    QVector<ParsedEvent> events;
    if (payload.isEmpty()) {
        return events;
    }

    QString text = QString::fromUtf8(payload);
    text.replace(QStringLiteral("\r\n"), QStringLiteral("\n"));
    text.replace(QLatin1Char('\r'), QLatin1Char('\n'));
    const QStringList rawLines = text.split(QLatin1Char('\n'));

    QStringList lines;
    lines.reserve(rawLines.size());
    for (const QString& rawLine : rawLines) {
        if (rawLine.startsWith(QLatin1Char(' ')) || rawLine.startsWith(QLatin1Char('\t'))) {
            if (!lines.isEmpty()) {
                QString unfolded = lines.takeLast();
                unfolded.append(rawLine.mid(1));
                lines.append(unfolded);
            }
        } else {
            lines.append(rawLine);
        }
    }

    bool inEvent = false;
    ParsedEvent current;

    for (const QString& line : std::as_const(lines)) {
        if (line.compare(QStringLiteral("BEGIN:VEVENT"), Qt::CaseInsensitive) == 0) {
            inEvent = true;
            current = ParsedEvent();
            continue;
        }
        if (line.compare(QStringLiteral("END:VEVENT"), Qt::CaseInsensitive) == 0) {
            if (inEvent && current.start.isValid()) {
                if (!current.end.isValid()) {
                    current.end = current.start;
                }
                events.append(current);
            }
            inEvent = false;
            continue;
        }
        if (!inEvent) {
            continue;
        }

        const IcsProperty prop = parsePropertyLine(line);
        if (prop.name == QStringLiteral("UID")) {
            current.uid = prop.value.trimmed();
        } else if (prop.name == QStringLiteral("SUMMARY")) {
            current.title = decodeText(prop.value);
        } else if (prop.name == QStringLiteral("LOCATION")) {
            current.location = decodeText(prop.value);
        } else if (prop.name == QStringLiteral("DESCRIPTION")) {
            current.description = decodeText(prop.value);
        } else if (prop.name == QStringLiteral("CATEGORIES")) {
            const QStringList parts = prop.value.split(QLatin1Char(','), Qt::SkipEmptyParts);
            current.categories.clear();
            for (const QString& part : parts) {
                current.categories.append(decodeText(part));
            }
        } else if (prop.name == QStringLiteral("DTSTART")) {
            QDateTime start = parseDateTimeProperty(prop, &current.allDay);
            if (start.isValid()) {
                current.start = start;
            }
        } else if (prop.name == QStringLiteral("DTEND")) {
            bool dummy = current.allDay;
            QDateTime end = parseDateTimeProperty(prop, &dummy);
            if (end.isValid()) {
                current.end = end;
            }
        }
    }

    return events;
}

EventRecord IcsImportService::buildRecord(const ParsedEvent& input) const {
    EventRecord record;
    record.title = input.title.isEmpty() ? tr("Unterricht") : input.title;
    record.location = input.location;
    record.notes = input.description;
    record.start = input.start;
    record.end = input.end.isValid() ? input.end : input.start.addSecs(45 * 60);
    if (input.allDay) {
        record.allDay = true;
        if (record.end.date() == record.start.date()) {
            record.end = record.end.addDays(1);
        }
    }
    if (!record.end.isValid() || record.end < record.start) {
        record.end = record.start;
    }

    record.tags = input.categories;
    record.tags.append(QStringLiteral("untis"));
    record.tags.removeDuplicates();

    const QString eventType = detectEventType(input);
    record.eventType = eventType;
    record.isExam = (eventType == QStringLiteral("exam"));
    record.colorHint = record.isExam ? QStringLiteral("#F97066") : kDefaultCategoryColor;
    record.priority = 0;
    record.isDone = false;
    record.due = record.start;
    record.categoryId = kDefaultCategoryId;
    record.source = kSourceKey;
    record.externalId = computeExternalId(input);

    return record;
}

QString IcsImportService::computeExternalId(const ParsedEvent& input) const {
    if (!input.uid.trimmed().isEmpty()) {
        return input.uid.trimmed();
    }
    const QString key = QStringLiteral("%1|%2|%3|%4")
                             .arg(input.title)
                             .arg(input.start.toString(Qt::ISODate))
                             .arg(input.end.toString(Qt::ISODate))
                             .arg(input.location);
    const QByteArray hash = QCryptographicHash::hash(key.toUtf8(), QCryptographicHash::Sha256);
    return QString::fromLatin1(hash.toHex());
}

QString IcsImportService::detectEventType(const ParsedEvent& input) const {
    const QString summary = input.title.toLower();
    const QString description = input.description.toLower();
    for (const QString& cat : input.categories) {
        const QString lower = cat.toLower();
        if (lower.contains(QStringLiteral("exam")) || lower.contains(QStringLiteral("klausur")) || lower.contains(QStringLiteral("prüfung")) || lower.contains(QStringLiteral("test"))) {
            return QStringLiteral("exam");
        }
    }
    if (summary.contains(QStringLiteral("klausur")) || summary.contains(QStringLiteral("prüfung")) || summary.contains(QStringLiteral("schulaufgabe")) || description.contains(QStringLiteral("klausur"))) {
        return QStringLiteral("exam");
    }
    if (summary.contains(QStringLiteral("vertretung")) || description.contains(QStringLiteral("vertretung"))) {
        return QStringLiteral("substitution");
    }
    if (summary.contains(QStringLiteral("frei")) || summary.contains(QStringLiteral("ferien"))) {
        return QStringLiteral("other");
    }
    return QStringLiteral("lesson");
}
*** End of File
