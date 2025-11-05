#include "core/QuickAddParser.h"
#include "models/EventModel.h"

#include <QDateTime>
#include <QTimeZone>

#include <iostream>
#include <string>

namespace {
struct TestCase {
    std::string description;
    bool (*test)(const QuickAddParser&);
};

void reportResult(const std::string& description, bool passed) {
    std::cout << (passed ? "[PASS] " : "[FAIL] ") << description << '\n';
}

bool testParseSimpleTitle(const QuickAddParser& parser) {
    const QDateTime ref(QDate(2024, 6, 15), QTime(10, 0), QTimeZone::systemTimeZone());
    const QuickAddResult result = parser.parse("Meeting with team", ref);
    
    if (!result.error.isEmpty()) {
        return false;
    }
    
    return result.record.title == "Meeting with team";
}

bool testParseEmptyInputReturnsError(const QuickAddParser& parser) {
    const QDateTime ref(QDate(2024, 6, 15), QTime(10, 0), QTimeZone::systemTimeZone());
    const QuickAddResult result = parser.parse("", ref);
    
    return !result.error.isEmpty();
}

bool testParseWithTime(const QuickAddParser& parser) {
    const QDateTime ref(QDate(2024, 6, 15), QTime(10, 0), QTimeZone::systemTimeZone());
    const QuickAddResult result = parser.parse("Dentist appointment at 14:30", ref);
    
    if (!result.error.isEmpty()) {
        return false;
    }
    
    // Should extract time 14:30
    return result.record.start.time().hour() == 14 && 
           result.record.start.time().minute() == 30;
}

bool testParseWithDuration(const QuickAddParser& parser) {
    const QDateTime ref(QDate(2024, 6, 15), QTime(10, 0), QTimeZone::systemTimeZone());
    const QuickAddResult result = parser.parse("Gym workout for 90m", ref);
    
    if (!result.error.isEmpty()) {
        return false;
    }
    
    // Duration should affect end time
    const int durationMinutes = result.record.start.secsTo(result.record.end) / 60;
    return durationMinutes == 90;
}

bool testParseWithLocation(const QuickAddParser& parser) {
    const QDateTime ref(QDate(2024, 6, 15), QTime(10, 0), QTimeZone::systemTimeZone());
    const QuickAddResult result = parser.parse("Conference @downtown", ref);
    
    if (!result.error.isEmpty()) {
        return false;
    }
    
    return result.record.location == "downtown";
}

bool testParseWithTags(const QuickAddParser& parser) {
    const QDateTime ref(QDate(2024, 6, 15), QTime(10, 0), QTimeZone::systemTimeZone());
    const QuickAddResult result = parser.parse("Project meeting #work #urgent", ref);
    
    if (!result.error.isEmpty()) {
        return false;
    }
    
    return result.record.tags.contains("work") && 
           result.record.tags.contains("urgent");
}

bool testParseWithPriorityHigh(const QuickAddParser& parser) {
    const QDateTime ref(QDate(2024, 6, 15), QTime(10, 0), QTimeZone::systemTimeZone());
    const QuickAddResult result = parser.parse("Important task !high", ref);
    
    if (!result.error.isEmpty()) {
        return false;
    }
    
    return result.record.priority == Priority::High;
}

bool testParseWithPriorityMedium(const QuickAddParser& parser) {
    const QDateTime ref(QDate(2024, 6, 15), QTime(10, 0), QTimeZone::systemTimeZone());
    const QuickAddResult result = parser.parse("Regular task !medium", ref);
    
    if (!result.error.isEmpty()) {
        return false;
    }
    
    return result.record.priority == Priority::Medium;
}

bool testParseWithPriorityLow(const QuickAddParser& parser) {
    const QDateTime ref(QDate(2024, 6, 15), QTime(10, 0), QTimeZone::systemTimeZone());
    const QuickAddResult result = parser.parse("Optional task !low", ref);
    
    if (!result.error.isEmpty()) {
        return false;
    }
    
    return result.record.priority == Priority::Low;
}

bool testParseAllDayEventWhenNoTime(const QuickAddParser& parser) {
    const QDateTime ref(QDate(2024, 6, 15), QTime(10, 0), QTimeZone::systemTimeZone());
    const QuickAddResult result = parser.parse("Birthday celebration", ref);
    
    if (!result.error.isEmpty()) {
        return false;
    }
    
    // Without specific time or duration, should be all-day
    return result.record.allDay;
}

bool testParseWithTimeRange(const QuickAddParser& parser) {
    const QDateTime ref(QDate(2024, 6, 15), QTime(10, 0), QTimeZone::systemTimeZone());
    const QuickAddResult result = parser.parse("Meeting from 9:00 to 10:30", ref);
    
    if (!result.error.isEmpty()) {
        return false;
    }
    
    return result.record.start.time().hour() == 9 &&
           result.record.end.time().hour() == 10 &&
           result.record.end.time().minute() == 30;
}

bool testParseWithDate(const QuickAddParser& parser) {
    const QDateTime ref(QDate(2024, 6, 15), QTime(10, 0), QTimeZone::systemTimeZone());
    const QuickAddResult result = parser.parse("Appointment on 2024-07-20", ref);
    
    if (!result.error.isEmpty()) {
        return false;
    }
    
    return result.record.start.date() == QDate(2024, 7, 20);
}

bool testParseCombinedElements(const QuickAddParser& parser) {
    const QDateTime ref(QDate(2024, 6, 15), QTime(10, 0), QTimeZone::systemTimeZone());
    const QuickAddResult result = parser.parse("Team sync at 15:00 for 60m @office #meeting !high", ref);
    
    if (!result.error.isEmpty()) {
        return false;
    }
    
    return result.record.start.time().hour() == 15 &&
           result.record.location == "office" &&
           result.record.tags.contains("meeting") &&
           result.record.priority == Priority::High;
}

bool testParsePreservesWhitespace(const QuickAddParser& parser) {
    const QDateTime ref(QDate(2024, 6, 15), QTime(10, 0), QTimeZone::systemTimeZone());
    const QuickAddResult result = parser.parse("   Padded   title   ", ref);
    
    if (!result.error.isEmpty()) {
        return false;
    }
    
    // Title should be trimmed and simplified
    return result.record.title == "Padded title";
}

bool testParseHandlesNewlines(const QuickAddParser& parser) {
    const QDateTime ref(QDate(2024, 6, 15), QTime(10, 0), QTimeZone::systemTimeZone());
    const QuickAddResult result = parser.parse("Multi\nline\ntitle", ref);
    
    if (!result.error.isEmpty()) {
        return false;
    }
    
    // Newlines should be converted to spaces
    return result.record.title == "Multi line title";
}

} // namespace

