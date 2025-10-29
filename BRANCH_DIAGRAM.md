# Branch Relationship Diagram

This document visualizes the current state of branches and merge conflicts.

## Current State

```
main (3003768d)
│
├── Commit history before PR #3
│   └── 7eb9e69c ← All feature branches created from here
│       │
│       ├── copilot/add-focus-session-module (PR #4)
│       │   └── 5db83d2 [DIRTY - has conflicts with main]
│       │
│       ├── copilot/add-deadline-stress-display (PR #5)
│       │   └── daaed63 [DIRTY - has conflicts with main]
│       │
│       ├── copilot/add-pdf-exporter-functionality (PR #6)
│       │   └── 07e43b5 [DIRTY - has conflicts with main]
│       │
│       └── copilot/add-pomodoro-focus-timer (PR #7)
│           └── ab4c61e [DIRTY - has conflicts with main]
│
└── PR #3 merged (11,085 lines added)
    └── 3003768d ← Current main


copilot/resolve-merge-conflicts (PR #8 - This PR)
└── 17a5adb [Contains merge conflict documentation]
    └── Docs to help resolve PRs #4-7
```

## What Needs to Happen

```
Goal: Update each feature branch with main's changes

Before:
┌─────────────┐
│ Feature #4  │ (based on 7eb9e69c)
└─────────────┘
       ↓ CONFLICT
┌─────────────┐
│    main     │ (at 3003768d)
└─────────────┘

After Resolution:
┌─────────────┐
│ Feature #4  │ (includes main changes)
└─────────────┘
       ↓ MERGEABLE ✓
┌─────────────┐
│    main     │ (at 3003768d)
└─────────────┘
```

## Merge Strategy Visualization

### Option 1: Merge main into feature branches (Recommended)

```
Before:
main:      A---B---C---[PR #3]---D
                   \
feature:            E---F---G

After merge:
main:      A---B---C---[PR #3]---D
                   \               \
feature:            E---F---G-------H (merge commit)

Result: Feature branch is up to date with main
```

### Option 2: Rebase feature branches onto main (Alternative)

```
Before:
main:      A---B---C---[PR #3]---D
                   \
feature:            E---F---G

After rebase:
main:      A---B---C---[PR #3]---D
                                  \
feature:                           E'---F'---G' (rebased commits)

Result: Cleaner linear history
```

## Conflict Zones by File

```
CMakeLists.txt
├── main branch:     Qt6 components list
├── PR #4:          + FocusSession sources
├── PR #6:          + ScheduleExporter sources + PrintSupport
└── PR #7:          + PomodoroTimer sources

PlannerBackend.h
├── main branch:     Base class structure
├── PR #4:          + focus session methods
├── PR #5:          + deadline severity methods
├── PR #6:          + PDF export methods
└── PR #7:          + PomodoroTimer property

src/ui/qml/views/SidebarToday.qml
├── main branch:     Basic sidebar layout
├── PR #4:          + StreakBadge + FocusControls
├── PR #5:          + "Dringend" urgent section
└── PR #7:          + Pomodoro start button
```

## Resolution Flow

```
┌─────────────────┐
│  Start          │
└────────┬────────┘
         │
    ┌────▼────┐
    │ PR #5   │ (Simplest - 474 lines)
    └────┬────┘
         │ Resolve & Merge
    ┌────▼────┐
    │ PR #6   │ (Independent - 2,459 lines)
    └────┬────┘
         │ Resolve & Merge
    ┌────▼────┐
    │ PR #4   │ (Foundation - 2,610 lines)
    └────┬────┘
         │ Resolve & Merge
    ┌────▼────┐
    │ PR #7   │ (Builds on #4 - 1,571 lines)
    └────┬────┘
         │ Resolve & Merge
    ┌────▼────┐
    │  Done   │ All features in main!
    └─────────┘
```

## Dependency Graph

```
         ┌─────────┐
         │  main   │
         └────┬────┘
              │
      ┌───────┴───────┐
      │               │
  ┌───▼───┐       ┌───▼───┐
  │ PR #5 │       │ PR #6 │
  │(Indie)│       │(Indie)│
  └───────┘       └───────┘
      │               │
      │           ┌───▼───┐
      │           │ PR #4 │
      │           │(Base) │
      │           └───┬───┘
      │               │
      │           ┌───▼───┐
      │           │ PR #7 │
      │           │(Deps) │
      │           └───────┘
      │               │
      └───────┬───────┘
              │
          ┌───▼───┐
          │  ALL  │
          │MERGED │
          └───────┘

Legend:
(Indie) = Independent, no dependencies
(Base)  = Base for other features
(Deps)  = Has dependencies on other PRs
```

## Timeline

```
Past                Present              Future
│                   │                    │
│  Initial          │  Feature           │  After
│  Commit           │  Branches          │  Resolution
│  7eb9e69c         │  Created           │
│                   │                    │
├──────┬────────────┼────────────────────┼─────►
       │            │                    │
       │   PR #3    │  PRs #4-7         │  PRs #4-7
       │   Merged   │  in conflict      │  mergeable
       │   to main  │                   │
       │            │                    │
       └────────────┼────────────────────►
                    │  3003768d          │
                    │  (current)         │
                    │                    │
                    │  Resolution        │
                    │  Docs Created      │
                    │  (PR #8)           │
```

## File Overlap Matrix

Shows which files are modified by multiple PRs:

```
File                          PR#4  PR#5  PR#6  PR#7
─────────────────────────────────────────────────────
CMakeLists.txt                 ✓     -     ✓     ✓
PlannerBackend.h               ✓     ✓     ✓     ✓
PlannerBackend.cpp             ✓     ✓     ✓     ✓
SidebarToday.qml               ✓     ✓     -     ✓
CommandPalette.qml             -     -     ✓     ✓
ThemeStore.qml                 -     ✓     -     -
EventChip.qml                  -     ✓     -     -
App.qml                        -     -     -     ✓

New files (no conflicts):
FocusSession*                  ✓     -     -     ✓  ← Shared
ScheduleExporter*              -     -     ✓     -
PomodoroTimer*                 -     -     -     ✓
StreakBadge.qml                ✓     -     -     -
ExportDialog.qml               -     -     ✓     -
PomodoroOverlay.qml            -     -     -     ✓
```

## Success Path

```
Current State → Resolution → Testing → Merging
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[4 PRs]        [Run script]   [Build OK]    [All merged]
 DIRTY      →   or manual  →   Test OK   →   to main
              ━━━━━━━━━━━━
              Takes 2-4hrs
```

## Summary Statistics

```
Total Lines to Integrate: 7,114 additions
Total Files to Resolve:   ~15-20 unique files
Total PRs:                4
Time Estimate:            2-4 hours
Documentation Created:    ~30 KB (5 files)
Automation:               1 bash script (7.2 KB)
```

---

This diagram helps visualize the relationships between branches, conflicts, and the resolution process.
