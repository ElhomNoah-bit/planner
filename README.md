# Noah Planner v2.0 (Native Linux – C++/Qt6)

Noah Planner ist eine native Qt-Quick-Anwendung für Fedora und andere Linux-Distributionen. Sie bietet einen fokussierten Lernkalender, generiert Tagespläne auf Basis von Fächern, Leistungsständen und Prüfungsterminen und speichert alle Daten vollständig lokal im JSON-Format.

## Überblick
- Native Desktop-App ohne Browser- oder Server-Abhängigkeiten
- Monats-, Wochen- und Listenansichten inklusive Sidebar für heutige Aufgaben, Timer und Prüfungsübersicht
- Automatischer Slot-Planer (20–40 Minuten) mit Gewichtung nach Fach, Niveau und Prüfungsnähe
- Persistente Filter (Suche, Fächer, offene Aufgaben) und Dunkelmodus über `QSettings`
- Datenhaltung in `~/.local/share/NoahPlanner` mit automatischer Initialbefüllung bei fehlenden Dateien
- Qt 6.5 Stack mit C++17 Backend (`PlannerService`, Modelle, `PlannerBackend`) und QML-Frontend

## Schnelleinstieg
1. Systemabhängigkeiten installieren (Fedora):
	```bash
	sudo dnf install -y qt6-qtbase-devel qt6-qtdeclarative-devel cmake gcc-c++
	```
	Für Debian/Ubuntu: `sudo apt install qt6-base-dev qt6-declarative-dev cmake g++` (Qt ≥ 6.5 erforderlich).
2. Projekt klonen bzw. in dieses Verzeichnis wechseln.
3. Build & Start via Helferskript:
	```bash
	./run.sh
	```
	Das Skript erzeugt `build/`, kompiliert im Release-Modus und startet `noah_planner`.

## Manuelles Bauen (optional)
```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
./build/noah_planner
```
Setze `CMAKE_PREFIX_PATH`, falls Qt6 nicht in den Standardpfaden liegt. CMake ≥ 3.16 sowie eine funktionierende Qt-Installation werden vorausgesetzt.

## Daten & Persistenz
- Arbeitsdaten landen automatisch unter `~/.local/share/NoahPlanner`.
- Beim ersten Start werden `subjects.json`, `diagnostics.json`, `config.json`, `exams.json` und `done.json` aus `data/` kopiert oder mit Default-Werten erzeugt.
- Anpassungen der JSON-Dateien können direkt im Nutzerverzeichnis erfolgen; beim nächsten Start werden sie geladen.

## Projektstruktur (Auszug)
- `src/core/` – Domänenlogik (`PlannerService`, Modelle für Fächer, Aufgaben, Prüfungen)
- `src/models/` – `QAbstractListModel` + Filter-Proxies für Aufgaben und Prüfungen
- `src/ui/` – C++-Backend (`PlannerBackend`, `AppState`) sowie QML-Assets unter `src/ui/qml/`
- `data/` – Beispiel- und Seed-Dateien für lokale Persistenz
- `assets/` – Schriftarten und weitere Ressourcen
- `run.sh` – Komfortskript für Build & Start

## Weiterführende Dokumentation
Ausführliche Informationen zu Architektur, Konfiguration, Bedienung und Erweiterung findest du in `docs/README.md`.
