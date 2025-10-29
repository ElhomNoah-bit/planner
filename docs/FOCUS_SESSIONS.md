# Focus Sessions & Streak Tracking

This feature implements a focus session timer with gamification through streak tracking, helping users maintain consistent study habits.

## Overview

The Focus Session system allows users to:
- Start/stop focus sessions tied to tasks
- Track time spent with second-precision accuracy
- Build daily streaks by maintaining minimum focus time
- View weekly focus time distribution
- See real-time statistics in the sidebar

## Architecture

### Backend Components

#### FocusSession Data Structure
```cpp
struct FocusSession {
    QString id;                 // Unique session identifier
    QString taskId;            // Associated task ID
    QDateTime start;           // Session start time
    QDateTime end;             // Session end time
    int durationSeconds;       // Total duration in seconds
    bool completed;            // Whether session ended normally
};
```

#### FocusSessionRepository
- Manages persistence of focus sessions to `focus_sessions.json`
- CRUD operations: `insert()`, `update()`, `remove()`, `loadById()`
- Query operations:
  - `loadByDate(date)` - Get sessions for a specific date
  - `loadBetween(start, end)` - Get sessions in date range
  - `getTotalMinutesForDate(date)` - Sum focus minutes for a date
  - `getWeeklyMinutes(weekStart)` - Get 7-day focus distribution

#### PlannerBackend Extensions
New Q_PROPERTY bindings:
- `focusSessionActive` - Whether a session is currently running
- `focusElapsedSeconds` - Real-time elapsed time in seconds
- `activeTaskId` - ID of the task being focused on
- `currentStreak` - Number of consecutive days with sufficient focus
- `weeklyMinutes` - Array of {date, minutes, dayName} for the week

New Q_INVOKABLE methods:
- `startFocus(taskId)` - Start a new focus session
- `stopFocus()` - Stop and save the current session
- `pauseFocus()` - Pause the timer (keeps session active)
- `resumeFocus()` - Resume from pause
- `getFocusHistory(start, end)` - Get historical sessions
- `getTodayFocusMinutes()` - Quick access to today's total

Signals:
- `focusTick(elapsedSeconds)` - Emitted every second during active session
- `focusSessionActiveChanged()` - Session state changed
- `currentStreakChanged()` - Streak updated

### QML Components

#### StreakBadge
Displays the current streak with a fire emoji indicator.

**Properties:**
- `streak: int` - Current streak count
- `compact: bool` - Compact display mode (60x60 vs 120x80)

**Features:**
- Color indication (accent color when streak > 0)
- Tooltip with threshold information
- Animated transitions

**Usage:**
```qml
StreakBadge {
    streak: planner.currentStreak
    compact: false
}
```

#### WeeklyHeatmap
Visual bar chart showing focus time for each day of the week.

**Properties:**
- `weeklyData: array` - Array of {date, minutes, dayName}
- `maxMinutes: int` - Maximum expected minutes for scaling (default: 120)

**Features:**
- Color intensity based on minutes (0-15-30-60+ minutes)
- Animated bar heights
- Total minutes summary
- Day labels (Mon-Sun)

**Usage:**
```qml
WeeklyHeatmap {
    weeklyData: planner.weeklyMinutes
    maxMinutes: 120
}
```

#### FocusControls
Interactive controls for starting/stopping focus sessions.

**Properties:**
- `active: bool` - Whether session is active
- `paused: bool` - Whether session is paused
- `elapsedSeconds: int` - Current elapsed time
- `taskId: string` - Task to focus on

**Signals:**
- `startRequested(taskId)`
- `stopRequested()`
- `pauseRequested()`
- `resumeRequested()`

**Features:**
- Real-time timer display (MM:SS format)
- Pause/Resume functionality
- Visual feedback (accent border when active)
- Adaptive height based on state

**Usage:**
```qml
FocusControls {
    active: planner.focusSessionActive
    elapsedSeconds: planner.focusElapsedSeconds
    taskId: "task-123"
    
    onStartRequested: planner.startFocus(taskId)
    onStopRequested: planner.stopFocus()
    onPauseRequested: planner.pauseFocus()
    onResumeRequested: planner.resumeFocus()
}
```

## Implementation Details

### Timer Accuracy
- Uses `QElapsedTimer` for precise time measurement (no drift)
- Updates every 1000ms via `QTimer`
- Emits `focusTick` signal for UI synchronization

