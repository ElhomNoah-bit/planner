# Noah Planner - Developer Documentation

This document describes the technical implementation details and new features added to Noah Planner.

## Table of Contents

1. [Zen Mode](#zen-mode)
2. [Category System](#category-system)
3. [Pomodoro Focus Timer](#pomodoro-focus-timer)
4. [Keyboard Shortcuts](#keyboard-shortcuts)
5. [Settings & Persistence](#settings--persistence)

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
| `Ctrl/Cmd + P` | Start Pomodoro | Open Pomodoro timer overlay |
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

## Pomodoro Focus Timer

**Purpose**: Time-boxed focus sessions using the Pomodoro Technique with automatic break management, session tracking, and statistics.

### Data Model

**FocusSession Structure** (`FocusSession.h`):
```cpp
struct FocusSession {
    QString id;              // Unique session identifier
    QString taskId;          // Optional linked task
    FocusMode mode;          // Work, ShortBreak, LongBreak
    PomodoroPreset preset;   // 25/5, 50/10, Custom
    int currentRound;        // Current Pomodoro round (1-4)
    int totalRounds;         // Rounds before long break (default: 4)
    int workMinutes;         // Work duration
    int shortBreakMinutes;   // Short break duration
    int longBreakMinutes;    // Long break duration
    int remainingSeconds;    // Remaining time in current phase
    bool isPaused;
    bool isActive;
    QDateTime startTime;
    QDateTime lastTickTime;  // For recovery after app restart
};
```

### Presets

Three built-in presets available:
1. **Classic Pomodoro (25/5)**: 25 min work, 5 min short break, 15 min long break
2. **Extended (50/10)**: 50 min work, 10 min short break, 20 min long break
3. **Custom** (planned): User-defined durations

### State Machine

**Work → Break Cycle**:
1. Start with Work phase (round 1)
2. After work: Short Break
3. After short break: Work (round 2)
4. Repeat until round 4 completes
5. After round 4: Long Break
6. After long break: Reset to round 1 or stop

### Persistence

**FocusSessionRepository** (`FocusSessionRepository.cpp`):
- Active session: `~/.local/share/NoahPlanner/focus_session_active.json`
- History log: `~/.local/share/NoahPlanner/focus_session_history.json`
- Keeps last 1000 completed sessions
- Session recovery on app restart (1-hour timeout)

### Backend API

**PomodoroTimer** (exposed via `PlannerBackend.pomodoroTimer`):

**Properties**:
```cpp
bool isActive          // Whether timer is running
bool isPaused          // Whether timer is paused
int remainingSeconds   // Seconds left in current phase
int totalSeconds       // Total seconds in current phase
QString modeString     // "work", "short_break", "long_break"
int currentRound       // Current round number
int totalRounds        // Total rounds in session
QString presetString   // "25/5", "50/10", "custom"
int totalFocusMinutes  // All-time focus minutes
int totalCompletedRounds // All-time completed rounds
```

**Methods**:
```cpp
startSession(preset, taskId)        // Start new session
startCustomSession(work, break, id) // Custom duration
pause()                              // Pause current session
resume()                             // Resume paused session
skip()                               // Skip to next phase
extend(minutes)                      // Add minutes to current phase
stop()                               // Stop and discard session
getRecentHistory(limit)              // Get last N sessions
getStatistics()                      // Get statistics including last 7 days
```

**Signals**:
```cpp
phaseChanged(QString)  // Emitted when phase transitions
roundCompleted()       // Emitted when work round completes
sessionCompleted()     // Emitted when full session completes
```

### UI Components

**PomodoroOverlay.qml**:
- Modal overlay with circular progress ring
- Preset selection (25/5, 50/10)
- Timer display with phase indicator
- Round counter (e.g., "Runde 2 von 4")
- Controls: Start/Pause/Resume, Stop, Skip, +5 Min
- Color-coded phases:
  - Work: Accent color
  - Short Break: Green
  - Long Break: Blue

**PomodoroStats.qml** (Sidebar component):
- Total focus minutes
- Total completed rounds
- Average minutes per round
- Total focus hours
- Motivational messages based on progress

### Keyboard Shortcut

**Ctrl/Cmd + P**: Open Pomodoro overlay

### Command Palette

Search for "pomodoro", "timer", or "fokus" to start a session.

### Usage Example

**From QML**:
```qml
// Access via PlannerBackend
planner.pomodoroTimer.startSession("25/5", "")

// Listen to phase changes
Connections {
    target: planner.pomodoroTimer
    function onPhaseChanged(newPhase) {
        console.log("Phase:", newPhase)
    }
    function onRoundCompleted() {
        // Show notification
    }
}
```

**From UI**:
1. Click "🍅 Jetzt Fokus" button in sidebar
2. Select preset (25/5 or 50/10)
3. Click "Start"
4. Timer runs automatically through work/break cycles
5. Statistics update in real-time in sidebar

### Features

✅ **Auto-transitions**: Automatically switches between work and break phases
✅ **State persistence**: Survives app restarts (with 1-hour timeout)
✅ **Session recovery**: Adjusts remaining time based on elapsed time
✅ **Pause/Resume**: Can pause and resume at any time
✅ **Skip phase**: Jump to next phase if needed
✅ **Extend time**: Add 5 minutes to current phase
✅ **Statistics tracking**: All-time and daily statistics
✅ **History log**: Last 1000 sessions stored
✅ **Round counter**: Visual indication of progress

### Notifications (Planned)

Future enhancement: System notifications when:
- Work phase completes → Time for break
- Break completes → Time to focus
- Full session completes → Achievement unlocked

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

**Pomodoro Timer**:
- [ ] Can start session with 25/5 preset
- [ ] Can start session with 50/10 preset
- [ ] Circular progress ring displays correctly
- [ ] Timer counts down every second
- [ ] Pause/resume functionality works
- [ ] Skip phase transitions correctly
- [ ] Extend adds 5 minutes correctly
- [ ] Auto-transitions from work to break
- [ ] Auto-transitions from break to work
- [ ] Round counter increments correctly
- [ ] Long break after 4 rounds
- [ ] Session completes after long break
- [ ] Statistics update after completion
- [ ] State persists across app restarts
- [ ] Keyboard shortcut (Ctrl+P) opens overlay
- [ ] "Jetzt Fokus" button in sidebar works
- [ ] Command palette integration works
- [ ] Statistics display updates in real-time

**Integration**:
- [ ] Zen mode + categories work together
- [ ] Category filtering doesn't break other filters
- [ ] Performance with 100+ events acceptable

---

## Future Enhancements

Planned features (in order of priority):
1. Drag & Drop rescheduling
2. Automatic priority calculation
3. ~~Focus sessions & streaks (Pomodoro)~~ ✅ **COMPLETED**
4. Deadline stress indicators
5. PDF export functionality
6. System notifications for Pomodoro phase transitions
7. Pomodoro streak tracking and achievements

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

Last Updated: 2025-10-29
Version: 2.2.0
