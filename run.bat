@echo off
REM Noah Planner Build & Run Script for Windows
REM Requirements:
REM   - CMake 3.16 or higher
REM   - Qt6 (6.4 or higher) with Qt6Config.cmake in PATH
REM   - Visual Studio Build Tools or MinGW with C++17 support

setlocal enabledelayedexpansion

echo ========================================
echo Noah Planner v2.0 - Windows Build
echo ========================================
echo.

REM Check if CMake is installed
where cmake >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: CMake not found in PATH
    echo Please install CMake 3.16 or higher
    echo Download from: https://cmake.org/download/
    pause
    exit /b 1
)

REM Check if Qt6 is available (basic check)
if "%Qt6_DIR%"=="" (
    if "%CMAKE_PREFIX_PATH%"=="" (
        echo WARNING: Qt6_DIR and CMAKE_PREFIX_PATH not set
        echo.
        echo Please ensure Qt6 is installed and set one of:
        echo   set Qt6_DIR=C:\Qt\6.5.0\msvc2019_64\lib\cmake\Qt6
        echo   or
        echo   set CMAKE_PREFIX_PATH=C:\Qt\6.5.0\msvc2019_64
        echo.
        echo Attempting build anyway...
        echo.
    )
)

REM Create build directory
set BUILD_DIR=build
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

echo Configuring CMake...
cmake -S . -B "%BUILD_DIR%" -DCMAKE_BUILD_TYPE=Release
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: CMake configuration failed
    echo.
    echo Common solutions:
    echo 1. Set Qt6 path: set CMAKE_PREFIX_PATH=C:\Qt\6.5.0\msvc2019_64
    echo 2. Install Qt6 from https://www.qt.io/download
    echo 3. Ensure Visual Studio Build Tools are installed
    pause
    exit /b 1
)

echo.
echo Building project...
cmake --build "%BUILD_DIR%" --config Release --parallel
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Build failed
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build successful!
echo ========================================
echo.
echo Starting Noah Planner...
echo.

REM Run the application
"%BUILD_DIR%\Release\noah_planner.exe"
if not exist "%BUILD_DIR%\Release\noah_planner.exe" (
    REM Try debug build location
    "%BUILD_DIR%\Debug\noah_planner.exe"
    if not exist "%BUILD_DIR%\Debug\noah_planner.exe" (
        REM Try root build location (some generators place exe here)
        "%BUILD_DIR%\noah_planner.exe"
        if not exist "%BUILD_DIR%\noah_planner.exe" (
            echo ERROR: noah_planner.exe not found
            echo Checked locations:
            echo   - %BUILD_DIR%\Release\noah_planner.exe
            echo   - %BUILD_DIR%\Debug\noah_planner.exe
            echo   - %BUILD_DIR%\noah_planner.exe
            pause
            exit /b 1
        )
    )
)

endlocal
