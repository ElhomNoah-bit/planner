# Noah Planner - Ausfuehrliche Dokumentation

## 1. Zweck & Funktionsumfang
Noah Planner ist eine desktop-native Lern- und Studienplaner-Anwendung. Sie kombiniert eine Kalenderoberflaeche mit einer automatischen Slot-Generator-Logik, um taegliche Lerneinheiten zu planen. Das Ziel ist, Lernzeitrahmen von 20-40 Minuten auf Basis von Fachprioritaeten, Leistungsdiagnostik und nahenden Klassenarbeiten zu verteilen. Alle Daten werden lokal gespeichert; es existiert keine Cloud-Komponente.

## 2. Systemarchitektur im Ueberblick
- **Core-Schicht (`src/core`)**: enthaelt Domaenenklassen (`Subject`, `Task`, `Exam`) sowie den `PlannerService`, der Daten laedt, speichert und Tagesplaene berechnet.
- **Model-Schicht (`src/models`)**: stellt `QAbstractListModel`-Implementierungen (`TaskModel`, `ExamModel`) und den `TaskFilterProxy` bereit, damit C++-Daten effizient an QML gebunden werden koennen.
- **UI-Schicht (`src/ui`)**: `PlannerBackend` vereint Core-Logik mit UI-Status (`AppState`) und exportiert Properties/Methoden nach QML. `AppState` persistiert Benutzerpraeferenzen ueber `QSettings`.
- **QML-Frontend (`src/ui/qml`)**: Qt Quick Controls 2 plus massgeschneiderte Komponenten fuer Kalenderansichten, Sidebar, Filter, Quick-Add-Dialog und Toasts. Styles liegen als Singleton (`ThemeStore.qml`) vor.
- **Assets & Ressourcen**: Schriftarten werden ueber Qt-Ressourcen eingebunden (`CMakeLists.txt` -> `qt_add_resources`).

Die Anwendung folgt einem klassischen Qt-MVVM-Muster: Der PlannerService stellt Daten bereit, `PlannerBackend` agiert als ViewModel, QML-Komponenten bilden die Views.

## 3. Build- & Laufzeitumgebung
- **Abhaengigkeiten**:
  - Qt 6.5 (Module: Quick, Qml, QuickControls2, QuickLayouts, Widgets)
  - CMake >= 3.16
  - C++17-faehiger Compiler (z. B. GCC 11+)
- **Empfohlene Pakete**:
  - Fedora: `sudo dnf install qt6-qtbase-devel qt6-qtdeclarative-devel qt6-qtquickcontrols2-devel cmake gcc-c++`
  - Debian/Ubuntu: `sudo apt install qt6-base-dev qt6-declarative-dev qt6-tools-dev cmake g++`
  - Arch Linux: `sudo pacman -S qt6-base qt6-declarative qt6-tools cmake gcc`
- **Build-Workflow**:
  1. `./run.sh` (empfohlene Variante, erzeugt Release-Build und startet die App)
  2. manuell: `cmake -S . -B build -DCMAKE_BUILD_TYPE=Release`
  3. `cmake --build build --parallel`
  4. `./build/noah_planner`
- **Hinweise**: Setze `CMAKE_PREFIX_PATH`, falls Qt in einem benutzerdefinierten Verzeichnis installiert wurde. Starte die App bei Plugin-Problemen einmal mit `QT_DEBUG_PLUGINS=1 ./build/noah_planner`, um Ladefehler sichtbar zu machen.

## 4. Verzeichnis- und Moduluebersicht
| Pfad | Beschreibung |
| --- | --- |
| `src/main.cpp` | Einstiegspunkt, registriert `PlannerBackend`, initialisiert Qt Quick Engine.
| `src/core/` | Geschaeftslogik + JSON-Persistenz (`PlannerService`).
| `src/models/` | Qt-Modelle und Filter (Aufgaben, Pruefungen).
| `src/ui/PlannerBackend.*` | Bridge zwischen C++ und QML (Properties, Slots, Filtersteuerung).
| `src/ui/AppState.*` | Verwaltung persistenter UI-Einstellungen per `QSettings("noah", "planner")`.
| `src/ui/qml/` | QML-Szenen (App-Shell, Kalenderansichten, Sidebar, Komponenten).
| `data/` | Seed-Dateien fuer den initialen Datenbestand.
| `assets/fonts/` | Inter-Regular/Bold, via Qt-Resource-System eingebunden.
| `build/` | Standard-Build-Verzeichnis (nicht versioniert, aber lokal vorhanden).

