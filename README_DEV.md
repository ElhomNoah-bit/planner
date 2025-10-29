# Noah Planner - Developer Documentation

This document describes the technical implementation details and new features added to Noah Planner.

## Table of Contents

1. [Zen Mode](#zen-mode)
2. [Category System](#category-system)
3. [Deadline Stress Indicator](#deadline-stress-indicator)
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

## Deadline Stress Indicator

**Purpose**: Visual emphasis on approaching deadlines to help users prioritize urgent tasks.

### Implementation

**Backend (C++)**:
- Added `DeadlineSeverity` enum with levels: None, Normal, Warn, Danger, Overdue
- `calculateDeadlineSeverity()` method determines severity based on time thresholds
- Added `stressIndicatorEnabled` boolean property to `AppState` class
- Persisted in QSettings under `ui/stressIndicatorEnabled` key (default: true)
- Added corresponding property to `PlannerBackend` with signal support
- Added `urgentEvents` property that filters events by severity

**Severity Thresholds**:
- **Normal**: More than 72 hours until deadline
- **Warn**: Less than 72 hours (3 days) until deadline
- **Danger**: Less than 24 hours (1 day) until deadline
- **Overdue**: Deadline has passed

**UI Components**:
- **EventChip.qml**: Enhanced with deadline severity styling
  - Border color changes based on severity (warn: amber, danger: orange-red, overdue: red)
  - Subtle pulse/glow animation for danger and overdue states
  - Animation is reduced/disabled in Zen Mode
  - Width: 2px border for danger/overdue, 1px for warn

- **TodayTaskDelegate.qml**: Task cards with severity indicators
  - Same color coding as EventChip
  - Pulse/glow effect for urgent items
  - Animation pauses when task is marked as done
  - Respects Zen Mode setting

- **SidebarToday.qml**: New "Dringend" (Urgent) section
  - Displays events with warn/danger/overdue severity
  - Sorted by deadline (most urgent first)
  - Shows above "Heute" (Today) section
  - Icon indicator (⚠️) for visual emphasis
  - Only visible when stress indicator is enabled and urgent items exist

- **SettingsDialog.qml**: Toggle control
  - Switch to enable/disable stress indicator feature
  - Description: "Visuelle Hervorhebung nahender Deadlines"
  - Changes take effect immediately

**Theme Tokens**:
- `Styles.ThemeStore.colors.warn` - `#F59E0B` (Amber)
- `Styles.ThemeStore.colors.danger` - `#F97066` (Orange-Red)
- `Styles.ThemeStore.colors.overdue` - `#DC2626` (Red)

**Behavior**:
- Severity is calculated in real-time based on current datetime
- Time calculations use `QDateTime::currentDateTime()` for timezone awareness
- Severity updates when events are reloaded or sidebar is rebuilt
- Pulse animation: 1500ms cycle (smooth sine easing)
- Animation opacity: 0 to 0.4 (subtle, non-distracting)

**Zen Mode Integration**:
- Pulse/glow animations are disabled when Zen Mode is active
- Border colors remain visible for accessibility
- Ensures focus mode isn't disrupted by animations

### Usage Example

**Backend - Calculate Severity**:
```cpp
PlannerBackend::DeadlineSeverity severity = calculateDeadlineSeverity(record.due);
// Returns: None, Normal, Warn, Danger, or Overdue
```

**QML - EventChip with Severity**:
```qml
EventChip {
    label: modelData.title
    deadlineSeverity: modelData.deadlineSeverityString || "none"
    zenMode: root.zenMode
    // Border and animation applied automatically
}
```

**QML - Check in Sidebar**:
```qml
property var urgentEvents: planner && planner.urgentEvents ? planner.urgentEvents : []

GlassPanel {
    visible: planner.stressIndicatorEnabled && urgentEvents.length > 0
    // Display urgent section
}
```

### Accessibility

- Not reliant solely on color coding
- Warning icon (⚠️) provides visual indicator
- Border width changes provide tactile difference
- Text color changes for deadline information
- Can be fully disabled via settings for users who prefer minimal UI

### Testing Considerations

**Time Threshold Tests**:
- Verify transitions at exact threshold times (72h, 24h, 0h)
- Test with events crossing midnight
- Verify correct handling across timezones
- Test daylight saving time transitions

**UI Tests**:
- Confirm no flickering during auto-updates
- Verify animation performance with many urgent items
- Test interaction with Zen Mode (animations off)
- Confirm sorting order in urgent section

**Settings Tests**:
- Verify toggle persists across app restarts
- Confirm urgent section hides when disabled
- Verify immediate UI update when toggled

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
stressIndicatorEnabled=true
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

## Future Enhancements

Planned features (in order of priority):
1. Drag & Drop rescheduling
2. Automatic priority calculation
3. Focus sessions & streaks (Pomodoro)
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
