#include "core/PlannerService.h"
#include "core/SpacedRepetitionService.h"
#include "core/QuickAddParser.h"
#include "core/PriorityRules.h"

#include <QCoreApplication>
#include <QDate>
#include <QDateTime>
#include <QTemporaryDir>

#include <iostream>
#include <string>

namespace {
struct TestCase {
    std::string description;
    bool (*test)();
};

void reportResult(const std::string& description, bool passed) {
    std::cout << (passed ? "[PASS] " : "[FAIL] ") << description << '\n';
}

// Edge case tests for date handling
bool testInvalidDateHandling() {
    QDate invalid;
    if (invalid.isValid()) {
        return false;
    }
    
    // Creating a date with invalid values should return invalid date
    QDate bad(0, 0, 0);
    if (bad.isValid()) {
        return false;
    }
    
    return true;
}

bool testLeapYearHandling() {
    // 2024 is a leap year
    QDate leap(2024, 2, 29);
    if (!leap.isValid()) {
        return false;
    }
    
    // 2023 is not a leap year
    QDate notLeap(2023, 2, 29);
    if (notLeap.isValid()) {
        return false;
    }
    
    return true;
}

bool testDateBoundaries() {
    // Test minimum date
    QDate minDate(1, 1, 1);
    if (!minDate.isValid()) {
        return false;
    }
    
    // Test maximum reasonable date
    QDate maxDate(9999, 12, 31);
    if (!maxDate.isValid()) {
        return false;
    }
    
    return true;
}

bool testDateArithmetic() {
    QDate start(2024, 1, 31);
    QDate end = start.addDays(1);
    
    // Should be February 1st
    if (end.month() != 2 || end.day() != 1) {
        return false;
    }
    
    // Test negative days
    QDate before = start.addDays(-31);
    if (before.month() != 12 || before.day() != 31 || before.year() != 2023) {
        return false;
    }
    
    return true;
}

// Edge cases for priority rules
bool testPriorityWithInvalidDate() {
    const std::optional<QDate> invalid;
    const Priority priority = priority::priorityForDeadline(invalid, false, QDate::currentDate());
    
    // Should return default priority
    return priority == Priority::Low;
}

bool testPriorityWithFarFutureDate() {
    const QDate future(9999, 12, 31);
    const Priority priority = priority::priorityForDeadline(future, false, QDate::currentDate());
    
    // Should be Low priority
    return priority == Priority::Low;
}

bool testPriorityWithFarPastDate() {
    const QDate past(1900, 1, 1);
    const Priority priority = priority::priorityForDeadline(past, false, QDate::currentDate());
    
    // Should be High priority (overdue)
    return priority == Priority::High;
}

// Edge cases for spaced repetition
bool testSpacedRepetitionWithInvalidQuality() {
    QTemporaryDir tempDir;
    SpacedRepetitionService service(tempDir.path());
    
    const QString id = service.addReview("test", "Test topic");
    
    // Quality must be 0-5
    if (service.recordReview(id, -1)) {
        return false;
    }
    
    if (service.recordReview(id, 6)) {
        return false;
    }
    
    if (service.recordReview(id, 100)) {
        return false;
    }
    
    return true;
}

bool testSpacedRepetitionWithEmptyTopic() {
    QTemporaryDir tempDir;
    SpacedRepetitionService service(tempDir.path());
    
    const QString id = service.addReview("test", "");
    
    // Should still create a review even with empty topic
    return !id.isEmpty();
}

bool testSpacedRepetitionIntervalBoundaries() {
    QTemporaryDir tempDir;
    SpacedRepetitionService service(tempDir.path());
    
    // Test minimum interval
    service.setInitialInterval(1);
    const QString id1 = service.addReview("test", "Min interval");
    
    // Test large interval (shouldn't crash)
    service.setInitialInterval(365);
    const QString id2 = service.addReview("test", "Max interval");
    
    return !id1.isEmpty() && !id2.isEmpty();
}

// Edge cases for quick add parser
bool testQuickAddWithEmptyString() {
    QuickAddParser parser;
    const QDateTime ref = QDateTime::currentDateTime();
    const QuickAddResult result = parser.parse("", ref);
    
    // Should return error for empty input
    return !result.error.isEmpty();
}

bool testQuickAddWithOnlyWhitespace() {
    QuickAddParser parser;
    const QDateTime ref = QDateTime::currentDateTime();
    const QuickAddResult result = parser.parse("   \n\t   ", ref);
    
    // Should return error for empty input after trimming
    return !result.error.isEmpty();
}

bool testQuickAddWithVeryLongInput() {
    QuickAddParser parser;
    const QDateTime ref = QDateTime::currentDateTime();
    QString longInput(10000, 'a');  // 10,000 character string
    
    const QuickAddResult result = parser.parse(longInput, ref);
    
    // Should not crash and should create a title
    return result.error.isEmpty();
}

bool testQuickAddWithSpecialCharacters() {
    QuickAddParser parser;
    const QDateTime ref = QDateTime::currentDateTime();
    const QuickAddResult result = parser.parse("Meeting @ café #tëst !high", ref);
    
    // Should handle unicode characters
    return result.error.isEmpty();
}

bool testQuickAddWithInvalidTime() {
    QuickAddParser parser;
    const QDateTime ref = QDateTime::currentDateTime();
    const QuickAddResult result = parser.parse("Meeting at 25:99", ref);
    
    // Should still create an event, possibly with default time
    return result.error.isEmpty();
}

// Edge cases for PlannerService
bool testGenerateDayWithZeroCapacity() {
    PlannerService planner;
    
    // Sunday typically has 0 capacity in default config
    QDate sunday(2024, 6, 16);  // A Sunday
    const QVector<Task> tasks = planner.generateDay(sunday);
    
    // Should return empty or small number of tasks
    return true;  // Just check it doesn't crash
}

bool testGenerateDayWithInvalidDate() {
    PlannerService planner;
    
    QDate invalid;
    const QVector<Task> tasks = planner.generateDay(invalid);
    
    // Should return empty vector
    return tasks.isEmpty();
}

bool testGenerateRangeWithInvertedDates() {
    PlannerService planner;
    
    const QDate start(2024, 6, 15);
    const QDate end(2024, 6, 10);  // End before start
    const QList<QVector<Task>> range = planner.generateRange(start, end);
    
    // Should return empty list
    return range.isEmpty();
}

bool testExamWithInvalidDate() {
    PlannerService planner;
    
    Exam exam;
    exam.id = "test_invalid_exam";
    exam.subjectId = "ma";
    exam.date = QDate();  // Invalid date
    exam.weightBoost = 1.5;
    
    // Should handle gracefully (either reject or accept with warning)
    planner.addOrUpdateExam(exam);
    
    // Just verify it doesn't crash
    return true;
}

} // namespace

