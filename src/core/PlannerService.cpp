#include "PlannerService.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QStandardPaths>
#include <QtMath>
#include <algorithm>

namespace {
QJsonObject readJson(const QString& path) {
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly)) return {};
    const auto doc = QJsonDocument::fromJson(f.readAll());
    return doc.object();
}

void writeJson(const QString& path, const QJsonObject& obj) {
    QFile f(path);
    if (!f.open(QIODevice::WriteOnly)) return;
    f.write(QJsonDocument(obj).toJson(QJsonDocument::Indented));
}

QString appDataDir() {
    auto dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (dir.isEmpty()) dir = QDir::homePath() + "/.local/share/NoahPlanner";
    QDir().mkpath(dir);
    return dir;
}

QString iso(const QDate& date) { return date.toString(Qt::ISODate); }
}

PlannerService::PlannerService(QObject* parent) : QObject(parent) {
    m_dataDir = appDataDir();
    ensureSeed();
    loadAll();
}

void PlannerService::ensureSeed() {
    const QStringList files = {"subjects.json", "diagnostics.json", "config.json", "exams.json", "done.json"};
    for (const auto& name : files) {
        const QString target = m_dataDir + "/" + name;
        if (QFileInfo::exists(target)) continue;
        const QString bundled = QCoreApplication::applicationDirPath() + "/data/" + name;
        QDir().mkpath(m_dataDir);
        if (QFileInfo::exists(bundled)) {
            QFile::copy(bundled, target);
            continue;
        }

        if (name == "exams.json") {
            writeJson(target, QJsonObject{{"exams", QJsonArray{}}});
        } else if (name == "done.json") {
            writeJson(target, QJsonObject{{"done", QJsonObject{}}});
        } else {
            writeJson(target, QJsonObject{});
        }
    }
}

bool PlannerService::addOrUpdateExam(const Exam& exam) {
    Exam copy = exam;
    if (copy.id.isEmpty()) copy.id = copy.subjectId + "_" + copy.date.toString(Qt::ISODate);

    bool found = false;
    for (auto& existing : m_exams) {
        if (existing.id == copy.id) {
            existing = copy;
            found = true;
            break;
        }
    }
    if (!found) m_exams.append(copy);

    saveExams();
    emit dataChanged();
    return true;
}

bool PlannerService::removeExam(const QString& id) {
    const int before = m_exams.size();
    m_exams.erase(std::remove_if(m_exams.begin(), m_exams.end(), [&](const Exam& e) {
        return e.id == id;
    }), m_exams.end());

    if (m_exams.size() == before) return false;

    saveExams();
    emit dataChanged();
    return true;
}

void PlannerService::setDone(const QDate& date, int index, bool value) {
    auto& set = m_done[iso(date)];
    if (value) {
        set.insert(index);
    } else {
        set.remove(index);
    }
    saveDone();
    emit dataChanged();
}

bool PlannerService::isDone(const QDate& date, int index) const {
    const auto it = m_done.constFind(iso(date));
    if (it == m_done.cend()) return false;
    return it.value().contains(index);
}

QVector<Task> PlannerService::generateDay(const QDate& date) const {
    QVector<Task> tasks;
    tasks.reserve(8);

    const auto cfg = m_config;
    const int weekday = date.dayOfWeek() - 1;
    const auto dailyCapacityObj = cfg.value("daily_capacity_min").toObject();
    const int capacity = dailyCapacityObj.value(QString::number(weekday)).toInt(0);

    int remaining = capacity;
    if (remaining <= 0) return tasks;

    for (const auto& breakValue : cfg.value("breaks").toArray()) {
        const auto window = breakValue.toString();
        const auto parts = window.split("..");
        if (parts.size() != 2) continue;
        const auto start = QDate::fromString(parts.at(0), Qt::ISODate);
        const auto end = QDate::fromString(parts.at(1), Qt::ISODate);
        if (date >= start && date <= end) return tasks;
    }

    QHash<QString, double> weights;
    for (const auto& subject : m_subjects) {
        weights.insert(subject.id, baseWeightFor(subject.id));
    }

    const auto boostDays = cfg.value("exam_boost_days").toArray();
    const auto boostFactors = cfg.value("exam_boost_factors").toArray();
    for (const auto& exam : m_exams) {
        const int diff = date.daysTo(exam.date);
        for (int i = 0; i < boostDays.size() && i < boostFactors.size(); ++i) {
            if (diff == boostDays.at(i).toInt()) {
                weights[exam.subjectId] = weights.value(exam.subjectId, 1.0) * boostFactors.at(i).toDouble(1.15);
            }
        }
    }

    QList<QString> subjectIds = weights.keys();
    std::sort(subjectIds.begin(), subjectIds.end(), [&](const QString& a, const QString& b) {
        return weights.value(a) > weights.value(b);
    });

    const int maxSlots = cfg.value("max_slots").toInt(3);
    const int slotMin = cfg.value("slot_min").toInt(20);
    const int slotMax = cfg.value("slot_max").toInt(40);

    int placed = 0;
    const int seed = date.toJulianDay();

    for (const auto& subjectId : subjectIds) {
        if (remaining < slotMin || placed >= maxSlots) break;
        if (weights.value(subjectId) < 0.5) continue;

        const int ideal = std::min(slotMax, std::max(slotMin, ((remaining / (maxSlots - placed) + 5) / 10) * 10));

    const Subject subject = subjectById(subjectId);

    Task task;
    task.id = makeTaskId(subjectId, date, placed);
    task.subjectId = subjectId;
    task.title = subject.name;
    task.goal = defaultGoal(subjectId, seed + placed);
    task.durationMinutes = ideal;
    task.date = date;
    task.done = isDone(date, placed);
    task.isExam = false;
    task.color = subject.color;
        task.planIndex = placed;
        task.priority = computePriority(task, QDate::currentDate());

        tasks.append(task);
        remaining -= ideal;
        placed++;
    }

    return tasks;
}

