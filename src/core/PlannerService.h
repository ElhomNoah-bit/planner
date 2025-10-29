#pragma once

#include "Task.h"
#include "Subject.h"
#include "Exam.h"

#include <QHash>
#include <QJsonObject>
#include <QList>
#include <QObject>
#include <QSet>
#include <QVector>

class PlannerService : public QObject {
    Q_OBJECT
public:
    explicit PlannerService(QObject* parent = nullptr);

    QString dataDir() const { return m_dataDir; }
    void ensureSeed();

    QList<Subject> subjects() const { return m_subjects; }
    QHash<QString, QString> levels() const { return m_levels; }
    QJsonObject config() const { return m_config; }
    QList<Exam> exams() const { return m_exams; }

    bool addOrUpdateExam(const Exam& exam);
    bool removeExam(const QString& id);
    void setDone(const QDate& date, int index, bool value);
    bool isDone(const QDate& date, int index) const;

    QVector<Task> generateDay(const QDate& date) const;
    QList<QVector<Task>> generateRange(const QDate& start, const QDate& end) const;

    Priority computePriority(const Task& task, const QDate& currentDate) const;

Q_SIGNALS:
    void dataChanged();

private:
    QString m_dataDir;
    QList<Subject> m_subjects;
    QHash<QString, QString> m_levels;
    QJsonObject m_config;
    QList<Exam> m_exams;
    QHash<QString, QSet<int>> m_done; // date ISO -> completed slot indices

    void loadAll();
    void loadSubjects();
    void loadDiagnostics();
    void loadConfig();
    void loadExams();
    void loadDone();
    void saveExams() const;
    void saveDone() const;

    double baseWeightFor(const QString& subjectId) const;
    QString defaultGoal(const QString& subjectId, int variantSeed = 0) const;
    Subject subjectById(const QString& subjectId) const;
    QString makeTaskId(const QString& subjectId, const QDate& date, int index) const;
};
