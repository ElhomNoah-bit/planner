# Noah Planner - Developer Documentation

This document describes the technical implementation details and new features added to Noah Planner.

## Table of Contents

1. [Zen Mode](#zen-mode)
2. [Category System](#category-system)
3. [Keyboard Shortcuts](#keyboard-shortcuts)
4. [Settings & Persistence](#settings--persistence)

---

## Zen Mode

**Purpose**: Focus mode that highlights only the selected day while fading all others to minimize distractions.

### Implementation

**Backend (C++)**:
- Added `zenMode` boolean property to `AppState` class
- Persisted in QSettings under `ui/zenMode` key
- Added corresponding property to `PlannerBackend` with signal support

**UI Components**:
- `ZenToggleButton.qml`: Toggle button in the top bar
  - Visual states: active (highlighted), inactive (neutral)
  - Hover effects for better UX
  - Tooltip showing keyboard shortcut

**Behavior**:
- In **MonthView**: Non-selected days fade to 25% opacity, interactions disabled
- In **WeekView**: Non-selected days fade to 25% opacity
- In **SidebarToday**: Display remains unaffected (always shows current day)
- Smooth animations: 150ms transitions with `Easing.InOutQuad`

**Keyboard Shortcut**: `Ctrl/Cmd + .` (period)

**Command Palette**: Search for "zen", "focus", or "fokus" to toggle

**Theme Tokens Used**:
- `Styles.ThemeStore.opacityFull` (1.0)
- `Styles.ThemeStore.opacityMuted` (0.25)
- `Styles.ThemeStore.opacityDisabled` (0.4)

### Usage Example

```qml
// MonthView.qml
DayCell {
    opacity: month.zenMode && modelData.iso !== month.selectedIso
             ? Styles.ThemeStore.opacityMuted
             : Styles.ThemeStore.opacityFull
    enabled: !month.zenMode || modelData.iso === month.selectedIso
    
    Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
    }
}
```

---

## Category System

**Purpose**: Organize tasks and events by subject/topic with color-coded visual indicators.

### Data Model

**Category Structure** (`Category.h`):
```cpp
struct Category {
    QString id;      // Unique identifier (e.g., "math", "english")
    QString name;    // Display name (e.g., "Mathematik")
    QColor color;    // RGB color for visual identification
};
```

**EventRecord Extension**:
- Added `categoryId` field to link events to categories
- Included in all persistence layers (JSON, SQL)

### Default Categories

Six predefined categories are created on first run:
1. **Mathematik** - Blue (`#3B82F6`)
2. **Deutsch** - Green (`#10B981`)
3. **Englisch** - Orange (`#F59E0B`)
4. **Naturwissenschaften** - Purple (`#8B5CF6`)
5. **Geschichte** - Red (`#EF4444`)
6. **Sonstiges** - Gray (`#6B7280`)

### Persistence

**CategoryRepository** (`CategoryRepository.cpp`):
- JSON-based storage in `~/.local/share/NoahPlanner/categories.json`
- CRUD operations: insert, update, remove, findById
- Atomic file operations with proper error handling

### Backend API

**PlannerBackend Methods**:
```cpp
// List all categories
QVariantList listCategories() const;

// Add a new category
bool addCategory(const QString& id, const QString& name, const QString& color);

// Update existing category
bool updateCategory(const QString& id, const QString& name, const QString& color);

// Remove category
bool removeCategory(const QString& id);

// Assign category to an event/task
bool setEntryCategory(const QString& entryId, const QString& categoryId);
```

### QML Usage

```qml
// Access categories from backend
property var categories: planner.categories

// Assign category to event
planner.setEntryCategory(eventId, "math")

// Create new category
planner.addCategory("physics", "Physik", "#14B8A6")
```

### Visual Indicators

**EventChip**: Shows colored border when category is assigned
```qml
EventChip {
    label: "Homework"
    categoryColor: "#3B82F6"  // Blue border for Math
    // border.width automatically set to 2 when categoryColor is set
}
```

**CategoryPicker**: Dropdown component for category selection
- Lists all available categories with color indicators
- "No category" option to clear assignment
- Visual feedback for selected category

---

## Keyboard Shortcuts

| Shortcut | Action | Description |
|----------|--------|-------------|
| `Ctrl/Cmd + K` | Open Command Palette | Quick access to all commands |
| `Ctrl/Cmd + N` | New Entry | Open quick add dialog |
| `Ctrl/Cmd + T` | Go to Today | Jump to current date |
| `Ctrl/Cmd + .` | Toggle Zen Mode | Enable/disable focus mode |
| `Ctrl/Cmd + 1` | Month View | Switch to calendar month view |
| `Ctrl/Cmd + 2` | Week View | Switch to week timeline view |
| `Ctrl/Cmd + 3` | List View | Switch to agenda list view |

---

## Settings & Persistence

### QSettings Storage

Location: `~/.config/noah/planner.conf` (Linux)

**UI Settings** (group: `ui`):
```ini
[ui]
darkTheme=true
onlyOpen=false
zenMode=false
searchQuery=
viewMode=month
language=de
weekStart=monday
weekNumbers=false
```

### Data Storage

Location: `~/.local/share/NoahPlanner/`

**Files**:
- `events.json` - All events and tasks
- `categories.json` - Category definitions
- `subjects.json` - Subject metadata
- `exams.json` - Exam schedule
- `diagnostics.json` - Performance tracking
- `config.json` - App configuration
- `done.json` - Completion status

### JSON Format Examples

**categories.json**:
```json
[
  {
    "id": "math",
    "name": "Mathematik",
    "color": "#3B82F6"
  },
  {
    "id": "german",
    "name": "Deutsch",
    "color": "#10B981"
  }
]
```

**events.json** (with category):
```json
{
  "id": "evt-123",
  "title": "Algebra Homework",
  "start": "2025-01-15T14:00:00",
  "end": "2025-01-15T15:00:00",
  "allDay": false,
  "categoryId": "math",
  "isDone": false,
  "priority": 0
}
```

---

## Architecture Notes

### Design Principles

1. **No Hardcoded Colors**: All colors use `ThemeStore` tokens
2. **No Layout Anchors**: Items in layouts use Layout properties only
3. **Smooth Animations**: 150ms max duration with proper easing
4. **Signal-Driven Updates**: Backend changes propagate via Qt signals
5. **Persistent State**: User preferences saved automatically

### Performance Considerations

- Category lookups cached in memory
- Events filtered at repository level
- UI updates batched via signals
- Animations limited to ≤150ms
- No re-layouts >1×/second

### Extensibility

**Adding New Features**:
1. Extend data models in `src/core/`
2. Update persistence in repositories
3. Add backend methods in `PlannerBackend`
4. Create QML components in `src/ui/qml/components/`
5. Register in `CMakeLists.txt`
6. Add to `CommandPalette` if applicable

---

## Testing Recommendations

### Manual Testing Checklist

**Zen Mode**:
- [ ] Toggle button changes state
- [ ] Keyboard shortcut works
- [ ] Non-selected days fade correctly
- [ ] State persists after restart
- [ ] Command palette integration works
- [ ] Transitions are smooth (150ms)

**Categories**:
- [ ] Default categories created on first run
- [ ] Category CRUD operations work
- [ ] Category assignment persists
- [ ] Visual borders appear on EventChips
- [ ] CategoryPicker shows all categories
- [ ] Colors meet contrast requirements (AA)

**Integration**:
- [ ] Zen mode + categories work together
- [ ] Category filtering doesn't break other filters
- [ ] Performance with 100+ events acceptable

---

## Focus Sessions & Streaks

**Purpose**: Track focus time with gamification through daily streaks. Helps maintain consistent study habits.

### Implementation

**Data Model** (`FocusSession.h`):
```cpp
struct FocusSession {
    QString id;
    QString taskId;
    QDateTime start;
    QDateTime end;
    int durationSeconds;
    bool completed;
};
```

**FocusSessionRepository** (`FocusSessionRepository.cpp`):
- JSON-based storage in `~/.local/share/NoahPlanner/focus_sessions.json`
- CRUD operations with date-based queries
- Streak calculation: minimum 30 minutes per day
- Weekly aggregation for heatmap visualization

### Backend API

**PlannerBackend Properties**:
```cpp
Q_PROPERTY(bool focusSessionActive ...)
Q_PROPERTY(int focusElapsedSeconds ...)
Q_PROPERTY(int currentStreak ...)
Q_PROPERTY(QVariantList weeklyMinutes ...)
```

**Methods**:
```cpp
// Session control
Q_INVOKABLE bool startFocus(const QString& taskId);
Q_INVOKABLE bool stopFocus();
Q_INVOKABLE bool pauseFocus();
Q_INVOKABLE bool resumeFocus();

// Data access
Q_INVOKABLE int getTodayFocusMinutes() const;
Q_INVOKABLE QVariantList getFocusHistory(const QString& start, const QString& end) const;
```

**Signals**:
```cpp
void focusTick(int elapsedSeconds);  // Emitted every second during active session
void currentStreakChanged();
void weeklyMinutesChanged();
```

### QML Components

**StreakBadge** (`components/StreakBadge.qml`):
- Displays current streak with fire emoji
- Compact/full modes
- Tooltip with threshold info
```qml
StreakBadge {
    streak: planner.currentStreak
    compact: false
}
```

**WeeklyHeatmap** (`components/WeeklyHeatmap.qml`):
- Visual bar chart of weekly focus time
- Color intensity based on minutes
- Animated transitions
```qml
WeeklyHeatmap {
    weeklyData: planner.weeklyMinutes
    maxMinutes: 120
}
```

**FocusControls** (`components/FocusControls.qml`):
- Start/stop/pause controls
- Real-time timer display (MM:SS)
- Integrated in SidebarToday
```qml
FocusControls {
    active: planner.focusSessionActive
    elapsedSeconds: planner.focusElapsedSeconds
    taskId: currentTaskId
    onStartRequested: planner.startFocus(taskId)
    onStopRequested: planner.stopFocus()
}
```

### Technical Details

**Timer Accuracy**:
- Uses `QElapsedTimer` for drift-free timing
- 1 second update interval via `QTimer`
- Persists session on stop (prevents data loss)

**Streak Logic**:
- Threshold: 30 minutes minimum per day
- Counts backwards from today until first day below threshold
- Updated automatically when sessions are saved
- Safety limit: 365 days maximum lookback

**Midnight Boundary**:
- Sessions spanning midnight attributed to start date
- No special handling needed (date comparison handles it)
- Weekly view correctly aggregates by date

**Persistence**:
- Atomic writes to prevent corruption
- Session saved immediately on stop
- No automatic recovery after restart (prevents accidental tracking)

### Integration

Focus session components are integrated into `SidebarToday.qml`:
1. **Streak Badge**: Shows current streak at top
2. **Weekly Heatmap**: Visual representation of week's focus time
3. **Focus Controls**: Start/stop controls linked to first today task

### Usage Example

```qml
// In SidebarToday.qml
GlassPanel {
    ColumnLayout {
        Label { text: qsTr("Fokus & Streak") }
        
        StreakBadge {
            streak: planner.currentStreak
        }
        
        WeeklyHeatmap {
            weeklyData: planner.weeklyMinutes
        }
        
        FocusControls {
            active: planner.focusSessionActive
            elapsedSeconds: planner.focusElapsedSeconds
            taskId: todayEvents.length > 0 ? todayEvents[0].id : ""
            
            onStartRequested: planner.startFocus(taskId)
            onStopRequested: planner.stopFocus()
            onPauseRequested: planner.pauseFocus()
            onResumeRequested: planner.resumeFocus()
        }
    }
}
```

### Testing

Manual tests (`docs/FOCUS_SESSIONS.md`):
- Start/stop session
- Pause/resume functionality
- Streak increment logic
- Midnight boundary handling
- App restart recovery

Automated test (`test_focus_sessions.py`):
```bash
python3 test_focus_sessions.py
```

### Storage Format

**focus_sessions.json**:
```json
[
  {
    "id": "session-uuid",
    "taskId": "task-123",
    "start": "2025-10-29T10:00:00",
    "end": "2025-10-29T10:45:00",
    "durationSeconds": 2700,
    "completed": true
  }
]
```

---

## Future Enhancements

Planned features (in order of priority):
1. ~~Drag & Drop rescheduling~~
2. ~~Automatic priority calculation~~
3. ~~Focus sessions & streaks (Pomodoro)~~ ✓ **IMPLEMENTED**
4. Deadline stress indicators
5. PDF export functionality
6. Enhanced timer with statistics

---

## Contributing

When adding new features:
1. Follow existing code structure
2. Use ThemeStore for all styling
3. Add proper error handling
4. Include German translations
5. Test on different screen sizes
6. Document in this file

---

Last Updated: 2025-01-29
Version: 2.1.0