int main() {
    QuickAddParser parser;
    
    std::cout << "=== QuickAddParser Test Suite ===\n";
    
    const std::vector<TestCase> tests = {
        {"Parse simple title", testParseSimpleTitle},
        {"Parse empty input returns error", testParseEmptyInputReturnsError},
        {"Parse with time", testParseWithTime},
        {"Parse with duration", testParseWithDuration},
        {"Parse with location", testParseWithLocation},
        {"Parse with tags", testParseWithTags},
        {"Parse with priority high", testParseWithPriorityHigh},
        {"Parse with priority medium", testParseWithPriorityMedium},
        {"Parse with priority low", testParseWithPriorityLow},
        {"Parse all-day event when no time", testParseAllDayEventWhenNoTime},
        {"Parse with time range", testParseWithTimeRange},
        {"Parse with date", testParseWithDate},
        {"Parse combined elements", testParseCombinedElements},
        {"Parse preserves whitespace correctly", testParsePreservesWhitespace},
        {"Parse handles newlines", testParseHandlesNewlines},
    };
    
    bool allPassed = true;
    for (const auto& test : tests) {
        try {
            const bool passed = test.test(parser);
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
    
    std::cout << '\n' << (allPassed ? "All QuickAddParser tests passed." : "Some QuickAddParser tests failed.") << '\n';
    return allPassed ? 0 : 1;
}
