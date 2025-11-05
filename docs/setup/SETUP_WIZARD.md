# Setup Wizard Documentation

## Overview

The Setup Wizard is a first-time onboarding experience for Noah Planner that guides new users through initial configuration of the app.

## Features

The wizard consists of 4 steps:

### Step 1: Welcome
- Introduces the app and its main features
- Lists key capabilities:
  - Task and appointment organization
  - Exam planning and tracking
  - Focus sessions for productive learning
  - Progress visualization

### Step 2: Language Selection
- Choose between German (🇩🇪) and English (🇬🇧)
- Default: German

### Step 3: Theme Selection
- Choose between Dark (🌙) and Light (☀️) theme
- Default: Dark theme

### Step 4: Calendar Settings
- Configure week start day (Monday/Sunday)
- Enable/disable week numbers display
- Default: Monday start, week numbers disabled

## Implementation Details

### Backend (C++)

#### AppState Class
- Added `m_setupCompleted` boolean flag
- Persisted in QSettings under `ui/setupCompleted` key
- Getter: `bool setupCompleted() const`
- Setter: `bool setSetupCompleted(bool completed)`

#### PlannerBackend Class
- Exposed `setupCompleted` as Q_PROPERTY
- Added `setupCompletedChanged()` signal
- Added setters for `language`, `weekStart`, and `showWeekNumbers` properties

### Frontend (QML)

#### SetupWizard.qml
- Located in `src/ui/qml/components/SetupWizard.qml`
- Uses GlassPanel component for consistent design
- 449 lines of code
- Features:
  - Progress bar showing current step
  - Navigation buttons (Back/Next/Finish)
  - ESC key disabled during setup
  - Auto-focus on welcome step
  - Smooth transitions between steps

#### App.qml Integration
- Wizard is instantiated as a child component
- Checks `planner.setupCompleted` on app launch
- Opens wizard automatically if setup not completed
- Shows success toast message after completion

## User Flow

1. User launches Noah Planner for the first time
2. App checks `setupCompleted` flag in QSettings (false by default)
3. Setup wizard appears with welcome screen
4. User navigates through 4 configuration steps
5. User clicks "Fertig" (Finish) button
6. `setupCompleted` flag is set to true and saved
7. Wizard closes and shows success toast
8. App main interface becomes accessible
9. On subsequent launches, wizard is skipped

## Technical Notes

### Storage
- Settings are stored in platform-specific locations:
  - Linux: `~/.config/noah/planner.conf`
  - Windows: Registry under `HKEY_CURRENT_USER\Software\noah\planner`

### z-index
- Wizard has `z: 300` to appear above all other UI elements
- Higher than dialogs (typically z: 250) to ensure visibility

### Reset Setup
To test or reset the setup wizard:
```bash
# Linux
rm ~/.config/noah/planner.conf

# Windows
# Delete registry key: HKEY_CURRENT_USER\Software\noah\planner
```

Or programmatically:
```cpp
planner.setupCompleted = false
```

## Future Enhancements

Potential improvements for future versions:
- Add more configuration options (notification settings, default view)
- Include a quick tutorial or feature highlights
- Add skip functionality with confirmation dialog
- Support for importing existing data
- Animated transitions between steps
- Video or GIF demonstrations of key features
