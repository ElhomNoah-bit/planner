# Noah Planner - Windows 10/11 Setup Guide

Dieser Leitfaden erklärt die Installation und Nutzung von Noah Planner unter Windows 10 und Windows 11.

## Systemvoraussetzungen

- **Betriebssystem**: Windows 10 (64-bit) oder Windows 11
- **RAM**: Mindestens 4 GB (8 GB empfohlen)
- **Festplattenspeicher**: 200 MB für die Anwendung + Qt6-Bibliotheken

## Voraussetzungen installieren

### 1. Qt6 installieren

1. Besuche [https://www.qt.io/download](https://www.qt.io/download)
2. Wähle "Go open source" oder "Qt Online Installer"
3. Lade den Qt Online Installer herunter und führe ihn aus
4. Während der Installation:
   - Wähle Qt 6.5.0 oder höher (mindestens 6.4 erforderlich)
   - Wähle einen Compiler:
     - **MSVC 2019** (empfohlen, wenn Visual Studio installiert ist)
     - **MinGW** (Alternative, enthält eigenen Compiler)
   - Installiere die folgenden Komponenten:
     - Qt Quick
     - Qt Quick Controls
     - Qt SQL
     - Qt Print Support

**Standardinstallationspfad**: `C:\Qt\6.5.0\msvc2019_64` oder `C:\Qt\6.5.0\mingw_64`

### 2. CMake installieren

1. Besuche [https://cmake.org/download/](https://cmake.org/download/)
2. Lade "Windows x64 Installer" herunter
3. Führe den Installer aus
4. **Wichtig**: Wähle während der Installation "Add CMake to system PATH for all users"

**Mindestversion**: CMake 3.16 oder höher

### 3. Compiler installieren

**Option A: Visual Studio Build Tools (empfohlen)**
1. Besuche [https://visualstudio.microsoft.com/downloads/](https://visualstudio.microsoft.com/downloads/)
2. Scrolle zu "Tools for Visual Studio" und lade "Build Tools für Visual Studio 2019" oder neuer herunter
3. Während der Installation wähle:
   - "Desktop-Entwicklung mit C++"
   - Stelle sicher, dass MSVC v142 oder neuer ausgewählt ist

**Option B: MinGW (wenn über Qt installiert)**
- MinGW ist bereits enthalten, wenn du Qt mit MinGW-Compiler installiert hast
- Kein zusätzlicher Schritt erforderlich

### 4. Git (optional, für Entwicklung)

1. Besuche [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. Lade den Windows-Installer herunter
3. Führe den Installer aus mit Standardeinstellungen

## Projekt bauen und ausführen

### Schnellstart mit run.bat

1. **Qt6-Pfad setzen** (öffne Eingabeaufforderung oder PowerShell):
   ```cmd
   set CMAKE_PREFIX_PATH=C:\Qt\6.5.0\msvc2019_64
   ```
   *Hinweis*: Passe den Pfad an deine Qt-Installation an!

2. **Navigiere zum Projektverzeichnis**:
   ```cmd
   cd C:\Pfad\zu\planner
   ```

3. **Führe das Build-Skript aus**:
   ```cmd
   run.bat
   ```

Das Skript wird:
- CMake konfigurieren
- Das Projekt im Release-Modus bauen
- Noah Planner automatisch starten

### Manuelle Build-Schritte

Wenn du mehr Kontrolle über den Build-Prozess haben möchtest:

1. **Qt6-Pfad setzen**:
   ```cmd
   set CMAKE_PREFIX_PATH=C:\Qt\6.5.0\msvc2019_64
   ```

2. **CMake konfigurieren**:
   ```cmd
   cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
   ```

3. **Projekt bauen**:
   ```cmd
   cmake --build build --config Release --parallel
   ```

4. **Anwendung starten**:
   ```cmd
   .\build\Release\noah_planner.exe
   ```

### Build mit Visual Studio Developer Command Prompt

Für erfahrene Nutzer mit Visual Studio:

1. Öffne "x64 Native Tools Command Prompt for VS 2019" (oder neuer)
2. Qt-Pfad setzen: `set CMAKE_PREFIX_PATH=C:\Qt\6.5.0\msvc2019_64`
3. Zum Projektverzeichnis navigieren
4. CMake-Befehle ausführen (siehe oben)

## Datenspeicherung unter Windows

Noah Planner speichert alle Daten lokal auf deinem Computer:

- **Konfigurationsdateien**: 
  - Registry: `HKEY_CURRENT_USER\Software\noah\planner`
  - Oder INI-Datei: `%APPDATA%\noah\planner.ini`

- **Arbeitsdaten** (JSON-Dateien):
  - `C:\Users\<Benutzername>\AppData\Local\NoahPlanner\`
  - Enthält: `events.json`, `categories.json`, `subjects.json`, `exams.json`, etc.

Du kannst diese Dateien sichern, um deine Daten zu exportieren oder auf einem anderen Computer wiederherzustellen.

## Häufige Probleme und Lösungen

### Problem: "CMake not found"

**Lösung**: 
- Überprüfe die Installation von CMake
- Stelle sicher, dass CMake zum PATH hinzugefügt wurde
- Schließe und öffne die Eingabeaufforderung erneut

### Problem: "Qt6 not found"

**Lösung**:
- Setze `CMAKE_PREFIX_PATH` auf dein Qt6-Installationsverzeichnis
- Beispiel für MSVC: `set CMAKE_PREFIX_PATH=C:\Qt\6.5.0\msvc2019_64`
- Beispiel für MinGW: `set CMAKE_PREFIX_PATH=C:\Qt\6.5.0\mingw_64`

### Problem: "Build failed" - Compiler-Fehler

**Lösung**:
- Stelle sicher, dass Visual Studio Build Tools oder MinGW installiert sind
- Für MSVC: Nutze "x64 Native Tools Command Prompt"
- Für MinGW: Nutze die Qt-Eingabeaufforderung aus dem Startmenü

### Problem: "noah_planner.exe not found"

**Lösung**:
- Überprüfe den Build-Status auf Fehler
- Die EXE könnte in verschiedenen Verzeichnissen liegen:
  - `build\Release\noah_planner.exe` (MSVC)
  - `build\Debug\noah_planner.exe` (Debug-Build)
  - `build\noah_planner.exe` (MinGW)

### Problem: Anwendung startet, zeigt aber weißen Bildschirm

**Lösung**:
- Stelle sicher, dass alle Qt6-DLLs im Suchpfad sind
- Kopiere die Qt-DLLs ins Build-Verzeichnis, oder
- Füge das Qt `bin`-Verzeichnis zum PATH hinzu:
  ```cmd
  set PATH=%PATH%;C:\Qt\6.5.0\msvc2019_64\bin
  ```

## Anwendung als standalone .exe verteilen (optional)

Um Noah Planner ohne Qt-Installation auszuführen:

1. **Führe windeployqt aus**:
   ```cmd
   cd build\Release
   C:\Qt\6.5.0\msvc2019_64\bin\windeployqt.exe noah_planner.exe
   ```

2. Dies kopiert alle benötigten Qt-DLLs und Plugins in das Release-Verzeichnis

3. Du kannst nun den gesamten `Release`-Ordner auf andere Computer kopieren

## Qt-Umgebungsvariable dauerhaft setzen (optional)

Um `CMAKE_PREFIX_PATH` nicht jedes Mal setzen zu müssen:

### Über die Systemsteuerung:
1. Rechtsklick auf "Dieser PC" → "Eigenschaften"
2. "Erweiterte Systemeinstellungen"
3. "Umgebungsvariablen"
4. Unter "Benutzervariablen" → "Neu"
5. Name: `CMAKE_PREFIX_PATH`
6. Wert: `C:\Qt\6.5.0\msvc2019_64` (dein Qt-Pfad)
7. Alle Fenster mit "OK" schließen
8. Neue Eingabeaufforderung öffnen

### Über PowerShell (dauerhaft):
```powershell
[System.Environment]::SetEnvironmentVariable('CMAKE_PREFIX_PATH', 'C:\Qt\6.5.0\msvc2019_64', 'User')
```

## Entwicklung unter Windows

### Empfohlene IDEs:
- **Qt Creator** (empfohlen, Teil der Qt-Installation)
- **Visual Studio 2019/2022** mit Qt VS Tools
- **Visual Studio Code** mit C++ und CMake Extensions

### Debugging:
```cmd
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build --config Debug
```

## Unterstützung

Bei Problemen:
1. Überprüfe die Konsolenausgabe auf Fehlermeldungen
2. Konsultiere die [README.md](README.md) für allgemeine Informationen
3. Erstelle ein Issue auf GitHub mit:
   - Windows-Version
   - Qt-Version
   - Compiler-Version
   - Vollständige Fehlermeldung

---

**Hinweis**: Diese Anleitung wurde für Windows 10/11 mit Qt 6.5.0 und Visual Studio 2019 erstellt. Andere Versionen sollten ähnlich funktionieren, können aber Anpassungen erfordern.