QList<QVector<Task>> PlannerService::generateRange(const QDate& start, const QDate& end) const {
    QList<QVector<Task>> out;
    for (QDate d = start; d <= end; d = d.addDays(1)) {
        out.append(generateDay(d));
    }
    return out;
}

void PlannerService::loadAll() {
    loadSubjects();
    loadDiagnostics();
    loadConfig();
    loadExams();
    loadDone();
}

void PlannerService::loadSubjects() {
    const auto obj = readJson(m_dataDir + "/subjects.json");
    m_subjects.clear();
    for (const auto& value : obj.value("subjects").toArray()) {
        const auto item = value.toObject();
        Subject subject;
        subject.id = item.value("id").toString();
        subject.name = item.value("name").toString();
        subject.weight = item.value("weight").toDouble(1.0);
        subject.color = QColor(item.value("color").toString("#999"));
        m_subjects.append(subject);
    }
}

void PlannerService::loadDiagnostics() {
    const auto obj = readJson(m_dataDir + "/diagnostics.json");
    m_levels.clear();
    const auto levelsObj = obj.value("levels").toObject();
    for (const auto& key : levelsObj.keys()) {
        m_levels.insert(key, levelsObj.value(key).toString("B"));
    }
}

void PlannerService::loadConfig() {
    m_config = readJson(m_dataDir + "/config.json");
}

void PlannerService::loadExams() {
    m_exams.clear();
    const auto obj = readJson(m_dataDir + "/exams.json");
    for (const auto& value : obj.value("exams").toArray()) {
        const auto item = value.toObject();
        Exam exam;
        exam.id = item.value("id").toString();
        exam.subjectId = item.value("subject").toString();
        exam.date = QDate::fromString(item.value("date").toString(), Qt::ISODate);
        exam.weightBoost = item.value("weight_boost").toDouble(1.3);
        for (const auto& topic : item.value("topics").toArray()) {
            exam.topics.append(topic.toString());
        }
        m_exams.append(exam);
    }
}

void PlannerService::loadDone() {
    m_done.clear();
    const auto obj = readJson(m_dataDir + "/done.json");
    const auto doneObj = obj.value("done").toObject();
    for (const auto& key : doneObj.keys()) {
        QSet<int> set;
        for (const auto& value : doneObj.value(key).toArray()) {
            set.insert(value.toInt());
        }
        m_done.insert(key, set);
    }
}

void PlannerService::saveExams() const {
    QJsonArray examsArray;
    for (const auto& exam : m_exams) {
        examsArray.append(QJsonObject{
            {"id", exam.id},
            {"subject", exam.subjectId},
            {"date", exam.date.toString(Qt::ISODate)},
            {"topics", QJsonArray::fromStringList(exam.topics)},
            {"weight_boost", exam.weightBoost}
        });
    }
    writeJson(m_dataDir + "/exams.json", QJsonObject{{"exams", examsArray}});
}

void PlannerService::saveDone() const {
    QJsonObject doneObj;
    for (auto it = m_done.constBegin(); it != m_done.constEnd(); ++it) {
        QJsonArray indices;
        for (int index : it.value()) indices.append(index);
        doneObj.insert(it.key(), indices);
    }
    writeJson(m_dataDir + "/done.json", QJsonObject{{"done", doneObj}});
}

double PlannerService::baseWeightFor(const QString& subjectId) const {
    double base = 1.0;
    for (const auto& subject : m_subjects) {
        if (subject.id == subjectId) {
            base = subject.weight;
            break;
        }
    }

    const QString level = m_levels.value(subjectId, "B");
    const auto factors = m_config.value("level_factor").toObject();
    return base * factors.value(level).toDouble(1.0);
}

