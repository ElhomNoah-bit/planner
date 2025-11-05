@echo off
REM Noah Planner Build & Run Script for Windows
REM Requirements:
REM   - CMake 3.16 or higher
REM   - Qt6 (6.4 or higher) with Qt6Config.cmake in PATH
REM   - Visual Studio Build Tools or MinGW with C++17 support

setlocal enabledelayedexpansion

set "PACKAGE_MANAGER="
where winget >nul 2>nul
if %ERRORLEVEL%==0 set "PACKAGE_MANAGER=winget"

if "%PACKAGE_MANAGER%"=="" (
    where choco >nul 2>nul
    if %ERRORLEVEL%==0 set "PACKAGE_MANAGER=choco"
)

echo ========================================
echo Noah Planner v2.0 - Windows Build
echo ========================================
echo.

if "%PACKAGE_MANAGER%"=="" (
    echo INFO: No supported package manager detected. Automatic dependency installation disabled.
) else (
    echo INFO: Using %PACKAGE_MANAGER% for dependency installation when required.
)
echo.

REM Ensure CMake is available (install if missing)
call :ensure_tool cmake "Kitware.CMake" "cmake" "CMake 3.16 or higher"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: CMake not found in PATH and automatic installation failed.
    echo Please install CMake 3.16 or higher manually if automatic installation is not possible.
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
        call :attempt_install_qt
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

REM Find and run the application
if exist "%BUILD_DIR%\Release\noah_planner.exe" (
    "%BUILD_DIR%\Release\noah_planner.exe"
) else if exist "%BUILD_DIR%\Debug\noah_planner.exe" (
    "%BUILD_DIR%\Debug\noah_planner.exe"
) else if exist "%BUILD_DIR%\noah_planner.exe" (
    "%BUILD_DIR%\noah_planner.exe"
) else (
    echo ERROR: noah_planner.exe not found
    echo Checked locations:
    echo   - %BUILD_DIR%\Release\noah_planner.exe
    echo   - %BUILD_DIR%\Debug\noah_planner.exe
    echo   - %BUILD_DIR%\noah_planner.exe
    pause
    exit /b 1
)

endlocal
goto :EOF

:ensure_tool
set "TOOL_NAME=%~1"
set "WINGET_ID=%~2"
set "CHOCO_ID=%~3"
set "TOOL_DESC=%~4"

where %TOOL_NAME% >nul 2>nul
if %ERRORLEVEL%==0 exit /b 0

echo.
echo Missing dependency detected: %TOOL_DESC%

if /I "%PACKAGE_MANAGER%"=="winget" (
    if "%WINGET_ID%"=="" (
        echo INFO: No winget package configured for %TOOL_DESC%. Skipping automatic installation.
    ) else (
        echo Attempting to install %TOOL_DESC% via winget...
        winget install --id %WINGET_ID% -e --accept-package-agreements --accept-source-agreements
        if %ERRORLEVEL% EQU 0 (
            call :post_install_path_adjust "%TOOL_NAME%"
            where %TOOL_NAME% >nul 2>nul
            if %ERRORLEVEL%==0 exit /b 0
        )
        echo WARNING: winget installation for %TOOL_DESC% did not complete successfully.
    )
)

if /I "%PACKAGE_MANAGER%"=="choco" (
    if "%CHOCO_ID%"=="" (
        echo INFO: No Chocolatey package configured for %TOOL_DESC%. Skipping automatic installation.
    ) else (
        echo Attempting to install %TOOL_DESC% via Chocolatey...
        choco install %CHOCO_ID% -y
        if %ERRORLEVEL% EQU 0 (
            call :post_install_path_adjust "%TOOL_NAME%"
            where %TOOL_NAME% >nul 2>nul
            if %ERRORLEVEL%==0 exit /b 0
        )
        echo WARNING: Chocolatey installation for %TOOL_DESC% did not complete successfully.
    )
)

if "%PACKAGE_MANAGER%"=="" (
    echo INFO: Automatic installation not available. Please install %TOOL_DESC% manually.
)

exit /b 1

:post_install_path_adjust
set "TOOL=%~1"

if /I "%TOOL%"=="cmake" (
    if exist "%ProgramFiles%\CMake\bin\cmake.exe" (
        set "PATH=%ProgramFiles%\CMake\bin;!PATH!"
    ) else (
        if defined ProgramFiles(x86) (
            if exist "%ProgramFiles(x86)%\CMake\bin\cmake.exe" (
                set "PATH=%ProgramFiles(x86)%\CMake\bin;!PATH!"
            )
        )
    )
)

exit /b 0

:attempt_install_qt
if "%PACKAGE_MANAGER%"=="" (
    echo INFO: Automatic Qt installation skipped (no supported package manager detected).
    exit /b 0
)

if /I "%PACKAGE_MANAGER%"=="winget" (
    echo Attempting to install Qt6 via winget (an interactive installer may appear)...
    winget install --id TheQtCompany.Qt -e --accept-package-agreements --accept-source-agreements
    if errorlevel 1 (
        echo WARNING: Automatic Qt installation via winget may not have completed successfully.
    )
    exit /b 0
)

if /I "%PACKAGE_MANAGER%"=="choco" (
    echo Attempting to install Qt6 via Chocolatey...
    choco install qt -y
    if errorlevel 1 (
        echo WARNING: Automatic Qt installation via Chocolatey may not have completed successfully.
    )
    exit /b 0
)

exit /b 0
