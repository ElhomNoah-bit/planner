#include "core/PriorityRules.h"
#include "core/Task.h"
#include "models/EventModel.h"

#include <QDate>
#include <QDateTime>
#include <QTime>
#include <QTimeZone>

#include <iostream>
#include <optional>
#include <string>
#include <vector>

namespace {
struct TaskCase {
    std::string description;
    int daysOffset;
    bool done = false;
    Priority expected;
};

struct EventCase {
    std::string description;
    std::optional<QDate> dueDate;
    std::optional<QDate> startDate;
    bool done = false;
    Priority expected;
};

void reportResult(const std::string& description, bool passed, const char* expected, const char* actual) {
    std::cout << (passed ? "[PASS] " : "[FAIL] ") << description
              << " | expected=" << expected
              << " | actual=" << actual << '\n';
}

const char* priorityName(Priority priority) {
    switch (priority) {
    case Priority::Low:
        return "Low";
    case Priority::Medium:
        return "Medium";
    case Priority::High:
        return "High";
    }
    return "Unknown";
}

std::optional<QDate> shiftedDate(const QDate& base, int offset) {
    if (!base.isValid()) {
        return std::nullopt;
    }
    return base.addDays(offset);
}

Priority computeTaskPriority(const TaskCase& testCase, const QDate& today) {
    Task task;
    task.date = today.addDays(testCase.daysOffset);
    task.done = testCase.done;
    const std::optional<QDate> dueDate = task.date.isValid() ? std::optional<QDate>(task.date) : std::nullopt;
    return priority::priorityForDeadline(dueDate, task.done, today, Priority::Low);
}

Priority computeEventPriority(const EventCase& testCase, const QDate& today) {
    EventRecord record;
    record.isDone = testCase.done;
    if (testCase.dueDate.has_value()) {
        record.due = QDateTime(*testCase.dueDate, QTime(23, 59), QTimeZone::systemTimeZone());
    }
    if (testCase.startDate.has_value()) {
        record.start = QDateTime(*testCase.startDate, QTime(9, 0), QTimeZone::systemTimeZone());
    }
    const Priority result = priority::priorityForDeadline(testCase.dueDate ? testCase.dueDate : testCase.startDate,
                                                          record.isDone,
                                                          today,
                                                          Priority::Medium);
    return result;
}

} // namespace

int main() {
    const QDate today(2024, 1, 15);
    bool success = true;

    std::cout << "=== Priority rules: task scenarios ===\n";
    const std::vector<TaskCase> taskTests = {
        {"Done task", 0, true, Priority::Low},
        {"Overdue task", -1, false, Priority::High},
        {"Due today", 0, false, Priority::High},
        {"Due tomorrow", 1, false, Priority::Medium},
        {"Due in future", 7, false, Priority::Low},
    };

    for (const auto& test : taskTests) {
        const Priority result = computeTaskPriority(test, today);
        const bool passed = result == test.expected;
        reportResult(test.description, passed, priorityName(test.expected), priorityName(result));
        success = success && passed;
    }

    std::cout << "\n=== Priority rules: event scenarios ===\n";
    const std::vector<EventCase> eventTests = {
        {"Done event", shiftedDate(today, 0), std::nullopt, true, Priority::Low},
        {"Overdue event", shiftedDate(today, -2), shiftedDate(today, -2), false, Priority::High},
        {"Due via start date", std::nullopt, shiftedDate(today, 0), false, Priority::High},
        {"Due tomorrow via start", std::nullopt, shiftedDate(today, 1), false, Priority::Medium},
        {"Future event", shiftedDate(today, 5), shiftedDate(today, 5), false, Priority::Low},
        {"No dates defaults to medium", std::nullopt, std::nullopt, false, Priority::Medium},
    };

    for (const auto& test : eventTests) {
        const Priority result = computeEventPriority(test, today);
        const bool passed = result == test.expected;
        reportResult(test.description, passed, priorityName(test.expected), priorityName(result));
        success = success && passed;
    }

    std::cout << '\n' << (success ? "All priority rule tests passed." : "Priority rule tests failed.") << '\n';
    return success ? 0 : 1;
}
