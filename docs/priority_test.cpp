/**
 * Priority Computation Test Suite
 * 
 * This file tests the automatic priority computation logic for tasks/events.
 * 
 * Priority Levels:
 * - 0: Low (Green)
 * - 1: Medium (Orange)
 * - 2: High (Red)
 * 
 * Rules:
 * 1. Done tasks are always Low priority
 * 2. Overdue tasks (negative days) are always High priority
 * 3. Due today (0 days) is High priority
 * 4. Due tomorrow (1 day) is Medium priority
 * 5. Due in 2+ days is Low priority
 */

#include <iostream>
#include <cassert>
#include <string>
#include <vector>

enum class Priority {
    Low = 0,
    Medium = 1,
    High = 2
};

struct TestCase {
    std::string description;
    int daysUntilDue;
    bool isDone;
    Priority expectedPriority;
};

Priority computePriority(int daysUntilDue, bool isDone) {
    // If task is done, always low priority
    if (isDone) {
        return Priority::Low;
    }

    // Overdue tasks are always high priority
    if (daysUntilDue < 0) {
        return Priority::High;
    }

    // Due today: High priority
    if (daysUntilDue == 0) {
        return Priority::High;
    }

    // Due tomorrow (within 48 hours): Medium priority
    if (daysUntilDue == 1) {
        return Priority::Medium;
    }

    // More than 2 days away: Low priority
    return Priority::Low;
}

const char* priorityName(Priority p) {
    switch (p) {
        case Priority::Low: return "Low";
        case Priority::Medium: return "Medium";
        case Priority::High: return "High";
    }
    return "Unknown";
}

void runTest(const TestCase& test) {
    Priority result = computePriority(test.daysUntilDue, test.isDone);
    bool passed = (result == test.expectedPriority);
    
    std::cout << (passed ? "[PASS] " : "[FAIL] ")
              << test.description
              << " | Days: " << test.daysUntilDue
              << " | Done: " << (test.isDone ? "yes" : "no")
              << " | Result: " << priorityName(result)
              << " | Expected: " << priorityName(test.expectedPriority)
              << std::endl;
    
    assert(passed && "Test failed!");
}

int main() {
    std::cout << "=== Priority Computation Test Suite ===\n" << std::endl;
    
    std::vector<TestCase> tests = {
        // Overdue tasks
        {"Overdue by 1 day", -1, false, Priority::High},
        {"Overdue by 3 days", -3, false, Priority::High},
        {"Overdue by 7 days", -7, false, Priority::High},
        
        // Due today
        {"Due today (0 hours to midnight)", 0, false, Priority::High},
        
        // Due tomorrow
        {"Due tomorrow (1 day)", 1, false, Priority::Medium},
        
        // Future tasks
        {"Due in 2 days", 2, false, Priority::Low},
        {"Due in 3 days", 3, false, Priority::Low},
        {"Due in 7 days", 7, false, Priority::Low},
        {"Due in 30 days", 30, false, Priority::Low},
        
        // Done tasks (always low priority)
        {"Done task overdue", -1, true, Priority::Low},
        {"Done task due today", 0, true, Priority::Low},
        {"Done task due tomorrow", 1, true, Priority::Low},
        {"Done task future", 7, true, Priority::Low},
        
        // Edge cases
        {"Far future task", 365, false, Priority::Low},
    };
    
    for (const auto& test : tests) {
        runTest(test);
    }
    
    std::cout << "\n=== All tests passed! ===" << std::endl;
    std::cout << "\nPriority Rules Summary:" << std::endl;
    std::cout << "- Done tasks: Always Low" << std::endl;
    std::cout << "- Overdue (< 0 days): High" << std::endl;
    std::cout << "- Due today (0 days): High" << std::endl;
    std::cout << "- Due tomorrow (1 day): Medium" << std::endl;
    std::cout << "- Due in 2+ days: Low" << std::endl;
    
    return 0;
}
