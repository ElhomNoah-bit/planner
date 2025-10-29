# Focus Sessions - UI Integration Summary

## Visual Layout

The focus session feature is integrated into the sidebar (right panel) of the Noah Planner application.

```
┌─────────────────────────────────────────────────────────────┐
│  Noah Planner                                    [Zen] [⚙]  │
├─────────────────────────┬───────────────────────────────────┤
│                         │                                   │
│                         │  ┌─────────────────────────────┐ │
│   Calendar View         │  │  Fokus & Streak             │ │
│   (Month/Week/List)     │  ├─────────────────────────────┤ │
│                         │  │                             │ │
│                         │  │       🔥                     │ │
│                         │  │       7                     │ │
│                         │  │      Tage                   │ │
│                         │  │                             │ │
│                         │  ├─────────────────────────────┤ │
│                         │  │  Fokuszeit diese Woche      │ │
│                         │  │                             │ │
│                         │  │  Mon Tue Wed Thu Fri Sat Sun│ │
│                         │  │  ┃   ┃   ┃   ┃   ┃   ┃   ┃ │ │
│                         │  │  ┃   ┃   ┃   ┃   ┃   ┃   ┃ │ │
│                         │  │  45  60  75  0   0   0   0  │ │
│                         │  │                             │ │
│                         │  │  Gesamt: 180 Minuten        │ │
│                         │  ├─────────────────────────────┤ │
│                         │  │  ⏱️  25:47                  │ │
│                         │  │     (Läuft)                 │ │
│                         │  │                             │ │
│                         │  │  [Pause]  [Beenden]         │ │
│                         │  └─────────────────────────────┘ │
│                         │                                   │
│                         │  ┌─────────────────────────────┐ │
│                         │  │  Heute                      │ │
│                         │  │  2 von 3 erledigt           │ │
│                         │  │  ...                        │ │
│                         │  └─────────────────────────────┘ │
│                         │                                   │
└─────────────────────────┴───────────────────────────────────┘
```

## Component Breakdown

### 1. Streak Badge (Top)
```
┌─────────────┐
│             │
│     🔥      │  <- Fire emoji (colored when streak > 0)
│     7       │  <- Streak count (large number)
│   Tage      │  <- "Days" label
│             │
└─────────────┘
```

**States:**
- **Active** (streak > 0): Orange accent border, fire emoji fully opaque
- **Inactive** (streak = 0): Gray border, fire emoji semi-transparent

**Interaction:**
- Hover: Shows tooltip with streak info and threshold

### 2. Weekly Heatmap (Middle)
```
┌───────────────────────────────┐
│ Fokuszeit diese Woche         │
│                               │
│ Mon  Tue  Wed  Thu  Fri  ...  │
│  ┃    ┃    ┃    ┃    ┃        │
│  ┃    ┃    ┃    ┃    ┃        │  <- Bars scaled by minutes
│  ┃    ┃    ┃    ┃    ┃        │     (0-120min range)
│  ┃    ┃    ┃    ┃    ┃        │
│ 45   60   75    0    0        │  <- Minutes display
│                               │
│ Gesamt: 180 Minuten           │
└───────────────────────────────┘
```

**Color Coding:**
- **0 minutes**: Transparent (no fill)
- **1-14 minutes**: 20% accent color
- **15-29 minutes**: 40% accent color
- **30-59 minutes**: 60% accent color
- **60+ minutes**: 100% accent color (full bright)

**Interaction:**
- Animated bar height changes (200ms cubic easing)
- Total sum displayed below bars

### 3. Focus Controls (Bottom)
```
┌───────────────────────────────┐
│                               │
│  ⏱️  25:47                    │  <- Timer display (MM:SS)
│     (Läuft)                   │  <- State indicator
│                               │
│  [Pause]  [Beenden]           │  <- Action buttons
│                               │
└───────────────────────────────┘
```

**State 1 - Inactive:**
```
┌───────────────────────────────┐
│  [Fokus starten]              │
└───────────────────────────────┘
```

**State 2 - Running:**
```
┌───────────────────────────────┐
│  ⏱️  12:34                    │
│     (Läuft)                   │
│  [Pause]  [Beenden]           │
└───────────────────────────────┘
```

**State 3 - Paused:**
```
┌───────────────────────────────┐
│  ⏱️  12:34                    │
│     (Pausiert)                │
│  [Fortsetzen]  [Beenden]      │
└───────────────────────────────┘
```

## Component Hierarchy

