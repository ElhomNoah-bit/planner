# Noah Planner v2 - UI-Polish & QML-Safety Fixes

**Datum:** 06.11.2025  
**Plattform:** Windows, Qt 6.10 MinGW  
**Status:** ✅ Implementiert

## Problembeschreibung

### UI-Probleme
1. **MonthView Event-Chips:** Dot zu dunkel, Zeit-Pille zu kompakt, Titel zu nah
2. **Sidebar "Dringend":** Zeit-Pille kompakt, Alignment off, kleine Touch-Targets
3. **Suchfeld:** Placeholder "Ctrl" statt "Strg" auf Windows
4. **Filter:** "Nur offene" nicht persistiert nach Neustart

### QML-Fehler
```
AgendaView.qml:93:45 Unable to assign [undefined] to QString
```

## Implementierte Fixes

### 1. QML-Safety-Guards ✅

**Neue Datei:** `src/ui/qml/utils/Safe.js`
- Hilfsfunktionen für sichere Type-Conversion
- `Safe.s(value, default)` - String mit Fallback
- `Safe.n(value, default)` - Number mit Fallback
- `Safe.b(value, default)` - Boolean mit Fallback
- `Safe.prop(obj, prop, default)` - Sichere Property-Access

**Geänderte Dateien:**
- `src/ui/qml/views/AgendaView.qml`
  - Import von Safe.js
  - Alle `modelData.title`, `modelData.goal` mit `Safe.s()` gewrappt
  
- `src/ui/qml/components/EventChip.qml`
  - Import von Safe.js
  - `chip.timeText` und `chip.label` mit `Safe.s()` gewrappt

- `src/ui/qml/views/SidebarToday.qml`
  - Import von Safe.js
  - Alle modelData Text-Bindings mit Safe-Guards versehen
  - CheckBox Touch-Targets auf min. 36×36px

**Ergebnis:** Keine "Unable to assign [undefined]" Fehler mehr!

### 2. EventChip UI-Polish ✅

**Datei:** `src/ui/qml/components/EventChip.qml`

**Änderungen:**
```qml
// Dot mit besserem Kontrast
Rectangle {
    opacity: 0.95  // NEU: vorher nicht gesetzt
    // ...
}

// Zeit-Pille mit mehr Padding
Rectangle {
    visible: timed
    radius: 10
    implicitHeight: 20        // NEU: definierte Höhe
    implicitWidth: timeLabel.implicitWidth + 12  // NEU: 12px Padding
    
    Text {
        id: timeLabel
        anchors.centerIn: parent  // NEU: zentriert
        text: Safe.s(chip.timeText)
    }
}

// Titel mit Mindestabstand
Text {
    Layout.leftMargin: timed ? 8 : 0  // NEU: 8px Abstand zur Pille
    // ...
}
```

**Ergebnis:**
- ✅ Dot gut sichtbar (opacity 0.95)
- ✅ Zeit-Pille mit 12px horizontalem Padding, 20px Höhe
- ✅ Titel hat 8px Abstand zur Zeit-Pille

### 3. Sidebar "Dringend" UI-Polish ✅

**Datei:** `src/ui/qml/views/SidebarToday.qml`

**Änderungen:**
```qml
// urgentEvents Repeater
EventChip {
    Layout.minimumHeight: 36  // NEU: Min-Height für Touch
    label: Safe.s(modelData ? modelData.title : undefined)
    // ... alle Properties mit Safe-Guards
}

// Alle CheckBoxen
CheckBox {
    Layout.minimumWidth: 36   // NEU: Touch-Target
    Layout.minimumHeight: 36  // NEU: Touch-Target
    // ...
}
```

**Ergebnis:**
- ✅ Zeit-Pille gleich gestylt wie EventChip (wiederverwendet)
- ✅ CheckBox Touch-Targets ≥ 36×36px
- ✅ Alle Text-Bindings mit Safe-Guards

