# Noah Planner v2.0 (Native Linux – C++/Qt6)

**Native Desktop-App** für Fedora und andere Linux-Distributionen. Keine Browser-/Server-Abhängigkeit. Daten werden lokal als JSON gespeichert.

## Abhängigkeiten (Fedora)
```bash
sudo dnf install -y qt6-qtbase-devel cmake gcc-c++
```

## Build & Start
```bash
./run.sh
```

## Ordner
- `src/` – C++/Qt6 Source
- `data/` – JSON-Daten (werden bei erstem Start auch unter `~/.local/share/NoahPlanner` gespiegelt/erstellt)
- `assets/` – Icons

## Features (v2.0)
- Monatskalender (Qt `QCalendarWidget`) + rechte Seitenleiste mit **Heutige Aufgaben** (Checkboxen).
- **Klassenarbeiten**-Dialog (Fach, Datum, Themen als Kommaliste).
- **Filter**: Suche (Text), Fach-Checkboxen, „Nur offene“.
- **Plan-Generator**: erzeugt Aufgaben-Slots (20–40 min) je Tag, gewichtet nach Fach, Niveau und nahenden Klassenarbeiten.
- **Persistenz**: JSON-Dateien (subjects, diagnostics, config, exams, done).

## Datenpfad
- App-Daten: `~/.local/share/NoahPlanner`
- Start-Seeding erfolgt automatisch, falls Dateien fehlen.

## Tastatur
- `T` – Heute
- `Ctrl+F` – Fokus in Suche
- `N` – Neue Klassenarbeit

## Build-Probleme?
- Prüfe Qt-Version (`qmake -v` oder Paket `qt6-qtbase-devel` installiert?). 
- CMake ≥ 3.16 erforderlich.
