# Spaced Repetition UI-Anleitung

## Übersicht

Das Noah Planner Spaced Repetition Feature verfügt über eine **vollständig implementierte und integrierte Benutzeroberfläche**. Diese Anleitung zeigt, wie Sie die UI verwenden können.

## Problem-Kontext

**Frage**: "Kann es sein das es für das Spaced Repetition Feature noch kein UI gibt?"

**Antwort**: ✅ **Nein, die UI existiert bereits vollständig!** Dieses Dokument beschreibt, wo Sie sie finden und wie Sie sie verwenden können.

## Zugriff auf die Spaced Repetition UI

### Methode 1: Tastenkombination (Schnellster Weg)
- **Windows/Linux**: `Strg + R`
- **macOS**: `⌘ + R`

Dies öffnet sofort den Review-Dialog.

### Methode 2: Sidebar-Button
Wenn Wiederholungen fällig sind:
1. Schauen Sie in die rechte Sidebar
2. Suchen Sie nach dem Panel "Wiederholungen"
3. Klicken Sie auf "🔄 Reviews öffnen"

Das Panel zeigt auch:
- Anzahl der fälligen Wiederholungen
- ReviewIndicator-Badge mit der Anzahl

### Methode 3: Command Palette
1. Öffnen Sie die Command Palette mit `Strg + K` oder `⌘ + K`
2. Tippen Sie: `review`, `reviews`, `wiederholung`, oder `lernen`
3. Wählen Sie den Befehl "open-reviews"

### Methode 4: ReviewIndicator-Badge
Wenn Wiederholungen fällig sind, erscheint in der Sidebar ein Badge:
- Zeigt die Anzahl der fälligen Wiederholungen
- Klicken Sie darauf, um den Review-Dialog zu öffnen

## UI-Komponenten im Detail

### 1. Review-Dialog (ReviewDialog)

Der Hauptdialog für die Verwaltung von Wiederholungen:

#### Header-Bereich
- **Titel**: "📚 Reviews"
- **Badge**: Zeigt die Anzahl der fälligen Reviews
- **Button "Neues Review"**: Zum Hinzufügen neuer Wiederholungen

#### Filter-Tabs
- **"Alle"**: Zeigt alle Reviews an
- **"Fällig"**: Zeigt nur fällige Reviews an

#### Review-Liste
Jeder Eintrag zeigt:
- **Topic-Name**: Das zu wiederholende Thema
- **Status-Anzeige**:
  - 🔴 "Fällig" (rot) - Review ist heute fällig
  - ⏳ "YYYY-MM-DD" (grau) - Nächstes Review-Datum
- **"Review"-Button**: Erscheint nur bei fälligen Items
- **"×"-Button**: Zum Löschen des Reviews
- **Statistiken**:
  - Fach-ID (z.B. "ma", "en")
  - Anzahl der Wiederholungen
  - Aktuelles Intervall in Tagen
  - Ease Factor (SM-2 Schwierigkeitsfaktor)

### 2. Neues Review hinzufügen

1. Klicken Sie auf "Neues Review" im Dialog-Header
2. Ein Popup erscheint mit:
   - **Fach-ID Feld**: z.B. "ma", "en", "de"
   - **Thema Feld**: z.B. "Quadratische Gleichungen"
3. Füllen Sie beide Felder aus
4. Klicken Sie "Hinzufügen"

Das neue Review wird mit den Standard-SM-2-Einstellungen erstellt.

### 3. Review durchführen

1. Klicken Sie auf den "Review"-Button bei einem fälligen Item
2. Ein Popup erscheint mit dem Thema und der Frage:
   **"Wie gut konntest du dich erinnern?"**
3. Wählen Sie eine der 6 Qualitätsstufen:

   - ✅ **5 - Perfekte Antwort** (grün)
     - Sie wussten es sofort
   
   - ✅ **4 - Richtig nach kurzem Überlegen** (grün)
     - Kleine Verzögerung, aber richtig
   
   - ⚠️ **3 - Richtig mit Schwierigkeit** (gelb)
     - Sie haben gekämpft, aber es geschafft
   
   - ⚠️ **2 - Falsch, aber leicht zu erinnern** (gelb)
     - Falsch, aber die Antwort schien leicht
   
   - ❌ **1 - Falsch, aber erinnert** (rot)
     - Falsch, aber Sie haben sich an etwas erinnert
   
   - ❌ **0 - Keine Erinnerung** (rot)
     - Völlige Erinnerungslücke

