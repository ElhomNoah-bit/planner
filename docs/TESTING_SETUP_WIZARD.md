# Testing Guide: Setup Wizard

## Overview

This document describes how to test the first-time setup wizard feature.

## Prerequisites

- Noah Planner build environment set up
- Qt 6.4+ installed
- Ability to build and run the application

## Test Cases

### Test Case 1: First Launch Experience

**Objective:** Verify setup wizard appears on first launch

**Steps:**
1. Delete existing configuration file:
   - Linux: `rm ~/.config/noah/planner.conf`
   - Windows: Delete registry key `HKEY_CURRENT_USER\Software\noah\planner`
2. Launch Noah Planner
3. Verify setup wizard appears automatically
4. Verify the welcome screen is displayed

**Expected Results:**
- Setup wizard opens automatically with dark overlay
- Welcome screen shows "Willkommen bei Noah Planner!"
- Progress bar shows "Schritt 1 von 4"
- Main app interface is visible but obscured by wizard
- Cannot close wizard with ESC key

### Test Case 2: Step Navigation

**Objective:** Verify navigation through wizard steps

**Steps:**
1. Open setup wizard (first launch or force open)
2. Click "Weiter" button on welcome screen
3. Verify language selection screen appears
4. Click "Zurück" button
5. Verify return to welcome screen
6. Click "Weiter" three times to reach the end

**Expected Results:**
- Progress bar updates correctly (1/4, 2/4, 3/4, 4/4)
- Each step displays correct content
- "Zurück" button not visible on first step
- "Weiter" button changes to "Fertig" on last step
- Smooth transitions between steps

### Test Case 3: Language Selection

**Objective:** Verify language setting works correctly

**Steps:**
1. Navigate to Step 2 (Language Selection)
2. Select "🇩🇪 Deutsch" radio button
3. Verify it's checked
4. Select "🇬🇧 English" radio button
5. Verify it's checked and German is unchecked

**Expected Results:**
- Only one language option selected at a time
- Selection persists when navigating back/forward
- Language preference saved to backend

### Test Case 4: Theme Selection

**Objective:** Verify theme setting works correctly

**Steps:**
1. Navigate to Step 3 (Theme Selection)
2. Select "🌙 Dunkles Theme"
3. Observe app background (should be dark)
4. Select "☀️ Helles Theme"
5. Observe app background (should be light)

**Expected Results:**
- Theme changes are immediately visible
- Only one theme selected at a time
- Theme persists through navigation

### Test Case 5: Calendar Settings

**Objective:** Verify calendar preferences work correctly

**Steps:**
1. Navigate to Step 4 (Calendar Settings)
2. Select "Montag" for week start
3. Select "Sonntag" for week start
4. Toggle "Kalender-Wochennummern" switch on
5. Toggle switch off

**Expected Results:**
- Week start options are mutually exclusive
- Week numbers toggle works correctly
- Settings are saved to backend

### Test Case 6: Setup Completion

**Objective:** Verify wizard completes successfully

**Steps:**
1. Complete all wizard steps
2. Click "Fertig" button on last step
3. Observe wizard closes
4. Verify toast message appears
5. Close and relaunch application

**Expected Results:**
- Wizard closes smoothly
- Success toast shows: "Setup abgeschlossen! Viel Erfolg mit Noah Planner!"
- Main app interface is fully accessible
- On relaunch, wizard does not appear
- `setupCompleted` flag is true in QSettings

### Test Case 7: Settings Persistence

**Objective:** Verify all settings are saved correctly

**Steps:**
1. Complete setup wizard with specific settings:
   - Language: English
   - Theme: Light
   - Week Start: Sunday
   - Week Numbers: Enabled
2. Close application
3. Relaunch application
4. Open Settings dialog
5. Verify all settings match choices from wizard

**Expected Results:**
- All settings persist correctly
- Settings accessible in Settings dialog
- QSettings file contains correct values

### Test Case 8: Manual Reset

**Objective:** Verify setup can be reset programmatically

**Steps:**
1. Complete setup wizard
2. Open QML debugger or use command palette
3. Execute: `planner.setupCompleted = false`
4. Restart application

**Expected Results:**
- Wizard appears again on next launch
- Previous settings are retained
- User can go through setup again

## Visual Checks

### Layout and Design
- [ ] Wizard panel is centered on screen
- [ ] GlassPanel blur effect works correctly
- [ ] Progress bar animates smoothly
- [ ] All text is readable and properly aligned
- [ ] Buttons have correct styling and hover effects
- [ ] Radio buttons and switches work correctly
- [ ] Emojis display correctly (flags, icons)

### Responsiveness
- [ ] Wizard adapts to different window sizes
- [ ] Minimum window size maintains usability
- [ ] Content doesn't overflow or clip

### Theme Support
- [ ] Wizard looks good in dark theme
- [ ] Wizard looks good in light theme
- [ ] Theme changes apply immediately

## Automated Test Scenarios

If unit tests are added, they should cover:

1. **AppState Tests:**
   - `setupCompleted` defaults to false
   - `setSetupCompleted()` changes state correctly
   - Settings persistence works

2. **PlannerBackend Tests:**
   - `setupCompletedChanged` signal emits correctly
   - Property getters/setters work
   - Settings are saved on change

3. **Integration Tests:**
   - Wizard opens when `setupCompleted` is false
   - Wizard doesn't open when `setupCompleted` is true
   - All settings apply correctly

## Known Limitations

1. ESC key is disabled during setup (by design)
2. Wizard cannot be dismissed without completing
3. No skip functionality (by design)
4. Requires full application restart to reset

## Troubleshooting

### Wizard doesn't appear
- Check `setupCompleted` flag in QSettings
- Verify QML component is properly loaded
- Check console for QML errors

### Settings don't persist
- Verify QSettings paths are writable
- Check file permissions on Linux
- Verify registry access on Windows

### Visual glitches
- Check Qt version compatibility
- Verify GlassPanel component works
- Test with different window sizes

## Success Criteria

All test cases pass with:
- ✅ No crashes or errors
- ✅ Smooth user experience
- ✅ All settings persist correctly
- ✅ Wizard only shows once
- ✅ Visual design matches app style
