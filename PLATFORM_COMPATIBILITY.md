# Platform Compatibility Guide

Noah Planner is designed to run on **Linux** and **Windows 10/11** systems with full feature parity.

## Supported Platforms

### ✅ Fully Supported

| Platform | Version | Status | Notes |
|----------|---------|--------|-------|
| **Linux** | Fedora 38+ | ✅ Primary | Native Qt6 packages available |
| **Linux** | Ubuntu 22.04+ | ✅ Tested | Qt6 via official repos |
| **Linux** | Debian 12+ | ✅ Tested | Qt6 via official repos |
| **Windows** | Windows 10 (64-bit) | ✅ Supported | MSVC or MinGW compiler required |
| **Windows** | Windows 11 | ✅ Supported | Native experience |

### 🔄 Should Work (Untested)

| Platform | Notes |
|----------|-------|
| **Linux** | Arch, Manjaro, openSUSE | Qt6 available via package manager |
| **macOS** | 10.15+ with Qt6 | Qt cross-platform support |

## Cross-Platform Features

All features work identically across platforms:

- ✅ Local JSON data storage
- ✅ QSettings persistence (platform-specific locations)
- ✅ File operations (QFile, QDir)
- ✅ PDF export
- ✅ Qt Quick UI rendering
- ✅ Keyboard shortcuts (Ctrl on Win/Linux, Cmd on macOS)

## Platform-Specific Behaviors

### Data Storage Locations

**Linux:**
- Config: `~/.config/noah/planner.conf`
- Data: `~/.local/share/NoahPlanner/`

**Windows:**
- Config: Registry `HKEY_CURRENT_USER\Software\noah\planner` or `%APPDATA%\noah\planner.ini`
- Data: `C:\Users\<username>\AppData\Local\NoahPlanner\`

**macOS** (untested):
- Config: `~/Library/Preferences/noah.planner.plist`
- Data: `~/Library/Application Support/NoahPlanner/`

### File Paths

All file path operations use Qt's cross-platform APIs:
- `QDir::filePath()` for path construction
- `QStandardPaths` for system directories
- Forward slashes (`/`) in literals (Qt converts automatically)

### Line Endings

- Shell scripts (`.sh`): LF (Unix line endings)
- Batch scripts (`.bat`): CRLF (Windows line endings)
- Source code (`.cpp`, `.h`, `.qml`): LF (Unix line endings, Git handles conversion)

## Build System

### CMake

The project uses CMake 3.16+ for cross-platform builds:

```cmake
# Automatic platform detection
if(WIN32)
    # Windows-specific settings
    add_definitions(-DUNICODE -D_UNICODE)
elseif(UNIX AND NOT APPLE)
    # Linux-specific settings
elseif(APPLE)
    # macOS-specific settings