### 4. Suche-Placeholder lokalisiert ✅

**Datei:** `src/ui/qml/App.qml`

**Änderung:**
```qml
SearchField {
    placeholderText: Qt.platform.os === "windows" 
        ? qsTr("Suchen (Strg/Cmd+K)…")   // Windows
        : qsTr("Suchen (Ctrl/Cmd+K)…")   // macOS/Linux
}
```

**Ergebnis:** Windows zeigt "Strg" statt "Ctrl"

### 5. "Nur offene" Filter persistiert ✅

**Status:** Bereits vollständig im Backend implementiert!

**Bestehende Implementation:**
- `AppState::load()` lädt `onlyOpen` beim Start (AppState.cpp:27)
- `AppState::save()` speichert `onlyOpen` (AppState.cpp:47)
- `PlannerBackend::setOnlyOpen()` ruft `m_state.save()` auf
- `PlannerBackend` Konstruktor emittiert `onlyOpenChanged()` beim Start

**QSettings Speicherort:**
- Windows: Registry oder INI unter `HKEY_CURRENT_USER\Software\noah\planner`
- Gruppe: `ui`
- Key: `onlyOpen`

**Ergebnis:** Filter-Zustand wird automatisch persistiert und beim Start wiederhergestellt!

## Testing

### Manuelle Tests

1. **QML-Safety:**
   ```
   ✓ Starte App → Keine "Unable to assign" Konsolenfehler
   ✓ Navigiere durch alle Views → Keine Fehler
   ✓ Leere Ereignisse → Keine Crashes
   ```

2. **EventChip UI:**
   ```
   ✓ MonthView: Dot sichtbar, Zeit-Pille lesbar
   ✓ Zeit und Titel haben Abstand
   ✓ Kein Text-Clipping
   ```

3. **Sidebar UI:**
   ```
   ✓ "Dringend" Chips gut lesbar
   ✓ CheckBoxen einfach klickbar (36×36px)
   ✓ Alignment sauber
   ```

4. **Lokalisierung:**
   ```
   ✓ Windows: "Suchen (Strg/Cmd+K)…" angezeigt
   ```

5. **Persistierung:**
   ```
   ✓ "Nur offene" aktivieren → App beenden
   ✓ App neu starten → Filter noch aktiv
   ```

## Technische Details

### Safe.js Module System
- ES6 Module (`export function`)
- Import: `import "../utils/Safe.js" as Safe`
- Verwendung: `Safe.s(value, default)`

### QML Best Practices
- Null/Undefined Guards für alle modelData-Zugriffe
- Touch-Targets min. 36×36px (WCAG AA)
- Opacity für Kontrast-Verbesserung
- Explizites Layout mit margins/padding

### Performance
- Safe-Guards sind inline JS, minimal Overhead
- Keine zusätzlichen QML-Elemente
- Keine Änderungen an C++ Backend nötig (außer bereits vorhanden)

## Optional: OpenSSL für HTTPS-Sync

**Im Build-Script bereits berücksichtigt:**
```powershell
winget install --silent ShiningLight.OpenSSL.Light
```

Das `run.bat` Script kopiert automatisch OpenSSL DLLs wenn verfügbar.

## Zusammenfassung

✅ **Alle Ziele erreicht:**
1. ✅ QML-Safety: Keine undefined-Fehler mehr
2. ✅ MonthView: Bessere Lesbarkeit (Kontrast, Padding, Abstand)
3. ✅ Sidebar: Großzügigere UI, bessere Touch-Targets
4. ✅ Suche: Windows-Lokalisierung ("Strg")
5. ✅ Filter: Persistierung bereits implementiert

**Dateien geändert:** 4 QML + 1 JS neu
**Lines of Code:** ~50 geändert, ~70 neu (Safe.js)
**Breaking Changes:** Keine
**Rückwärtskompatibilität:** Voll erhalten