int main(int argc, char* argv[]) {
    QCoreApplication app(argc, argv);
    QCoreApplication::setOrganizationName("noah-test");
    QCoreApplication::setApplicationName("edge-cases-test");
    
    std::cout << "=== Edge Cases Test Suite ===\n";
    
    const std::vector<TestCase> tests = {
        // Date handling
        {"Invalid date handling", testInvalidDateHandling},
        {"Leap year handling", testLeapYearHandling},
        {"Date boundaries", testDateBoundaries},
        {"Date arithmetic", testDateArithmetic},
        
        // Priority rules
        {"Priority with invalid date", testPriorityWithInvalidDate},
        {"Priority with far future date", testPriorityWithFarFutureDate},
        {"Priority with far past date", testPriorityWithFarPastDate},
        
        // Spaced repetition
        {"Spaced repetition with invalid quality", testSpacedRepetitionWithInvalidQuality},
        {"Spaced repetition with empty topic", testSpacedRepetitionWithEmptyTopic},
        {"Spaced repetition interval boundaries", testSpacedRepetitionIntervalBoundaries},
        
        // Quick add parser
        {"Quick add with empty string", testQuickAddWithEmptyString},
        {"Quick add with only whitespace", testQuickAddWithOnlyWhitespace},
        {"Quick add with very long input", testQuickAddWithVeryLongInput},
        {"Quick add with special characters", testQuickAddWithSpecialCharacters},
        {"Quick add with invalid time", testQuickAddWithInvalidTime},
        
        // Planner service
        {"Generate day with zero capacity", testGenerateDayWithZeroCapacity},
        {"Generate day with invalid date", testGenerateDayWithInvalidDate},
        {"Generate range with inverted dates", testGenerateRangeWithInvertedDates},
        {"Exam with invalid date", testExamWithInvalidDate},
    };
    
    bool allPassed = true;
    for (const auto& test : tests) {
        try {
            const bool passed = test.test();
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
    
    std::cout << '\n' << (allPassed ? "All edge case tests passed." : "Some edge case tests failed.") << '\n';
    return allPassed ? 0 : 1;
}
