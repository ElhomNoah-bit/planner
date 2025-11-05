@echo off
REM Noah Planner Build & Run Script for Windows
REM Requirements:
REM   - CMake 3.16 or higher
REM   - Qt6 (6.4 or higher) with Qt6Config.cmake in PATH
REM   - Visual Studio Build Tools or MinGW with C++17 support

set "EXIT_CODE=0"
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%" >nul

set "SKIP_PAUSE="
if not "%~1"=="" (
    for %%A in (%*) do (
        if /I "%%~A"=="--no-pause" set "SKIP_PAUSE=1"
    )
)

set "QT_TOOLCHAIN_TYPE="
set "QT_ROOT_DIR="
set "MINGW_BIN_DIR="
set "CMAKE_GENERATOR_OPTION="
set "CMAKE_COMPILER_OPTIONS="
set "TARGET_GENERATOR="

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
    set "EXIT_CODE=1"
    goto :cleanup
)

call :configure_qt_env
call :prepare_toolchain

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
        call :configure_qt_env
        call :prepare_toolchain
        echo Attempting build anyway...
        echo.
    )
)

REM Create build directory
set BUILD_DIR=build
call :ensure_clean_build_dir
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

echo Configuring CMake...
cmake -S . -B "%BUILD_DIR%" -DCMAKE_BUILD_TYPE=Release %CMAKE_GENERATOR_OPTION% %CMAKE_COMPILER_OPTIONS%
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: CMake configuration failed
    echo.
    echo Common solutions:
    echo 1. Set Qt6 path: set CMAKE_PREFIX_PATH=C:\Qt\6.5.0\msvc2019_64
    echo 2. Install Qt6 from https://www.qt.io/download
    echo 3. Ensure Visual Studio Build Tools are installed
    pause
    set "EXIT_CODE=1"
    goto :cleanup
)

echo.
echo Building project...
cmake --build "%BUILD_DIR%" %CMAKE_BUILD_CONFIG_SWITCH% --parallel
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Build failed
    pause
    set "EXIT_CODE=1"
    goto :cleanup
)

echo.
echo ========================================
echo Build successful!
echo ========================================
echo.
echo Starting Noah Planner...
echo.

set "APP_PATH="
if exist "%BUILD_DIR%\Release\noah_planner.exe" set "APP_PATH=%BUILD_DIR%\Release\noah_planner.exe"
if "%APP_PATH%"=="" if exist "%BUILD_DIR%\Debug\noah_planner.exe" set "APP_PATH=%BUILD_DIR%\Debug\noah_planner.exe"
if "%APP_PATH%"=="" if exist "%BUILD_DIR%\noah_planner.exe" set "APP_PATH=%BUILD_DIR%\noah_planner.exe"

if "%APP_PATH%"=="" (
    echo ERROR: noah_planner.exe not found
    echo Checked locations:
    echo   - %BUILD_DIR%\Release\noah_planner.exe
    echo   - %BUILD_DIR%\Debug\noah_planner.exe
    echo   - %BUILD_DIR%\noah_planner.exe
    pause
    set "EXIT_CODE=1"
    goto :cleanup
)

call :deploy_qt_dependencies "%APP_PATH%"
if %ERRORLEVEL% NEQ 0 (
    echo WARNING: Qt runtime deployment failed. The application may not start correctly.
)

"%APP_PATH%"

if not defined SKIP_PAUSE (
    echo.
    pause
)

set "EXIT_CODE=0"
goto :cleanup

:ensure_clean_build_dir
if not exist "%BUILD_DIR%\CMakeCache.txt" exit /b 0

set "CURRENT_GENERATOR="
for /f "tokens=2 delims==" %%G in ('findstr /R /C:"^CMAKE_GENERATOR:INTERNAL=" "%BUILD_DIR%\CMakeCache.txt" 2^>nul') do (
    if not defined CURRENT_GENERATOR (
        for /f "tokens=*" %%H in ("%%G") do set "CURRENT_GENERATOR=%%H"
    )
)

if "%TARGET_GENERATOR%"=="" (
    set "CURRENT_GENERATOR="
    exit /b 0
)

if /I "!CURRENT_GENERATOR!"=="%TARGET_GENERATOR%" (
    set "CURRENT_GENERATOR="
    exit /b 0
)

echo INFO: Clearing build directory (cached generator "!CURRENT_GENERATOR!" differs from target "%TARGET_GENERATOR%").
call :clean_build_dir
set "CURRENT_GENERATOR="
exit /b 0

:clean_build_dir
if exist "%BUILD_DIR%" (
    rmdir /s /q "%BUILD_DIR%" >nul 2>nul
)
exit /b 0

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

:cleanup
set "CODE=!EXIT_CODE!"
popd >nul
endlocal & exit /b %CODE%

:find_windeployqt
set "WINDEPLOYQT_PATH="

for /f "delims=" %%I in ('where windeployqt 2^>nul') do (
    if not defined WINDEPLOYQT_PATH set "WINDEPLOYQT_PATH=%%~fI"
)

if defined WINDEPLOYQT_PATH exit /b 0

