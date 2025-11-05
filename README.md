# Noah Planner v2.0 (Cross-Platform – C++/Qt6)

Noah Planner ist eine native Qt-Quick-Anwendung für Linux und Windows. Sie bietet einen fokussierten Lernkalender, generiert Tagespläne auf Basis von Fächern, Leistungsständen und Prüfungsterminen und speichert alle Daten vollständig lokal im JSON-Format.

**Unterstützte Plattformen:** Linux (Fedora, Ubuntu, Debian) | Windows 10/11

## Überblick
- Plattformübergreifende native Desktop-App ohne Browser- oder Server-Abhängigkeiten
- Monats-, Wochen- und Listenansichten inklusive Sidebar für heutige Aufgaben, Timer und Prüfungsübersicht
- Automatischer Slot-Planer (20–40 Minuten) mit Gewichtung nach Fach, Niveau und Prüfungsnähe
- Persistente Filter (Suche, Fächer, offene Aufgaben) und Dunkelmodus über `QSettings`
- Datenhaltung in `~/.local/share/NoahPlanner` mit automatischer Initialbefüllung bei fehlenden Dateien
- Qt 6.5 Stack mit C++17 Backend (`PlannerService`, Modelle, `PlannerBackend`) und QML-Frontend

## Schnelleinstieg

### Linux
1. Systemabhängigkeiten installieren:
	- **Fedora**: `sudo dnf install -y qt6-qtbase-devel qt6-qtdeclarative-devel cmake gcc-c++`
	- **Debian/Ubuntu**: `sudo apt install qt6-base-dev qt6-declarative-dev cmake g++` (Qt ≥ 6.4 erforderlich)
2. Projekt klonen bzw. in dieses Verzeichnis wechseln.
3. Build & Start via Helferskript:
	```bash
	./run.sh
	```
	Das Skript erzeugt `build/`, kompiliert im Release-Modus und startet `noah_planner`.

### Windows 10/11
1. Voraussetzungen installieren:
	- **Qt6** (≥ 6.4): [Download von qt.io](https://www.qt.io/download)
	- **CMake** (≥ 3.16): [Download von cmake.org](https://cmake.org/download/)
	- **Visual Studio Build Tools** oder **MinGW** mit C++17-Unterstützung
2. Qt6-Pfad setzen (cmd oder PowerShell):
	```cmd
	set CMAKE_PREFIX_PATH=C:\Qt\6.5.0\msvc2019_64
	```
	(Pfad entsprechend deiner Qt-Installation anpassen)
3. Build & Start via Batch-Skript:
	```cmd
	run.bat
	```
	Das Skript erzeugt `build/`, kompiliert im Release-Modus und startet `noah_planner.exe`.

## Manuelles Bauen (optional)

### Linux
```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
./build/noah_planner
```

### Windows
```cmd
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release --parallel
.\build\Release\noah_planner.exe
```

**Hinweis**: Setze `CMAKE_PREFIX_PATH`, falls Qt6 nicht in den Standardpfaden liegt. CMake ≥ 3.16 sowie eine funktionierende Qt6-Installation werden vorausgesetzt.

## Daten & Persistenz
- Arbeitsdaten landen automatisch im plattformspezifischen Verzeichnis:
	- **Linux**: `~/.local/share/NoahPlanner`
	- **Windows**: `C:\Users\<Benutzername>\AppData\Local\NoahPlanner`
- Beim ersten Start werden `subjects.json`, `diagnostics.json`, `config.json`, `exams.json` und `done.json` aus `data/` kopiert oder mit Default-Werten erzeugt.
- Anpassungen der JSON-Dateien können direkt im Nutzerverzeichnis erfolgen; beim nächsten Start werden sie geladen.

## Projektstruktur (Auszug)
- `src/core/` – Domänenlogik (`PlannerService`, Modelle für Fächer, Aufgaben, Prüfungen)
- `src/models/` – `QAbstractListModel` + Filter-Proxies für Aufgaben und Prüfungen
- `src/ui/` – C++-Backend (`PlannerBackend`, `AppState`) sowie QML-Assets unter `src/ui/qml/`
- `data/` – Beispiel- und Seed-Dateien für lokale Persistenz
- `assets/` – Schriftarten und weitere Ressourcen
- `run.sh` – Build & Start-Skript für Linux
- `run.bat` – Build & Start-Skript für Windows

## Weiterführende Dokumentation
- **Entwickler-Dokumentation**: Siehe [README_DEV.md](README_DEV.md) für technische Details
- **Windows-Setup**: Detaillierte Anleitung in [WINDOWS_SETUP.md](WINDOWS_SETUP.md)
- **Plattformkompatibilität**: Informationen zu unterstützten Systemen in [PLATFORM_COMPATIBILITY.md](PLATFORM_COMPATIBILITY.md)
- **Erweiterte Dokumentation**: Ausführliche Informationen zu Architektur, Konfiguration und Bedienung in `docs/README.md`