## 5. Datenhaltung & Konfiguration
- **Speicherort**: Standardmaessig `~/.local/share/NoahPlanner`. `PlannerService::ensureSeed()` kopiert fehlende Dateien aus `data/`.
- **Dateien**:
  | Datei | Inhalt | Hinweise |
  | --- | --- | --- |
  | `subjects.json` | Liste der Faecher mit `id`, `name`, `weight`, `color`. | `weight` beeinflusst Grundpriorisierung, `color` in Hex (`#RRGGBB`). |
  | `diagnostics.json` | Leistungsstand je Fach (`levels`). | Level wird mit `level_factor` kombiniert (`A`, `B`, `C`, etc.). |
  | `config.json` | Globale Planungsparameter. | Enthaelt Zeitraum (`start`, `end`), taegliche Kapazitaet in Minuten pro Wochentag (`daily_capacity_min`), Slotgroessen (`slot_min`, `slot_max`, `max_slots`), Level-Faktoren und Pruefungs-Boosts. |
  | `exams.json` | Liste anstehenden Klassenarbeiten. | `PlannerBackend::exams()` sortiert nach Datum; `weight_boost` multipliziert die Fachgewichtung in der Planerlogik. |
  | `done.json` | Dokumentiert abgehakte Slots pro Tag. | Struktur: `{"done": {"YYYY-MM-DD": [slotIndex,...]}}`. |

Aenderungen an diesen Dateien werden beim naechsten Start uebernommen. Die Anwendung erstellt fehlende Dateien automatisch, falls sie geloescht oder beschaedigt werden.

## 6. Bedienoberflaeche
- **Kalenderansichten**:
  - `MonthView`: Raster-Uebersicht mit Tages-Chips; `goToday()` springt auf den aktuellen Tag.
  - `WeekView`: Horizontale Wochenplanung mit Zeitachse (Start bei 08:00 Uhr, Slot-Versatz um +10 Minuten Puffer).
  - `AgendaView`: Gruppiert Aufgaben in Buckets (Heute, Morgen, Diese Woche, Spaeter).
- **Sidebar Today (`SidebarToday.qml`)**:
  - Tageszusammenfassung (erledigt/offen), Liste der aktuellen Slots, Pruefungsliste.
  - Aktionen: Aufgaben abhaken (`PlannerBackend.toggleTaskDone`), Timer starten (`TimerOverlay`).
- **Filter & Suche**:
  - Volltextfilter fuer Titel/Ziel (`searchQuery`).
  - Fach-Filter (Mehrfachwahl). Persistenz via `AppState`.
  - "Nur offene" blendet erledigte Slots aus.
- **Quick Add Dialog**:
  - Erreichbar ueber Schnellaktionen (z. B. `QuickAddPill`). Aktuell Platzhalter: Eingaben fuehren zu Toast "Hinzugefuegt"; Persistenz ist noch nicht implementiert.
- **Einstellungen (`SettingsDialog.qml`)**:
  - Erreichbar ueber den "Einstellungen"-Button in der Top-Bar (mit Zahnrad-Symbol) oder ueber die Command Palette (Ctrl+K, dann "einstellungen" eingeben).
  - Schaltet Dark/Light, Sprache (`de`/`en`), Wochenstart (Mo/So) und Kalenderwoche-Anzeige.
- **Tastenkuerzel**:
  - `T`: Heute springen (`PlannerBackend.refreshToday()`).
  - `Ctrl+F`: Fokus in das Suchfeld.
  - `N`: Neue Klassenarbeit anlegen (oeffnet Dialog in QML).