call :_ensure_qt_root_dir

if defined QT_ROOT_DIR (
    if exist "%QT_ROOT_DIR%\bin\windeployqt.exe" (
        set "WINDEPLOYQT_PATH=%QT_ROOT_DIR%\bin\windeployqt.exe"
        exit /b 0
    )
)

for %%B in ("%ProgramFiles%\Qt" "C:\Qt" "%ProgramFiles(x86)%\Qt" "%USERPROFILE%\Qt" "%USERPROFILE%\AppData\Local\Programs\Qt") do (
    if not defined WINDEPLOYQT_PATH (
        if exist "%%~fB" (
            for /f "delims=" %%F in ('dir /b /s "%%~fB\windeployqt.exe" 2^>nul') do (
                if not defined WINDEPLOYQT_PATH set "WINDEPLOYQT_PATH=%%~fF"
            )
        )
    )
)

if defined WINDEPLOYQT_PATH exit /b 0

exit /b 1

:deploy_qt_dependencies
set "TARGET_EXE=%~1"
if "%TARGET_EXE%"=="" exit /b 1

call :find_windeployqt
if not defined WINDEPLOYQT_PATH (
    echo WARNING: windeployqt not found. Skipping Qt dependency deployment.
    exit /b 1
)

echo Running windeployqt to bundle Qt dependencies...
"%WINDEPLOYQT_PATH%" --force-openssl "%TARGET_EXE%" --qmldir "%SCRIPT_DIR%src\ui\qml"
if errorlevel 1 (
    echo WARNING: windeployqt reported an error.
    exit /b 1
)

call :copy_openssl_dlls "%TARGET_EXE%"

exit /b 0

:_ensure_qt_root_dir
if defined QT_ROOT_DIR (
    call :_normalize_qt_root "%QT_ROOT_DIR%"
    exit /b 0
)

if defined Qt6_DIR (
    call :_normalize_qt_root "%Qt6_DIR%"
    if defined QT_ROOT_DIR goto :_ensure_qt_root_done
)

if defined CMAKE_PREFIX_PATH (
    for /f "tokens=1 delims=;" %%P in ("%CMAKE_PREFIX_PATH%") do (
        if not defined QT_ROOT_DIR (
            call :_normalize_qt_root "%%~fP"
        )
    )
    if defined QT_ROOT_DIR goto :_ensure_qt_root_done
)

for %%B in ("%ProgramFiles%\Qt" "C:\Qt" "%ProgramFiles(x86)%\Qt" "%USERPROFILE%\Qt" "%USERPROFILE%\AppData\Local\Programs\Qt") do (
    if not defined QT_ROOT_DIR (
        if exist "%%~fB" (
            for /f "delims=" %%V in ('dir /b /ad "%%~fB\6*" 2^>nul ^| sort /r') do (
                for /d %%K in ("%%~fB\%%V\*") do (
                    if not defined QT_ROOT_DIR (
                        call :_normalize_qt_root "%%~fK"
                    )
                )
            )
        )
    )
)

:_ensure_qt_root_done
exit /b 0

:copy_openssl_dlls
set "_target_exe=%~1"
if "%_target_exe%"=="" exit /b 0
set "_target_dir=%~dp1"
if "%_target_dir%"=="" exit /b 0

set "OPENSSL_BIN="

if defined OPENSSL_ROOT_DIR (
    if exist "%OPENSSL_ROOT_DIR%\bin\libssl-3-x64.dll" set "OPENSSL_BIN=%OPENSSL_ROOT_DIR%\bin"
    if not defined OPENSSL_BIN if exist "%OPENSSL_ROOT_DIR%\libssl-3-x64.dll" set "OPENSSL_BIN=%OPENSSL_ROOT_DIR%"
)

if not defined OPENSSL_BIN (
    for %%B in ("%ProgramFiles%\OpenSSL-Win64\bin" "C:\Program Files\OpenSSL-Win64\bin" "C:\OpenSSL-Win64\bin" "%ProgramFiles%\OpenSSL\bin" "%ProgramFiles(x86)%\OpenSSL-Win64\bin") do (
        if not defined OPENSSL_BIN if exist "%%~fB\libssl-3-x64.dll" set "OPENSSL_BIN=%%~fB"
    )
)

if not defined OPENSSL_BIN (
    for /f "delims=" %%I in ('where libssl-3-x64.dll 2^>nul') do (
        if not defined OPENSSL_BIN set "OPENSSL_BIN=%%~dpI"
    )
)

if not defined OPENSSL_BIN (
    echo INFO: OpenSSL binaries not found. Install via "winget install ShiningLight.OpenSSL.Light" to enable HTTPS sync.
    exit /b 0
)

set "_copied=0"
for %%F in (libssl-3-x64.dll libcrypto-3-x64.dll) do (
    if exist "%OPENSSL_BIN%\%%F" (
        copy /Y "%OPENSSL_BIN%\%%F" "%_target_dir%%%F" >nul
        if not errorlevel 1 set "_copied=1"
    )
)