QString PlannerService::defaultGoal(const QString& subjectId, int seed) const {
    const QHash<QString, QStringList> goals = {
        {"en", {"Reading 250w + 4Q", "Passive drill 12x", "100-word email (clean)", "Listening 10m + notes"}},
        {"de", {"Zusammenfassung 120w", "Erörterungsbausteine", "Kommasetzung-Drill", "Kurzgeschichte deuten"}},
        {"ma", {"Prozent-Drill 10x", "Lineare Funktionen 6x", "Gemischte Aufgaben 15m", "Statistik: Mittel/Median"}},
        {"wpf", {"Werkstoffeigenschaften", "Schaltplan skizzieren", "Projektplanung 20m", "Zeichnungsnorm Basics"}},
        {"bio", {"Zelle+Labels", "DNA–Gen–Chromosom", "Mendel Beispiel", "Nahrungsnetz 6 Pfeile"}},
        {"ch", {"Teilchenmodell", "Reaktionsgleichungen 5x", "Säure/Base pH", "Alltagschemie Analyse"}},
        {"ph", {"Ohmsches Gesetz 8x", "Dichte/Druck 8x", "Arbeit/Leistung 8x", "Optik Grundbegriffe"}},
        {"gk", {"Grundrechte + Beispiele", "Gewaltenteilung + Sinn", "Wahlen kurz", "EU-Institutionen"}},
        {"geo", {"Maßstab-Umrechnung", "Sektoren + Bsp.", "Klimadiagramm deuten", "Karte lesen (Übung)"}},
        {"ges", {"Zeitstrahl 1850–1950", "Weimar→NS 12 St.", "Begriffe erklären", "Quellenarten kurz"}},
        {"bk", {"Ein-Punkt-Perspektive", "Zwei-Punkt-Perspektive", "Farbkontraste", "Bildanalyse kurz"}},
        {"mu", {"Hören & benennen", "Rhythmus zählen", "Intervalle Basis", "Formenlehre kurz"}},
        {"wbs", {"Budget & Vertrag", "Sozialversicherungen", "Bewerbungskern", "Wirtschaftskreislauf"}},
        {"eth", {"Dilemma & Begründung", "Theorien-Vergleich", "Argumentationskette", "Fallanalyse kurz"}},
        {"sp", {"Regelkunde", "Trainingslehre", "Ernährung/Reg.", "Pulsbereiche"}}
    };

    const auto list = goals.value(subjectId, QStringList{"Übung 20–30m"});
    if (list.isEmpty()) return "Übung 20–30m";
    return list.at(seed % list.size());
}

Subject PlannerService::subjectById(const QString& subjectId) const {
    for (const auto& subject : m_subjects) {
        if (subject.id == subjectId) return subject;
    }
    Subject fallback;
    fallback.id = subjectId;
    fallback.name = subjectId;
    fallback.color = QColor("#606060");
    return fallback;
}

QString PlannerService::makeTaskId(const QString& subjectId, const QDate& date, int index) const {
    return iso(date) + ":" + subjectId + ":" + QString::number(index);
}

Priority PlannerService::computePriority(const Task& task, const QDate& currentDate) const {
    // Load configurable weights from settings
    const auto priorityConfig = m_config.value("priority_weights").toObject();
    const double overdueWeight = priorityConfig.value("overdue").toDouble(3.0);
    const double dueSoonWeight = priorityConfig.value("due_soon").toDouble(2.0);
    const double estimateWeight = priorityConfig.value("estimate").toDouble(1.0);
    const int dueSoonThresholdHours = priorityConfig.value("due_soon_hours").toInt(48);

    // Calculate days until due
    const int daysUntilDue = currentDate.daysTo(task.date);
    const int hoursUntilDue = daysUntilDue * 24;

    // If task is done, always low priority
    if (task.done) {
        return Priority::Low;
    }

    // Overdue tasks are always high priority
    if (daysUntilDue < 0) {
        return Priority::High;
    }

    // Calculate priority score
    double score = 0.0;

    // Due soon contribution
    if (hoursUntilDue <= dueSoonThresholdHours && hoursUntilDue >= 0) {
        // Linear scaling: closer deadline = higher score
        const double dueSoonFactor = 1.0 - (static_cast<double>(hoursUntilDue) / dueSoonThresholdHours);
        score += dueSoonWeight * dueSoonFactor;
    }

    // Estimate/duration contribution - longer tasks get slightly higher priority
    if (task.durationMinutes > 0) {
        const double normalizedDuration = std::min(1.0, task.durationMinutes / 60.0); // Cap at 60 minutes
        score += estimateWeight * normalizedDuration * 0.5;
    }

    // Threshold mapping to priority levels
    const double highThreshold = priorityConfig.value("high_threshold").toDouble(1.5);
    const double mediumThreshold = priorityConfig.value("medium_threshold").toDouble(0.5);

    if (score >= highThreshold) {
        return Priority::High;
    } else if (score >= mediumThreshold) {
        return Priority::Medium;
    }

    return Priority::Low;
}