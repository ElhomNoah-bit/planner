# Focus Sessions - Quick Start Guide

## For Users

### Starting a Focus Session

1. Open Noah Planner
2. Look at the sidebar on the right
3. In the "Fokus & Streak" section, click **"Fokus starten"**
4. The timer will start counting up
5. Keep working on your task!

### Pausing a Session

1. Click **"Pause"** to pause the timer
2. The timer stops but the session remains active
3. Click **"Fortsetzen"** to resume

### Stopping a Session

1. Click **"Beenden"** to stop and save the session
2. Your focus time is recorded
3. Your streak may increase if you've reached 30 minutes today

### Understanding the Streak

- **Fire Emoji (🔥)**: Shows your current streak
- **Daily Goal**: At least 30 minutes of focus time per day
- **How it works**: 
  - Day 1: Focus 30+ minutes → Streak = 1
  - Day 2: Focus 30+ minutes → Streak = 2
  - Skip a day → Streak resets to 0
  
### Weekly Heatmap

The bar chart shows your focus time for each day of the week:
- **Dark bars**: More focus time
- **Light bars**: Less focus time
- **No color**: No focus time
- **Numbers**: Minutes focused that day

## For Developers

### Starting a Focus Session Programmatically

```qml
// In QML
planner.startFocus("task-id-123")
```

```cpp
// In C++
backend->startFocus("task-id-123");
```

### Stopping a Focus Session

```qml
// In QML
planner.stopFocus()
```

```cpp
// In C++
backend->stopFocus();
```

### Monitoring Focus Time

```qml
// In QML
Text {
    text: "Elapsed: " + planner.focusElapsedSeconds + "s"
    visible: planner.focusSessionActive
}
```

```cpp
// In C++
connect(backend, &PlannerBackend::focusTick, this, [](int elapsed) {
    qDebug() << "Focus time:" << elapsed << "seconds";
});
```

### Getting Today's Focus Time

```qml
// In QML
property int todayMinutes: planner.getTodayFocusMinutes()
```

```cpp
// In C++
int minutes = backend->getTodayFocusMinutes();
```

### Accessing Streak Data

```qml
// In QML
StreakBadge {
    streak: planner.currentStreak
}

Text {
    text: "Current streak: " + planner.currentStreak + " days"
}
```

### Displaying Weekly Data

```qml
// In QML
WeeklyHeatmap {
    weeklyData: planner.weeklyMinutes
}

// Or custom visualization
Repeater {
    model: planner.weeklyMinutes
    delegate: Text {
        text: modelData.dayName + ": " + modelData.minutes + " min"
    }
}
```

### Custom Integration Example

```qml
// Custom focus timer with notification
Item {
    property int targetMinutes: 25  // Pomodoro style
    
    Connections {
        target: planner
        function onFocusTick(elapsed) {
            if (elapsed >= targetMinutes * 60) {
                // Goal reached!
                planner.stopFocus()
                showNotification("Pomodoro complete!")
            }
        }
    }
    
    Button {
        text: planner.focusSessionActive ? "Stop Pomodoro" : "Start 25min Pomodoro"
        onClicked: {
            if (planner.focusSessionActive) {
                planner.stopFocus()
            } else {
                planner.startFocus("pomodoro-task")
            }
        }
    }
    
    Text {
        text: {
            var remaining = targetMinutes * 60 - planner.focusElapsedSeconds
            var mins = Math.floor(remaining / 60)
            var secs = remaining % 60
            return mins + ":" + (secs < 10 ? "0" : "") + secs
        }
        visible: planner.focusSessionActive
    }
}
```

## Data Format

### focus_sessions.json

Location: `~/.local/share/NoahPlanner/focus_sessions.json`

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "taskId": "task-123",
    "start": "2025-10-29T10:00:00",
    "end": "2025-10-29T10:45:00",
    "durationSeconds": 2700,
    "completed": true
  },
  {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "taskId": "task-456",
    "start": "2025-10-29T14:30:00",
    "end": "2025-10-29T15:00:00",
    "durationSeconds": 1800,
    "completed": true
  }
]
```

### Weekly Minutes Data Structure

```javascript
[
  {
    date: "2025-10-27",      // ISO date string
    minutes: 45,              // Total minutes for that day
    dayName: "Mon"           // Localized day name
  },
  {
    date: "2025-10-28",
    minutes: 60,
    dayName: "Tue"
  },
  // ... 7 entries total (one per weekday)
]
```

## Common Tasks

### Reset Streak
Delete or edit entries in `focus_sessions.json` to remove the consecutive days.

### Change Daily Threshold
Edit `DAILY_THRESHOLD_MINUTES` in `src/ui/PlannerBackend.h` and rebuild.

### Export Focus History
```cpp
QVariantList history = planner->getFocusHistory(
    "2025-01-01",  // start date
    "2025-12-31"   // end date
);
```

### Check if User is Focusing
```qml
if (planner.focusSessionActive) {
    // Session is active
}
```

## Tips

1. **Start focus sessions before studying** to build your streak
2. **Aim for 30+ minutes daily** to maintain your streak
3. **Check the weekly heatmap** to see your patterns
4. **Use pause** when taking quick breaks (instead of stopping)
5. **The timer is accurate** - no need to worry about drift

## Troubleshooting

**Q: Timer not starting?**
- Check if a session is already active
- Look for error messages in the sidebar

**Q: Streak not updating?**
- Ensure you completed at least 30 minutes today
- Restart the app to trigger recalculation

**Q: Data not saving?**
- Check file permissions on `~/.local/share/NoahPlanner/`
- Look for error messages in console output

**Q: Weekly heatmap empty?**
- Start and complete a focus session
- Check that `focus_sessions.json` exists and has valid data

## See Also

- Full documentation: `docs/FOCUS_SESSIONS.md`
- Developer guide: `README_DEV.md`
- Automated tests: `test_focus_sessions.py`