if "%_copied%"=="1" (
    echo Copied OpenSSL runtime DLLs from "%OPENSSL_BIN%".
) else (
    echo WARNING: OpenSSL DLLs not found in "%OPENSSL_BIN%".
)

exit /b 0

:_normalize_qt_root
set "_candidate=%~1"
if "%_candidate%"=="" exit /b 0

for %%R in ("%_candidate%" "%_candidate%\.." "%_candidate%\..\.." "%_candidate%\..\..\..") do (
    if exist "%%~fR\bin\windeployqt.exe" (
        set "QT_ROOT_DIR=%%~fR"
        set "_candidate="
        exit /b 0
    )
    if exist "%%~fR\lib\cmake\Qt6\Qt6Config.cmake" (
        set "QT_ROOT_DIR=%%~fR"
        set "_candidate="
        exit /b 0
    )
)

set "_candidate="
exit /b 0

:configure_qt_env
call :_ensure_qt_root_dir

if defined QT_ROOT_DIR (
    if not defined Qt6_DIR (
        if exist "%QT_ROOT_DIR%\lib\cmake\Qt6\Qt6Config.cmake" set "Qt6_DIR=%QT_ROOT_DIR%\lib\cmake\Qt6"
    )
    if not defined CMAKE_PREFIX_PATH set "CMAKE_PREFIX_PATH=%QT_ROOT_DIR%"
    echo INFO: Using Qt root at "%QT_ROOT_DIR%"
    call :_determine_qt_toolchain "%QT_ROOT_DIR%"
) else (
    set "QT_TOOLCHAIN_TYPE="
)

exit /b 0

:prepare_toolchain
set "CMAKE_GENERATOR_OPTION="
set "CMAKE_COMPILER_OPTIONS="
set "CMAKE_BUILD_CONFIG_SWITCH=--config Release"

if /I "%QT_TOOLCHAIN_TYPE%"=="mingw" (
    call :_ensure_mingw_toolchain
    if defined MINGW_BIN_DIR (
        echo INFO: MinGW toolchain detected at "!MINGW_BIN_DIR!"
        echo !PATH! | find /I "!MINGW_BIN_DIR!" >nul
        if errorlevel 1 set "PATH=!MINGW_BIN_DIR!;!PATH!"
        set "CMAKE_GENERATOR_OPTION=-G ^"MinGW Makefiles^""
        set "CMAKE_COMPILER_OPTIONS=-DCMAKE_C_COMPILER=^"!MINGW_BIN_DIR!\gcc.exe^" -DCMAKE_CXX_COMPILER=^"!MINGW_BIN_DIR!\g++.exe^" -DCMAKE_MAKE_PROGRAM=^"!MINGW_BIN_DIR!\mingw32-make.exe^""
        set "CMAKE_BUILD_CONFIG_SWITCH="
        set "TARGET_GENERATOR=MinGW Makefiles"
    ) else (
        echo WARNING: MinGW toolchain for Qt not found automatically. Install the Qt MinGW tools or update PATH.
        set "CMAKE_GENERATOR_OPTION=-G ^"MinGW Makefiles^""
        set "CMAKE_BUILD_CONFIG_SWITCH="
    )
) else if /I "%QT_TOOLCHAIN_TYPE%"=="msvc" (
    set "CMAKE_GENERATOR_OPTION="
    set "MINGW_BIN_DIR="
) else (
    set "CMAKE_GENERATOR_OPTION="
    set "MINGW_BIN_DIR="
)

exit /b 0

:_determine_qt_toolchain
set "_qt_root=%~1"
if "%_qt_root%"=="" exit /b 0

set "_detected="
echo %_qt_root% | find /I "mingw" >nul
if not errorlevel 1 set "_detected=mingw"

if not defined _detected (
    echo %_qt_root% | find /I "msvc" >nul
    if not errorlevel 1 set "_detected=msvc"
)

if not defined _detected set "_detected=unknown"

set "QT_TOOLCHAIN_TYPE=%_detected%"
set "_detected="
set "_qt_root="
exit /b 0

:_ensure_mingw_toolchain
if not defined QT_ROOT_DIR exit /b 0

if defined MINGW_BIN_DIR (
    if exist "%MINGW_BIN_DIR%\mingw32-make.exe" exit /b 0
    set "MINGW_BIN_DIR="
)

for %%C in ("%QT_ROOT_DIR%" "%QT_ROOT_DIR%\.." "%QT_ROOT_DIR%\..\.." "%QT_ROOT_DIR%\..\..\Tools" "%QT_ROOT_DIR%\..\Tools" "%QT_ROOT_DIR%\Tools") do (
    if not defined MINGW_BIN_DIR (
        if exist "%%~fC" (
            for /f "delims=" %%F in ('dir /b /s "%%~fC\mingw32-make.exe" 2^>nul') do (
                if not defined MINGW_BIN_DIR set "MINGW_BIN_DIR=%%~dpF"
            )
        )
    )
)

if defined MINGW_BIN_DIR (
    if "!MINGW_BIN_DIR:~-1!"=="\" set "MINGW_BIN_DIR=!MINGW_BIN_DIR:~0,-1!"
)

exit /b 0
