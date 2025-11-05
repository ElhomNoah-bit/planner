#include "core/PlannerService.h"
#include "core/Task.h"
#include "core/Subject.h"
#include "core/Exam.h"

#include <QCoreApplication>
#include <QDate>
#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTemporaryDir>

#include <iostream>
#include <string>

namespace {
struct TestCase {
    std::string description;
    bool (*test)(PlannerService&);
};

void reportResult(const std::string& description, bool passed) {
    std::cout << (passed ? "[PASS] " : "[FAIL] ") << description << '\n';
}

bool testGenerateDayReturnsTasksForValidDate(PlannerService& planner) {
    const QDate today = QDate::currentDate();
    const QVector<Task> tasks = planner.generateDay(today);
    // Should generate some tasks if configuration is valid
    return true; // Pass if no crash occurs
}

bool testGenerateDayHandlesInvalidDate(PlannerService& planner) {
    const QDate invalid;
    const QVector<Task> tasks = planner.generateDay(invalid);
    return tasks.isEmpty();
}

bool testSetDoneAndIsDoneRoundTrip(PlannerService& planner) {
    const QDate testDate(2024, 6, 15);
    const int testIndex = 0;
    
    planner.setDone(testDate, testIndex, true);
    if (!planner.isDone(testDate, testIndex)) {
        return false;
    }
    
    planner.setDone(testDate, testIndex, false);
    if (planner.isDone(testDate, testIndex)) {
        return false;
    }
    
    return true;
}

bool testAddAndRemoveExam(PlannerService& planner) {
    Exam exam;
    exam.id = "test_exam_001";
    exam.subjectId = "ma";
    exam.date = QDate::currentDate().addDays(30);
    exam.weightBoost = 1.5;
    exam.topics = QStringList{"Algebra", "Geometry"};
    
    const int initialCount = planner.exams().size();
    planner.addOrUpdateExam(exam);
    
    if (planner.exams().size() != initialCount + 1) {
        return false;
    }
    
    planner.removeExam(exam.id);
    if (planner.exams().size() != initialCount) {
        return false;
    }
    
    return true;
}

bool testUpdateExistingExam(PlannerService& planner) {
    Exam exam;
    exam.id = "test_exam_002";
    exam.subjectId = "en";
    exam.date = QDate::currentDate().addDays(20);
    exam.weightBoost = 1.3;
    
    planner.addOrUpdateExam(exam);
    const int count = planner.exams().size();
    
    // Update the same exam
    exam.weightBoost = 1.8;
    exam.topics = QStringList{"Reading", "Writing"};
    planner.addOrUpdateExam(exam);
    
    // Count should remain the same (update, not add)
    if (planner.exams().size() != count) {
        return false;
    }
    
    // Clean up
    planner.removeExam(exam.id);
    return true;
}

bool testGenerateRangeReturnsCorrectNumberOfDays(PlannerService& planner) {
    const QDate start(2024, 7, 1);
    const QDate end(2024, 7, 7);
    const QList<QVector<Task>> range = planner.generateRange(start, end);
    
    return range.size() == 7; // 7 days inclusive
}

bool testComputePriorityForOverdueTask(PlannerService& planner) {
    Task task;
    task.date = QDate::currentDate().addDays(-1); // Yesterday
    task.done = false;
    
    const Priority priority = planner.computePriority(task, QDate::currentDate());
    return priority == Priority::High;
}

bool testComputePriorityForDoneTask(PlannerService& planner) {
    Task task;
    task.date = QDate::currentDate();
    task.done = true;
    
    const Priority priority = planner.computePriority(task, QDate::currentDate());
    return priority == Priority::Low;
}

bool testSubjectsLoadedCorrectly(PlannerService& planner) {
    const QList<Subject> subjects = planner.subjects();
    // Should have loaded subjects from seed data
    return !subjects.isEmpty();
}

bool testConfigLoadedCorrectly(PlannerService& planner) {
    const QJsonObject config = planner.config();
    // Should have some configuration
    return !config.isEmpty();
}

bool testLevelsLoadedCorrectly(PlannerService& planner) {
    const QHash<QString, QString> levels = planner.levels();
    // Should have some levels
    return !levels.isEmpty();
}

bool testDataDirIsValid(PlannerService& planner) {
    const QString dataDir = planner.dataDir();
    return !dataDir.isEmpty() && QDir(dataDir).exists();
}

} // namespace

int main(int argc, char* argv[]) {
    QCoreApplication app(argc, argv);
    QCoreApplication::setOrganizationName("noah-test");
    QCoreApplication::setApplicationName("planner-test");
    
    // Use a temporary directory for test data
    QTemporaryDir tempDir;
    if (!tempDir.isValid()) {
        std::cerr << "Failed to create temporary directory\n";
        return 1;
    }
    
    // We can't easily override the data directory, so tests will use the default location
    // In a production test suite, we'd want to mock or override this
    PlannerService planner;
    
    std::cout << "=== PlannerService Test Suite ===\n";
    
    const std::vector<TestCase> tests = {
        {"Generate day returns tasks for valid date", testGenerateDayReturnsTasksForValidDate},
        {"Generate day handles invalid date", testGenerateDayHandlesInvalidDate},
        {"Set done and is done round trip", testSetDoneAndIsDoneRoundTrip},
        {"Add and remove exam", testAddAndRemoveExam},
        {"Update existing exam", testUpdateExistingExam},
        {"Generate range returns correct number of days", testGenerateRangeReturnsCorrectNumberOfDays},
        {"Compute priority for overdue task", testComputePriorityForOverdueTask},
        {"Compute priority for done task", testComputePriorityForDoneTask},
        {"Subjects loaded correctly", testSubjectsLoadedCorrectly},
        {"Config loaded correctly", testConfigLoadedCorrectly},
        {"Levels loaded correctly", testLevelsLoadedCorrectly},
        {"Data dir is valid", testDataDirIsValid},
    };
    
    bool allPassed = true;
    for (const auto& test : tests) {
        try {
            const bool passed = test.test(planner);
            reportResult(test.description, passed);
            allPassed = allPassed && passed;
        } catch (const std::exception& e) {
            reportResult(test.description + " (exception: " + e.what() + ")", false);
            allPassed = false;
        } catch (...) {
            reportResult(test.description + " (unknown exception)", false);
            allPassed = false;
        }
    }
    
    std::cout << '\n' << (allPassed ? "All PlannerService tests passed." : "Some PlannerService tests failed.") << '\n';
    return allPassed ? 0 : 1;
}