## 7. Planungsalgorithmus (`PlannerService`)
1. **Kapazitaet**: Pro Wochentag wird `daily_capacity_min[0..6]` eingelesen (0 = Montag). Bei Kapazitaet <= 0 entsteht kein Plan.
2. **Pausen/Bereiche**: `breaks` enthaelt optionale Zeitfenster (`YYYY-MM-DD..YYYY-MM-DD`). Liegt das Datum in einem Break, wird kein Plan erzeugt.
3. **Basisgewicht**: Kombination aus Fachgewicht (`Subject.weight`) und Level-Faktor (`config.level_factor[level]`). Fehlende Werte fallen auf 1.0 zurueck.
4. **Pruefungsboost**: Fuer jede Klassenarbeit wird der Tagesabstand geprueft. Stimmen `diff` und `exam_boost_days[i]` ueberein, wird das Gewicht mit `exam_boost_factors[i]` multipliziert.
5. **Sortierung**: Faecher werden nach resultierendem Gewicht absteigend sortiert. Faecher mit Gewicht < 0.5 entfallen.
6. **Slot-Verteilung**: Maximal `max_slots` pro Tag, Dauer zwischen `slot_min` und `slot_max`. Der Algorithmus versucht eine gleichmaessige Verteilung ueber die verbliebene Kapazitaet.
7. **Aufgaben-Details**: Titel = Fachname, `goal` aus vordefinierten Textbausteinen (abhaengig von Fach + Datumssamen), Farbe = Fachfarbe. Slot-Index dient als Stabilitaetsanker fuer Done-Status.
8. **Persistenz**: `setDone()` schreibt Zustaende nach `done.json`; `addOrUpdateExam()` und `removeExam()` pflegen `exams.json`.

## 8. Einstellungen & Speicherorte
- `AppState` nutzt `QSettings("noah", "planner")`. Unter Linux landet dies ueblicherweise in `~/.config/noah/planner.conf`.
- Gespeicherte Werte: Dark-Theme, Filterstatus, Suche, Sprache, Wochenstart, Kalenderwoche-Anzeige.
- Die Einstellungen werden beim Beenden automatisch synchronisiert und beim Start geladen.

## 9. Erweiterung & Entwicklung
- **Neue Faecher hinzufuegen**: `subjects.json` ergaenzen (inklusive eindeutiger ID, Gewicht, Farbe). Optional `diagnostics.json` um Level ergaenzen.
- **Weitere Goals**: In `PlannerService::defaultGoal()` die jeweiligen QString-Listen erweitern. Seed basiert auf Julianischem Datum.
- **Neue Views/Komponenten**: QML-Datei unter `src/ui/qml` anlegen und in `CMakeLists.txt` (`qt_add_qml_module`) registrieren.
- **Backend-Funktionen**: In `PlannerBackend` Property/Method definieren, Signal hinzufuegen, QML binden. Nicht vergessen, bei Bedarf Modelle zu invalidieren (`emit tasksChanged()` etc.).
- **Tests**: Aktuell keine automatisierten Tests vorhanden. Empfohlen wird, neue Planner-Logik modular zu halten und ueber Qt-Test (`QTest`) oder gtest/QtQuickTest nachzuruesten.

## 10. Fehlersuche & bekannte Stolpersteine
- **Qt-Plugin-Fehler**: Pruefe `QT_QPA_PLATFORM` und stelle sicher, dass `qt6-qtwayland` oder `qt6-qtbase-gui` installiert ist.
- **Leere Ansicht nach Start**: Kontrolliere, ob `~/.local/share/NoahPlanner` beschreibbar ist und `config.json` gueltiges JSON enthaelt.
- **Aenderungen an JSON greifen nicht**: Anwendung neu starten; PlannerService laedt Dateien nur beim Start.
- **Build schlaegt fehl**: Cache loeschen (`rm -rf build`) und erneut konfigurieren. Pruefe, ob `Qt6_DIR` korrekt gesetzt ist.

## 11. Qualitaetssicherung & Ausblick
- Ein erster automatisierter Test (`priority_rules_test`) prueft die Prioritaetslogik und laesst sich ueber `ctest` ausfuehren.
- Potenzielle Erweiterungen: echte Persistenz fuer Quick-Add, Export/Import, multi-user Profile, weitere Unit-Tests sowie UI-Tests mit Squish oder Qt Quick Ultralite.

## 12. Support & Kontakt
- Allgemeine Fehlermeldungen bitte mit Konsolenausgabe (`QT_LOGGING_RULES="*.debug=true"`) melden.
- Fuer Beitragsschlaege: Pull Requests mit kurzer Beschreibung und reproduzierbaren Schritten einreichen.
