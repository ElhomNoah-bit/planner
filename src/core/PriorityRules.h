#pragma once

#include "Priority.h"

#include <QDate>

#include <optional>

namespace priority {

/**
 * Computes the priority for a task-like item based on its deadline, completion state and a
 * reference date. When no deadline is available the provided default priority is returned.
 */
inline Priority priorityForDeadline(const std::optional<QDate>& deadline,
                                    bool done,
                                    const QDate& currentDate,
                                    Priority defaultPriority = Priority::Low) {
    if (done) {
        return Priority::Low;
    }

    if (!deadline.has_value()) {
        return defaultPriority;
    }

    const int daysUntilDue = currentDate.daysTo(*deadline);
    if (daysUntilDue < 0) {
        return Priority::High;
    }
    if (daysUntilDue == 0) {
        return Priority::High;
    }
    if (daysUntilDue == 1) {
        return Priority::Medium;
    }
    return Priority::Low;
}

inline int toInt(Priority priority) {
    return static_cast<int>(priority);
}

} // namespace priority
