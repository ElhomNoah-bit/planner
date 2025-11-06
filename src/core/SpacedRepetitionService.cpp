#include "SpacedRepetitionService.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QtMath>

namespace {
QJsonObject readJson(const QString& path) {
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly)) {
        qWarning() << "[SpacedRepetitionService] Failed to open file for reading:" << path << f.errorString();
        return {};
    }
    const QByteArray data = f.readAll();
    const auto doc = QJsonDocument::fromJson(data);
    if (doc.isNull()) {
        qWarning() << "[SpacedRepetitionService] Failed to parse JSON from:" << path;
        return {};
    }
    return doc.object();
}

void writeJson(const QString& path, const QJsonObject& obj) {
    QFile f(path);
    if (!f.open(QIODevice::WriteOnly)) {
        qWarning() << "[SpacedRepetitionService] Failed to open file for writing:" << path << f.errorString();
        return;
    }
    const QByteArray data = QJsonDocument(obj).toJson(QJsonDocument::Indented);
    const qint64 written = f.write(data);
    if (written != data.size()) {
        qWarning() << "[SpacedRepetitionService] Incomplete write to:" << path;
    }
}
}

SpacedRepetitionService::SpacedRepetitionService(const QString& dataDir, QObject* parent)
    : QObject(parent), m_dataDir(dataDir) {
    if (!dataDir.isEmpty()) {
        load();
    }
}

void SpacedRepetitionService::setDataDirectory(const QString& dataDir) {
    m_dataDir = dataDir;
    load();
}

QList<Review> SpacedRepetitionService::reviewsForSubject(const QString& subjectId) const {
    QList<Review> result;
    for (const auto& review : m_reviews) {
        if (review.subjectId == subjectId) {
            result.append(review);
        }
    }
    return result;
}

QList<Review> SpacedRepetitionService::dueReviews(const QDate& date) const {
    QList<Review> result;
    for (const auto& review : m_reviews) {
        if (review.nextReviewDate <= date) {
            result.append(review);
        }
    }
    return result;
}

QList<Review> SpacedRepetitionService::reviewsOnDate(const QDate& date) const {
    QList<Review> result;
    for (const auto& review : m_reviews) {
        if (review.nextReviewDate == date) {
            result.append(review);
        }
    }
    return result;
}

QString SpacedRepetitionService::addReview(const QString& subjectId, const QString& topic) {
    Review review;
    review.id = generateReviewId(subjectId, topic);
    review.subjectId = subjectId;
    review.topic = topic;
    review.lastReviewDate = QDate::currentDate();
    const bool scheduleToday = m_initialInterval <= 1;
    review.nextReviewDate = scheduleToday
        ? QDate::currentDate()
        : QDate::currentDate().addDays(m_initialInterval);
    review.repetitionNumber = 0;
    review.easeFactor = 2.5;
    review.intervalDays = qMax(1, m_initialInterval);
    review.quality = 0;

    m_reviews.append(review);
    save();
    emit reviewsChanged();

    return review.id;
}

bool SpacedRepetitionService::recordReview(const QString& reviewId, int quality) {
    if (quality < 0 || quality > 5) {
        return false;
    }

    for (auto& review : m_reviews) {
        if (review.id == reviewId) {
            calculateNextReview(review, quality);
            save();
            emit reviewsChanged();
            return true;
        }
    }

    return false;
}

bool SpacedRepetitionService::removeReview(const QString& reviewId) {
    const int before = m_reviews.size();
    m_reviews.erase(std::remove_if(m_reviews.begin(), m_reviews.end(),
        [&](const Review& r) { return r.id == reviewId; }), m_reviews.end());

    if (m_reviews.size() == before) {
        return false;
    }

    save();
    emit reviewsChanged();
    return true;
}

void SpacedRepetitionService::setInitialInterval(int days) {
    m_initialInterval = qMax(1, days);
}

void SpacedRepetitionService::setEaseFactorModifier(double modifier) {
    m_easeModifier = qMax(0.1, modifier);
}

