# Development Documentation

This directory contains technical documentation for developers working on Noah Planner.

## 📋 Contents

### Technical Documentation

- **[README_DEV.md](README_DEV.md)** - Comprehensive developer guide
  - Zen Mode implementation
  - Category System architecture
  - Drag & Drop implementation
  - Keyboard shortcuts
  - Settings & persistence
  - Technical architecture overview

### Implementation Reports

- **[IMPLEMENTATION_NOTES.md](IMPLEMENTATION_NOTES.md)** - Automatic task prioritization implementation
  - Problem statement requirements
  - Implementation approach
  - Architecture decisions
  - Priority algorithm details

- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Feature implementation overview
  - Completed features (8 of 8)
  - Zen Mode / Tagesfokus
  - Drag & Drop Rescheduling
  - And more...

- **[IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md)** - Feature implementation tracking
  - Project overview
  - Build environment notes
  - Implementation progress
  - Status updates

### Platform Support

- **[CHANGELOG_WINDOWS_COMPATIBILITY.md](CHANGELOG_WINDOWS_COMPATIBILITY.md)** - Windows support changelog
  - Windows 10/11 compatibility
  - Build system improvements
  - Cross-platform path handling
  - Migration guide

## 🏗️ Architecture Overview

Noah Planner follows a **Qt MVVM architecture**:

- **Core Layer** (`src/core/`) - Domain classes and business logic
- **Model Layer** (`src/models/`) - QAbstractListModel implementations
- **UI Layer** (`src/ui/`) - PlannerBackend, AppState, and QML views
- **QML Frontend** (`src/ui/qml/`) - UI components and views

## 🔧 Key Technologies

- **Framework**: Qt 6.4+ (Qt Quick, QML)
- **Language**: C++17
- **Build System**: CMake 3.16+
- **Data Storage**: JSON files (local)
- **Settings**: QSettings (platform-specific)

## 📚 Development Workflow

1. Read [README_DEV.md](README_DEV.md) for technical details
2. Review [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) for feature overview
3. Check [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) for current state
4. Follow platform-specific setup in [../setup/](../setup/)

## 🧪 Testing

- Build environment requirements in documentation
- Manual testing procedures in feature docs
- Integration testing for platform compatibility

## 📌 Related Documentation

- [Main README](../../README.md) - Project overview
- [Setup Documentation](../setup/) - Installation guides
- [Feature Documentation](../features/) - User-facing features
- [Documentation Index](../INDEX.md) - Complete overview