endif()
```

### Compiler Support

| Compiler | Platform | Minimum Version |
|----------|----------|-----------------|
| GCC | Linux | 9.0+ (C++17) |
| Clang | Linux/macOS | 10.0+ (C++17) |
| MSVC | Windows | 2019 (v142) |
| MinGW | Windows | GCC 9.0+ |

## Qt6 Requirements

- **Minimum Qt Version**: 6.4.0
- **Recommended Qt Version**: 6.5.0+

### Required Qt Modules

- Qt6::Core
- Qt6::Quick
- Qt6::Qml
- Qt6::QuickControls2
- Qt6::QuickLayouts
- Qt6::Widgets
- Qt6::Sql
- Qt6::PrintSupport

## Build Instructions by Platform

### Linux (Quick)
```bash
./run.sh
```

### Windows (Quick)
```cmd
set CMAKE_PREFIX_PATH=C:\Qt\6.5.0\msvc2019_64
run.bat
```

For detailed instructions, see:
- Linux: [README.md](README.md)
- Windows: [WINDOWS_SETUP.md](WINDOWS_SETUP.md)

## Known Platform Differences

### Console Output

**Linux:**
- Application runs in terminal
- `qInfo()`, `qWarning()`, `qDebug()` visible in terminal

**Windows:**
- Console window appears by default (for debugging)
- Output visible in console
- For production, can be hidden by uncommenting `set(CMAKE_WIN32_EXECUTABLE ON)` in CMakeLists.txt

### Font Rendering

- **Linux**: Uses system font rendering (FreeType)
- **Windows**: Uses DirectWrite
- Application includes Inter font as embedded resource for consistency

### File Dialogs

Qt automatically uses native file dialogs:
- **Linux**: GTK or KDE file picker (depending on desktop environment)
- **Windows**: Windows Explorer file picker

## Testing Checklist

When testing cross-platform compatibility:

- [ ] Application launches successfully
- [ ] Data directory created in correct location
- [ ] JSON files read/write correctly
- [ ] Settings persist across sessions
- [ ] UI renders correctly (fonts, layouts, themes)
- [ ] Keyboard shortcuts work (Ctrl vs Cmd)
- [ ] File operations succeed (open, save, export PDF)
- [ ] Window management works (minimize, maximize, close)
- [ ] Dark/Light theme switching works
- [ ] All QML components load without errors

## Troubleshooting by Platform

### Linux

**Qt6 not found:**
```bash
# Fedora
sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel

# Ubuntu/Debian
sudo apt install qt6-base-dev qt6-declarative-dev
```

**Permissions issue with data directory:**
```bash
chmod 755 ~/.local/share/NoahPlanner
```

### Windows

**Qt6 not found:**
- Set `CMAKE_PREFIX_PATH` environment variable
- Ensure Qt6 bin directory is in PATH

**MSVC not found:**
- Install "Build Tools for Visual Studio"
- Use "x64 Native Tools Command Prompt"

**Application won't start (missing DLLs):**
```cmd
# Deploy Qt DLLs
C:\Qt\6.5.0\msvc2019_64\bin\windeployqt.exe build\Release\noah_planner.exe
```

## Developer Notes

### Code Style

For cross-platform compatibility:

```cpp
// ✅ GOOD - Cross-platform
QString path = QDir(dir).filePath("file.txt");

// ❌ BAD - Hardcoded separator
QString path = dir + "/file.txt";  // Works but less robust

// ❌ BAD - Windows-specific
QString path = dir + "\\file.txt";  // Fails on Linux
```

### Platform-Specific Code

Use Qt's platform macros when needed:

```cpp
#ifdef Q_OS_WIN
    // Windows-specific code
#elif defined(Q_OS_LINUX)
    // Linux-specific code
#elif defined(Q_OS_MACOS)
    // macOS-specific code
#endif
```

### Testing on Multiple Platforms

1. Test on both Windows and Linux before release
2. Check console output for warnings
3. Verify file paths in log messages
4. Test with different Qt versions (6.4, 6.5, 6.6)

## Contributing

When submitting cross-platform changes:

1. Test on at least two platforms (Win + Linux)
2. Avoid platform-specific APIs unless necessary
3. Use Qt's cross-platform abstractions
4. Document any platform-specific behavior
5. Update this guide if adding new platform features

## Future Platform Support

### Planned
- 📋 **Flatpak** (Linux) - Universal package format
- 📋 **AppImage** (Linux) - Portable Linux binary
- 📋 **MSIX** (Windows) - Modern Windows packaging

### Considering
- 🤔 **macOS** native build
- 🤔 **FreeBSD** support (if Qt6 available)

---

**Last Updated:** 2025-01-30  
**Tested Configurations:**
- Fedora 39 + Qt 6.5.0 + GCC 13
- Windows 11 + Qt 6.5.0 + MSVC 2019

For issues related to platform compatibility, please open a GitHub issue with:
- Operating System and version
- Qt version
- Compiler version
- Full error message or build log