4. Das System berechnet automatisch:
   - Nächstes Review-Datum (basierend auf SM-2-Algorithmus)
   - Aktualisierter Ease Factor
   - Neues Intervall

### 4. ReviewIndicator (Sidebar-Badge)

Der Badge erscheint nur, wenn Reviews fällig sind und zeigt:
- 🔄 Icon
- Anzahl der fälligen Reviews
- Text "Wiederholung" oder "Wiederholungen"
- Tooltip beim Überfahren mit Details

## SM-2-Algorithmus Verhalten

Das System verwendet den SuperMemo 2 (SM-2) Algorithmus:

### Bewertung 0-2 (Fehlgeschlagen)
- Repetition-Zähler wird auf 0 zurückgesetzt
- Intervall wird auf den Anfangswert zurückgesetzt (Standard: 1 Tag)
- Sie müssen von vorne beginnen

### Bewertung 3-5 (Bestanden)
- Repetition-Zähler wird erhöht
- Ease Factor wird angepasst (höher bei besserer Bewertung)
- Intervall wird verlängert:
  - 1. Wiederholung: 1 Tag (konfigurierbar)
  - 2. Wiederholung: 6 Tage
  - Weitere: vorheriges Intervall × Ease Factor

### Ease Factor Berechnung
```
Neuer EF = Alter EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02))
Minimum EF = 1.3
Standard EF = 2.5
```

## Einstellungen

Im Einstellungsdialog (⚙ in der Top-Bar):
- **"Review Intervall (Tage)"**: Konfiguriert das initiale Intervall (1-7 Tage)
- Standard: 1 Tag

## Datenspeicherung

### Speicherort
- **Linux**: `~/.local/share/NoahPlanner/reviews.json`
- **Windows**: `C:\Users\<Benutzername>\AppData\Local\NoahPlanner\reviews.json`

### Seed-Daten
Beim ersten Start werden Beispiel-Reviews aus `data/reviews.json` geladen:
- Mathematik: "Quadratische Gleichungen"
- Englisch: "Present Perfect"

## Tastenkombinationen Übersicht

| Aktion | Windows/Linux | macOS |
|--------|---------------|-------|
| Review-Dialog öffnen | `Strg + R` | `⌘ + R` |
| Command Palette | `Strg + K` | `⌘ + K` |
| Neuer Eintrag | `Strg + N` | `⌘ + N` |
| Suchen | `Strg + F` | `⌘ + F` |

## Fehlerbehebung

### "Ich sehe keine Reviews"
1. Überprüfen Sie, ob Reviews fällig sind:
   - Das ReviewIndicator-Panel erscheint nur bei fälligen Reviews
   - Verwenden Sie `Strg + R` um den Dialog zu öffnen
   - Wählen Sie den Tab "Alle" um alle Reviews zu sehen
2. Fügen Sie neue Reviews hinzu mit "Neues Review"

### "Meine Reviews verschwinden"
- Reviews werden nicht gelöscht, nur das nächste Review-Datum wird aktualisiert
- Verwenden Sie den Tab "Alle" um alle Reviews zu sehen (nicht nur fällige)

### "Intervalle sind zu kurz/lang"
- Passen Sie Ihre Qualitätsbewertungen an:
  - Höhere Bewertungen → längere Intervalle
  - Niedrigere Bewertungen → kürzere Intervalle
- Ändern Sie das initiale Intervall in den Einstellungen

## Technische Details

### Backend-API (für Entwickler)

```javascript
// QML/JavaScript Beispiele

// Review hinzufügen
backend.addReview("ma", "Trigonometrie")

// Review durchführen
backend.recordReview("ma_Quadratische_Gleichungen", 5)

// Review löschen
backend.removeReview("ma_Quadratische_Gleichungen")

// Queries
var allReviews = backend.getAllReviews()
var mathReviews = backend.getReviewsForSubject("ma")
var todayReviews = backend.getReviewsOnDate(Qt.formatDate(new Date(), "yyyy-MM-dd"))

// Properties
var count = backend.dueReviewCount
var dueList = backend.dueReviews
```

## Zusammenfassung

✅ **Die Spaced Repetition UI ist vollständig implementiert und integriert**
✅ **Mehrere Zugriffsmethoden stehen zur Verfügung**
✅ **Vollständige SM-2-Algorithmus-Unterstützung**
✅ **Intuitive Benutzeroberfläche mit Qualitätsbewertungen**
✅ **Persistente Datenspeicherung**

Verwenden Sie `Strg + R` oder `⌘ + R` um sofort loszulegen!
