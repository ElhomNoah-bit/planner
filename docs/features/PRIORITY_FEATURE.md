# Automatic Task Prioritization

This document describes the automatic task prioritization feature implemented in Noah Planner.

## Overview

Tasks and events are automatically assigned a priority level (High, Medium, or Low) based on their deadline proximity. The priority is recomputed whenever tasks are loaded from the database, ensuring priorities are always current.

## Priority Levels

- **High (2)**: Red dot - Overdue or due today
- **Medium (1)**: Orange dot - Due tomorrow  
- **Low (0)**: Green dot - Due in 2+ days or completed

## Priority Computation Rules

The priority computation follows a simple, predictable algorithm:

1. **Done tasks**: Always Low priority (regardless of deadline)
2. **Overdue tasks** (deadline < today): High priority
3. **Due today** (deadline = today): High priority
4. **Due tomorrow** (deadline = today + 1 day): Medium priority
5. **Due in 2+ days** (deadline >= today + 2 days): Low priority

## Implementation Details

### Backend (C++)

#### EventRepository
The `EventRepository::computePriority()` static method computes priority based on:
- Event's due date (if available) or start date
- Current date
- Whether the event is marked as done

Priority is automatically computed when events are loaded via:
- `loadAll()` - Loads all events
- `loadBetween()` - Loads events in a date range
- `search()` - Searches for events

#### PlannerService
The `PlannerService::computePriority()` method uses the same logic for Task objects, computing priority when tasks are generated via `generateDay()`.

### UI Display

#### Priority Indicators
Tasks display their priority as a colored dot:
- Red (High): `#F97066`
- Orange (Medium): `#FFA726`
- Green (Low): `#66BB6A`

Priority dots appear in:
1. **SidebarToday** - Today's tasks and upcoming tasks
2. **AgendaView** - List view of tasks grouped by week
3. **TodayTaskDelegate** - Individual task cards (when implemented)

Priority dots are hidden for completed tasks.

#### Sorting
Tasks are sorted by priority (High → Medium → Low) within each view:
- **Sidebar**: Today's and upcoming tasks lists
- **List View**: Tasks within each weekly bucket

Within the same priority level, tasks are sorted by their start time.

## Data Model

### Task Structure (src/core/Task.h)
```cpp
enum class Priority {
    Low = 0,
    Medium = 1,
    High = 2
};

struct Task {
    // ... other fields ...
    Priority priority = Priority::Medium;
};
```

### EventRecord Structure (src/models/EventModel.h)
```cpp
struct EventRecord {
    // ... other fields ...
    int priority = 0;  // 0=Low, 1=Medium, 2=High
};
```

## Theme Colors (src/ui/qml/styles/ThemeStore.qml)

```qml
readonly property color prioHigh:     "#F97066"  // Red
readonly property color prioMedium:   "#FFA726"  // Orange
readonly property color prioLow:      "#66BB6A"  // Green
```

## Testing

Unit tests for the priority computation logic live in `tests/priority_rules_test.cpp`. After configuring the project with CMake you can execute the suite via CTest:

```bash
cmake -S . -B build
cmake --build build
cd build
ctest --output-on-failure
```

Alternatively, run the standalone binary `priority_rules_test` inside the build directory.

The tests validate the priority rules for various scenarios including:
- Overdue tasks
- Tasks due today
- Tasks due tomorrow
- Future tasks
- Completed tasks
- Edge cases

## Acceptance Criteria

✅ **Overdue tasks always "high"**: Tasks with deadlines in the past are marked as High priority

✅ **Sorting in list view stable and comprehensible**: Tasks are sorted by priority (High → Medium → Low) then by start time

✅ **Heuristic changeable without rebuild**: The priority computation logic can be modified in the source code without requiring data migration (priorities are computed dynamically on load)

## Future Enhancements

Potential improvements for consideration:
1. Make priority thresholds configurable in `config.json`
2. Add task duration/effort as a factor in priority calculation
3. Allow manual priority override by users
4. Add visual indicators for priority in calendar views
5. Support custom priority rules per category