```
SidebarToday.qml
├── GlassPanel "Fokus & Streak"
│   ├── Label "Fokus & Streak"
│   ├── StreakBadge
│   │   ├── Rectangle (border/background)
│   │   ├── Column
│   │   │   ├── Text "🔥"
│   │   │   ├── Text (streak number)
│   │   │   └── Text "Tage"
│   │   └── MouseArea (tooltip)
│   ├── WeeklyHeatmap
│   │   ├── Label "Fokuszeit diese Woche"
│   │   ├── Row
│   │   │   └── Repeater (7 days)
│   │   │       ├── Rectangle (day bar)
│   │   │       └── Text (day name)
│   │   └── Text "Gesamt: X Minuten"
│   └── FocusControls
│       ├── Row (timer display)
│       │   ├── Text "⏱️"
│       │   ├── Text (time)
│       │   └── Text (state)
│       └── Row (buttons)
│           ├── PillButton (start/pause/resume)
│           └── PillButton "Beenden"
├── GlassPanel "Heute"
│   └── ...
├── GlassPanel "Nächste Aufgaben"
│   └── ...
└── GlassPanel "Klassenarbeiten"
    └── ...
```

## Interaction Flow

### Starting a Focus Session
```
User clicks "Fokus starten"
    ↓
planner.startFocus(taskId)
    ↓
PlannerBackend::startFocus()
    ↓
- Set m_focusSessionActive = true
- Start QElapsedTimer
- Start QTimer (1s interval)
    ↓
emit focusSessionActiveChanged()
    ↓
QML updates:
- FocusControls expands
- Timer display appears
- Buttons change to Pause/Stop
    ↓
Every second:
- QTimer timeout
- Update m_focusElapsedSeconds
- emit focusElapsedSecondsChanged()
- emit focusTick(elapsed)
    ↓
QML updates timer text
```

### Stopping a Focus Session
```
User clicks "Beenden"
    ↓
planner.stopFocus()
    ↓
PlannerBackend::stopFocus()
    ↓
- Calculate duration
- Create FocusSession object
- Save to repository
    ↓
FocusSessionRepository::insert()
    ↓
- Generate UUID
- Serialize to JSON
- Write to focus_sessions.json
    ↓
PlannerBackend::updateStreak()
    ↓
- Calculate new streak
- emit currentStreakChanged()
    ↓
PlannerBackend::updateWeeklyMinutes()
    ↓
- Aggregate this week's data
- emit weeklyMinutesChanged()
    ↓
QML updates:
- StreakBadge shows new streak
- WeeklyHeatmap shows updated bars
- FocusControls collapses
- Toast notification appears
```

## Responsive Behavior

### Sidebar Width
- Fixed at `Styles.ThemeStore.layout.sidebarW` (typically 300-400px)
- Components stretch to fill width
- Heatmap bars divide available width by 7

### Component Sizing
- **StreakBadge**: 120x80 (or 60x60 in compact mode)
- **WeeklyHeatmap**: Full width, 180px height
- **FocusControls**: Full width, 60px when inactive, 120px when active

### Text Scaling
All text uses theme tokens:
- `typeScale.lg` for headers
- `typeScale.sm` for labels
- `typeScale.xl` for timer/streak numbers
- `typeScale.xs` for meta info

## Theme Integration

### Colors
- **Accent**: Primary action color (focus controls, active streak)
- **Background**: Panel backgrounds
- **Border**: Component borders
- **Text**: Primary text color
- **TextSecondary**: Meta information

### Spacing
- `gaps.g4`: Tight spacing (within components)
- `gaps.g8`: Normal spacing (between elements)
- `gaps.g12`: Section spacing
- `gaps.g16`: Panel padding

### Animations
- All transitions: 150-200ms with easing
- Bar height changes: `Easing.OutCubic`
- Component expand/collapse: `Easing.InOutQuad`
- Opacity fades: `Easing.OutCubic`

## Accessibility

### Tooltips
- StreakBadge: Explains streak threshold
- All interactive elements have hover states

### Keyboard
- All buttons accessible via Tab navigation
- Enter/Space to activate buttons

### Screen Readers
- Semantic label text provided
- Timer updates announced via text changes
- State indicators clearly labeled

## Performance

### Update Frequency
- Timer: 1 Hz (1 update/second)
- Streak: Only on session save
- Weekly data: Only on session save

### Animation Performance
- GPU-accelerated transforms where possible
- Smooth 60 FPS animations
- No layout thrashing

### Memory
- Minimal state in QML (bound to backend)
- No large data structures in UI
- Efficient data binding (only changed properties update)

## Future UI Enhancements

1. **Expandable history**: Click to see detailed session history
2. **Progress rings**: Circular progress instead of bars
3. **Achievement badges**: Visual rewards for milestones
4. **Customizable colors**: User-selected accent colors
5. **Compact mode**: Collapsible sections to save space
6. **Dark/light mode**: Already theme-aware, ready for toggle
