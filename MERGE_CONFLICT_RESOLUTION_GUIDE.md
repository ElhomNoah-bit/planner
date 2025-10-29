# Merge Conflict Resolution Guide

This guide provides instructions for resolving merge conflicts in all open pull requests in the planner repository.

## Summary

Four open pull requests have merge conflicts with the `main` branch:

1. **PR #4**: Focus session tracking with streak gamification
2. **PR #5**: Deadline stress indicator with visual emphasis  
3. **PR #6**: PDF export for week and month schedules
4. **PR #7**: Pomodoro focus timer with auto-transitions

All these PRs were created before the major merge of PR #3 (automatic task prioritization), which added the foundational application structure to `main`.

## Resolution Strategy

**Preferred Approach**: Keep changes from feature branches when conflicts occur, as instructed.

## Step-by-Step Instructions

### Prerequisites

```bash
# Ensure you're in the repository directory
cd /path/to/planner

# Fetch latest changes
git fetch origin
```

### Resolving PR #4: Focus Session Tracking

```bash
# Checkout the feature branch
git checkout copilot/add-focus-session-module

# Update with latest from origin
git pull origin copilot/add-focus-session-module

# Merge main into the feature branch
git merge origin/main

# If conflicts occur:
# 1. Git will mark conflicted files
# 2. For each conflict, prefer the feature branch version
# 3. Look for conflict markers: <<<<<<<, =======, >>>>>>>
# 4. Keep the code between ======= and >>>>>>> (feature branch)
# 5. Or use: git checkout --ours <file> to keep feature branch version

# Common conflicting files for PR #4:
# - CMakeLists.txt (likely needs both changes merged)
# - src/ui/PlannerBackend.h (add new focus session methods)
# - src/ui/PlannerBackend.cpp (add new focus session implementations)
# - src/ui/qml/views/SidebarToday.qml (add new UI components)

# After resolving conflicts:
git add .
git commit -m "Merge main into focus session tracking (prefer feature branch changes)"
git push origin copilot/add-focus-session-module
```

### Resolving PR #5: Deadline Stress Indicator

```bash
# Checkout the feature branch
git checkout copilot/add-deadline-stress-display

# Update with latest from origin
git pull origin copilot/add-deadline-stress-display

# Merge main into the feature branch
git merge origin/main

# Common conflicting files for PR #5:
# - src/ui/PlannerBackend.h (add deadline severity methods)
# - src/ui/PlannerBackend.cpp (add deadline severity implementations)
# - src/ui/qml/components/EventChip.qml (add stress indicators)
# - src/ui/qml/views/SidebarToday.qml (add urgent section)
# - src/ui/qml/styles/ThemeStore.qml (add warn/overdue colors)

# Resolution approach:
# - For PlannerBackend files: Add new methods/properties to existing structure
# - For QML files: Integrate new UI elements into existing layouts
# - For ThemeStore: Add new color definitions

# After resolving conflicts:
git add .
git commit -m "Merge main into deadline stress indicator (prefer feature branch changes)"
git push origin copilot/add-deadline-stress-display
```

### Resolving PR #6: PDF Export

```bash
# Checkout the feature branch
git checkout copilot/add-pdf-exporter-functionality

# Update with latest from origin
git pull origin copilot/add-pdf-exporter-functionality

# Merge main into the feature branch
git merge origin/main

# Common conflicting files for PR #6:
# - CMakeLists.txt (add PrintSupport Qt module)
# - src/ui/PlannerBackend.h (add export methods)
# - src/ui/PlannerBackend.cpp (add export implementations)
# - src/ui/qml/components/CommandPalette.qml (add export commands)

# Resolution approach:
# - CMakeLists.txt: Add PrintSupport to existing Qt6 components
# - PlannerBackend: Add export methods alongside existing methods
# - New files (ScheduleExporter.h/cpp, ExportDialog.qml): Keep as-is

# After resolving conflicts:
git add .
git commit -m "Merge main into PDF export (prefer feature branch changes)"
git push origin copilot/add-pdf-exporter-functionality
```

### Resolving PR #7: Pomodoro Timer

```bash
# Checkout the feature branch
git checkout copilot/add-pomodoro-focus-timer

# Update with latest from origin
git pull origin copilot/add-pomodoro-focus-timer

# Merge main into the feature branch
git merge origin/main

# Common conflicting files for PR #7:
# - CMakeLists.txt (add new source files)
# - src/ui/PlannerBackend.h (add PomodoroTimer property)
# - src/ui/PlannerBackend.cpp (initialize PomodoroTimer)
# - src/ui/qml/App.qml (add keyboard shortcut)
# - src/ui/qml/views/SidebarToday.qml (add Pomodoro button)

# Resolution approach:
# - Keep all Pomodoro-related code from feature branch
# - Integrate with existing PlannerBackend structure
# - New files (PomodoroTimer.h/cpp, FocusSession.h, etc.): Keep as-is

# After resolving conflicts:
git add .
git commit -m "Merge main into Pomodoro timer (prefer feature branch changes)"
git push origin copilot/add-pomodoro-focus-timer
```

## Conflict Resolution Tips

### CMakeLists.txt
This file will likely conflict in all PRs. Merge strategy:
1. Keep the Qt6 component list from main
2. Add new components from feature branches (e.g., PrintSupport for PR #6)
3. Add new source files from feature branches
4. Keep all existing source files from main

### PlannerBackend.h/cpp
These files will conflict in multiple PRs. Merge strategy:
1. Keep the base class structure from main
2. Add new methods and properties from each feature branch
3. Add new includes for feature-specific classes
4. Initialize new components in constructor

### QML Files
For QML component conflicts:
1. Keep base structure from main
2. Add new UI elements from feature branches
3. Ensure proper spacing and layout integration
4. Test that new elements don't overlap

## Automated Helper Script

See `resolve_merge_conflicts.sh` for an automated approach (use with caution and review changes).

## Verification

After resolving conflicts in each PR:

1. Verify the PR shows as mergeable on GitHub
2. Check CI/CD if configured
3. Test the feature locally:
   ```bash
   mkdir -p build && cd build
   cmake ..
   make
   ./planner
   ```

## Order of Resolution

Recommended order (from simplest to most complex):
1. PR #5 (Deadline stress - smallest changes)
2. PR #6 (PDF export - moderate changes, fewer dependencies)
3. PR #4 (Focus sessions - depends on PR #7 concept)
4. PR #7 (Pomodoro - most complex, builds on PR #4)

Or resolve in numerical order (#4, #5, #6, #7) to follow development sequence.

## Getting Help

If conflicts are too complex:
1. Review the PR description for implementation details
2. Check the original commits in each branch
3. Use `git log --oneline --graph --all` to visualize branch relationships
4. Consider rebasing instead of merging for cleaner history

## Alternative: Rebase Instead of Merge

For a cleaner history, consider rebasing:

```bash
git checkout <feature-branch>
git rebase origin/main

# Resolve conflicts at each commit
# Follow prompts from Git

git push --force-with-lease origin <feature-branch>
```

**Warning**: Only use `--force-with-lease` if you're sure no one else is working on the branch.