void SpacedRepetitionService::load() {
    if (m_dataDir.isEmpty()) {
        m_reviews.clear();
        return;
    }

    m_reviews.clear();

    const QString path = QDir(m_dataDir).filePath(QStringLiteral("reviews.json"));

    if (!QFileInfo::exists(path)) {
        QDir().mkpath(m_dataDir);
        writeJson(path, QJsonObject{{QStringLiteral("reviews"), QJsonArray{}}});
        return;
    }

    QJsonObject root = readJson(path);
    if (root.isEmpty()) {
        root.insert(QStringLiteral("reviews"), QJsonArray());
    }

    QJsonArray reviewsArray = root["reviews"].toArray();
    for (const auto& value : reviewsArray) {
        QJsonObject obj = value.toObject();
        Review review;
        review.id = obj["id"].toString();
        review.subjectId = obj["subjectId"].toString();
        review.topic = obj["topic"].toString();
        review.lastReviewDate = QDate::fromString(obj["lastReviewDate"].toString(), Qt::ISODate);
        review.nextReviewDate = QDate::fromString(obj["nextReviewDate"].toString(), Qt::ISODate);
        review.repetitionNumber = obj["repetitionNumber"].toInt();
        review.easeFactor = obj["easeFactor"].toDouble(2.5);
        review.intervalDays = obj["intervalDays"].toInt();
        review.quality = obj["quality"].toInt();

        m_reviews.append(review);
    }
}

void SpacedRepetitionService::save() const {
    QJsonArray reviewsArray;
    for (const auto& review : m_reviews) {
        QJsonObject obj;
        obj["id"] = review.id;
        obj["subjectId"] = review.subjectId;
        obj["topic"] = review.topic;
        obj["lastReviewDate"] = review.lastReviewDate.toString(Qt::ISODate);
        obj["nextReviewDate"] = review.nextReviewDate.toString(Qt::ISODate);
        obj["repetitionNumber"] = review.repetitionNumber;
        obj["easeFactor"] = review.easeFactor;
        obj["intervalDays"] = review.intervalDays;
        obj["quality"] = review.quality;

        reviewsArray.append(obj);
    }

    QJsonObject root;
    root["reviews"] = reviewsArray;

    const QString path = QDir(m_dataDir).filePath(QStringLiteral("reviews.json"));
    QDir().mkpath(m_dataDir);
    writeJson(path, root);
}

void SpacedRepetitionService::calculateNextReview(Review& review, int quality) {
    // SM-2 Algorithm implementation
    review.lastReviewDate = QDate::currentDate();
    review.quality = quality;

    // If quality < 3, reset the review (start over)
    if (quality < 3) {
        review.repetitionNumber = 0;
        review.intervalDays = qMax(1, m_initialInterval);
        review.nextReviewDate = review.lastReviewDate.addDays(review.intervalDays);
        return;
    }

    // Update ease factor based on quality
    // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
    double efChange = 0.1 - (5.0 - quality) * (0.08 + (5.0 - quality) * 0.02);
    review.easeFactor = qMax(1.3, review.easeFactor + efChange * m_easeModifier);

    // Calculate next interval
    if (review.repetitionNumber == 0) {
        review.intervalDays = qMax(1, m_initialInterval);
    } else if (review.repetitionNumber == 1) {
        review.intervalDays = 6;
    } else {
        review.intervalDays = qRound(review.intervalDays * review.easeFactor);
    }

    review.repetitionNumber++;
    review.nextReviewDate = review.lastReviewDate.addDays(review.intervalDays);
}

QString SpacedRepetitionService::generateReviewId(const QString& subjectId, const QString& topic) const {
    QString baseId = subjectId + "_" + topic;
    baseId.replace(" ", "_");
    
    // Check for uniqueness and append number if needed
    QString id = baseId;
    int counter = 1;
    while (true) {
        bool unique = true;
        for (const auto& review : m_reviews) {
            if (review.id == id) {
                unique = false;
                break;
            }
        }
        if (unique) break;
        id = baseId + "_" + QString::number(counter++);
    }

    return id;
}