### Streak Calculation
- **Threshold**: 30 minutes minimum per day
- **Algorithm**: Count backwards from today until first day below threshold
- **Updates**: Recalculated when sessions are saved
- **Safety**: Maximum 365 days lookback to prevent performance issues

### Data Persistence
- **Location**: `~/.local/share/NoahPlanner/focus_sessions.json`
- **Format**: JSON array of session objects
- **Atomic writes**: File written atomically to prevent corruption
- **Auto-save**: Session saved immediately on `stopFocus()`

### Session Recovery
When the app restarts:
1. Incomplete sessions remain in storage
2. User can resume or start new session
3. No automatic recovery (prevents unintended time tracking)

### Midnight Boundary Handling
Sessions spanning midnight are stored with their actual start/end times:
- Streak calculation uses `session.start.date()` for day attribution
- Weekly view aggregates by date correctly
- No special midnight logic needed (handled by date comparison)

## Integration Points

### SidebarToday
The focus session components are integrated into the sidebar:

```qml
GlassPanel {
    Layout.fillWidth: true
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
            taskId: todayEvents[0].id
            
            onStartRequested: planner.startFocus(taskId)
            onStopRequested: planner.stopFocus()
        }
    }
}
```

### Reusability with TimerOverlay
The existing `TimerOverlay` component can be enhanced to use the focus session backend:

```qml
TimerOverlay {
    onFinished: {
        // Save as focus session
        planner.stopFocus()
    }
}
```

## Testing

### Manual Tests
1. **Start/Stop Session**
   - Start focus → timer begins
   - Stop focus → session saved, streak updated
   - Verify JSON file contains session

2. **Pause/Resume**
   - Start → Pause → timer stops counting
   - Resume → timer continues from paused value
   - Stop → correct total duration saved

3. **Streak Logic**
   - Focus 30+ minutes → streak = 1
   - Next day, focus 30+ minutes → streak = 2
   - Skip a day → streak resets to 0
   - Resume next day → streak = 1

4. **Midnight Boundary**
   - Start session at 23:55
   - Continue past midnight
   - Stop at 00:05
   - Verify: session attributed to start date
   - Verify: 10 minutes recorded

5. **App Restart**
   - Start session
   - Close app (Ctrl+C or normal close)
   - Restart app
   - Verify: no active session
   - Verify: previous sessions in history

### Automated Test
Run `test_focus_sessions.py`:
```bash
python3 test_focus_sessions.py
```

Tests repository operations, streak calculation, and weekly data generation.

## Performance Considerations

- **Timer**: 1Hz update rate (low CPU usage)
- **Streak**: Calculated only when sessions change, not on every tick
- **Weekly data**: Cached, updated only on session save
- **File I/O**: Atomic writes, no locking needed (single-user app)
- **Memory**: Minimal (all sessions in JSON array, typically < 100KB for year of data)

## Future Enhancements

1. **Pomodoro Integration**: Auto-stop after 25/50 minutes with break prompts
2. **Goals**: Daily/weekly focus time targets with progress bars
3. **Statistics**: Monthly/yearly aggregates, graphs, trends
4. **Achievements**: Badges for milestones (7/30/100 day streaks)
5. **Categories**: Focus time per subject/category
6. **Export**: CSV/PDF reports of focus history
7. **Notifications**: Desktop notifications for streak milestones
8. **Break reminders**: Suggest breaks after long focus periods

## Configuration

Default settings (in `PlannerBackend.h`):
```cpp
static constexpr int DAILY_THRESHOLD_MINUTES = 30;
```

To customize:
1. Modify `DAILY_THRESHOLD_MINUTES` in `PlannerBackend.h`
2. Rebuild application
3. Existing streaks will recalculate with new threshold

## Troubleshooting

**Streak not updating:**
- Ensure focus session completed (not just stopped)
- Check `focus_sessions.json` contains today's session
- Verify total minutes >= 30 for the day
- Restart app to trigger recalculation

**Timer not ticking:**
- Check `focusSessionActive` property is true
- Verify QML binding to `focusElapsedSeconds`
- Check console for timer-related errors

**Data not persisting:**
- Check write permissions on `~/.local/share/NoahPlanner/`
- Look for errors in application output
- Verify `focus_sessions.json` is valid JSON

---

**Version**: 1.0  
**Last Updated**: 2025-10-29  
**Author**: GitHub Copilot
