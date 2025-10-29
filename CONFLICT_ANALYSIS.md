# Detailed Conflict Analysis

This document provides a detailed analysis of the merge conflicts in all open pull requests.

## Context

All four feature branch PRs (#4, #5, #6, #7) were created from an earlier version of the `main` branch (commit `7eb9e69c`). After these PRs were created, PR #3 was merged into `main`, which added the complete foundational application structure (11,085 lines added across 84 files).

**Current main branch**: `3003768d` - Contains full application structure  
**Feature branches based on**: `7eb9e69c` - Before PR #3 merge

## File-Level Conflict Analysis

### CMakeLists.txt
**Affected PRs**: #4, #6, #7  
**Conflict Type**: Both modified  
**Resolution Strategy**:
- Base (from main): Contains Qt6 components and source file list
- Feature branches: Add additional source files and possibly Qt6 components
- **Action**: Merge both changes - keep main's structure and add feature-specific files

**Example for PR #6** (PDF export):
```cmake
# Main has:
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Qml Quick)

# PR #6 needs:
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Qml Quick PrintSupport)

# Resolution: Add PrintSupport to existing list
```

### src/ui/PlannerBackend.h
**Affected PRs**: #4, #5, #6, #7  
**Conflict Type**: Multiple feature branches modify this file  
**Current state in main**:
- Has basic class structure
- Contains event/task management methods
- Has Q_PROPERTY declarations

**Feature branch additions**:
- **PR #4**: Add focus session methods (startFocus, stopFocus, etc.) and properties
- **PR #5**: Add deadline severity calculation methods and urgent events property
- **PR #6**: Add PDF export methods (exportWeekPdf, exportMonthPdf)
- **PR #7**: Add PomodoroTimer pointer and related methods

**Resolution Strategy**:
1. Keep main's class structure
2. Add all new includes from feature branches
3. Add all new method declarations
4. Add all new Q_PROPERTY declarations
5. Add all new private members

### src/ui/PlannerBackend.cpp
**Affected PRs**: #4, #5, #6, #7  
**Conflict Type**: Implementation file modifications  
**Resolution Strategy**:
- Keep constructor initialization list from main
- Add new member initializations from feature branches
- Keep all existing methods from main
- Add all new method implementations from feature branches
- Ensure includes are merged

### src/ui/qml/views/SidebarToday.qml
**Affected PRs**: #4, #5, #7  
**Conflict Type**: UI component modifications  
**Current state**: Basic sidebar structure
**Feature additions**:
- **PR #4**: StreakBadge, WeeklyHeatmap, FocusControls components
- **PR #5**: "Dringend" (Urgent) section for deadline-stressed tasks
- **PR #7**: "🍅 Jetzt Fokus" Pomodoro start button

**Resolution Strategy**:
1. Keep main's layout structure
2. Add urgent section from PR #5 at the top
3. Add Pomodoro button from PR #7
4. Add streak/focus controls from PR #4
5. Ensure proper spacing and visual hierarchy

### src/ui/qml/components/CommandPalette.qml
**Affected PRs**: #6, #7  
**Conflict Type**: Command additions  
**Resolution Strategy**:
- Keep main's command structure
- Add export commands from PR #6 (export-week, export-month)
- Add Pomodoro command from PR #7
- Ensure command IDs don't conflict

### src/ui/qml/styles/ThemeStore.qml
**Affected PRs**: #5  
**Conflict Type**: Color additions  
**Resolution Strategy**:
- Keep main's theme structure
- Add warn and overdue colors from PR #5
```qml
// Add from PR #5:
readonly property color warn: "#F59E0B"
readonly property color danger: "#F97066"
readonly property color overdue: "#DC2626"
```

### src/ui/qml/components/EventChip.qml
**Affected PRs**: #5  
**Conflict Type**: Visual indicator additions  
**Resolution Strategy**:
- Keep main's EventChip structure
- Add deadline severity border styling from PR #5
- Add pulse animation for urgent items

### src/ui/qml/App.qml
**Affected PRs**: #7  
**Conflict Type**: Keyboard shortcut addition  
**Resolution Strategy**:
- Keep main's App structure
- Add Ctrl+P shortcut for Pomodoro timer
- Add PomodoroOverlay component

## New Files (No Conflicts)

These files are completely new and won't conflict:

### PR #4:
- src/core/FocusSession.h
- src/core/FocusSessionRepository.h
- src/core/FocusSessionRepository.cpp
- src/ui/qml/components/StreakBadge.qml
- src/ui/qml/components/WeeklyHeatmap.qml
- src/ui/qml/components/FocusControls.qml
- docs/FOCUS_SESSION_*.md

### PR #6:
- src/core/ScheduleExporter.h
- src/core/ScheduleExporter.cpp
- src/ui/qml/components/ExportDialog.qml
- docs/PDF_EXPORT*.md

### PR #7:
- src/core/PomodoroTimer.h
- src/core/PomodoroTimer.cpp
- src/core/FocusSession.h (shared with PR #4)
- src/core/FocusSessionRepository.h (shared with PR #4)
- src/core/FocusSessionRepository.cpp (shared with PR #4)
- src/ui/qml/components/PomodoroOverlay.qml
- src/ui/qml/components/PomodoroStats.qml
- docs/POMODORO_*.md

### PR #5:
- docs/DEADLINE_STRESS_*.md

## Dependency Analysis

### PR #7 depends on PR #4
Both PRs use FocusSession and FocusSessionRepository. If resolving independently:
1. PR #4 should be merged first
2. Or PR #7's versions of these files should be used (more complete)

**Recommendation**: Resolve PR #7 after PR #4, or ensure PR #7 includes all PR #4 focus session functionality.

### No other inter-PR dependencies
PRs #5 and #6 are independent of other PRs.

## Merge Order Recommendation

### Option 1: By Complexity (Simplest First)
1. **PR #5** - Smallest, cleanest changes
2. **PR #6** - Moderate size, self-contained
3. **PR #4** - Foundation for PR #7
4. **PR #7** - Most complex, depends on #4

### Option 2: By Feature Priority
1. **PR #4** then **PR #7** - Focus/Pomodoro features together
2. **PR #5** - Deadline indicators
3. **PR #6** - Export functionality

### Option 3: All at Once (Advanced)
Merge all feature branches into a single integration branch first, then merge to main. This approach is more complex but ensures all features work together.

## Testing After Resolution

For each merged PR, test:

### PR #4:
- Start a focus session
- Stop a focus session
- Verify streak calculation
- Check persistent storage
- Test weekly heatmap display

### PR #5:
- Create tasks with different deadline proximities
- Verify color coding (warn/danger/overdue)
- Check urgent section in sidebar
- Test deadline severity updates
- Verify Zen mode disables animations

### PR #6:
- Export a week schedule to PDF
- Export a month schedule to PDF
- Verify PDF content and formatting
- Test command palette integration
- Check file picker functionality

### PR #7:
- Start a Pomodoro session (25/5 preset)
- Test pause/resume functionality
- Verify automatic work/break transitions
- Test long break after 4 rounds
- Check statistics accuracy
- Verify Ctrl+P shortcut

## Potential Integration Issues

### 1. Database/Storage Schema
- PR #4 adds focus_sessions.json
- PR #7 adds focus_session_active.json and focus_session_history.json
- Ensure storage locations don't conflict

### 2. PlannerBackend Size
All PRs modify PlannerBackend, which could become large. Consider:
- Splitting into multiple service classes
- Using composition over inheritance
- Extracting services to separate classes

### 3. UI Overlay Management
Both PR #6 and PR #7 add modal overlays:
- ExportDialog (PR #6)
- PomodoroOverlay (PR #7)
- Ensure proper z-order and focus management

### 4. Command Palette Commands
PR #6 and PR #7 both add commands. Ensure:
- Unique command IDs
- No keyword conflicts
- Proper command categorization

## Success Criteria

After resolving all conflicts, verify:

✅ All PRs show as "mergeable" on GitHub  
✅ No build errors in CMake  
✅ No QML errors at runtime  
✅ All features function as described in PR descriptions  
✅ No regression in existing main branch functionality  
✅ Features can be used together without conflicts  

## Rollback Plan

If integration issues arise:

1. Each PR is on its own branch - easy to revert
2. Create integration testing branch before merging to main
3. Use GitHub's "Revert Pull Request" if needed after merge
4. Feature flags could be added for gradual rollout

## Additional Notes

- All PRs follow similar patterns (Backend extension + QML UI)
- Code style appears consistent across PRs
- Documentation is provided with each PR
- No breaking API changes in any PR
- All PRs are additive (no deletions of existing functionality)

This makes conflict resolution straightforward - mostly about merging additions rather than resolving contradictory changes.
