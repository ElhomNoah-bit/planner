# PDF Export - Test Plan

## Test Environment

- **OS**: Linux (Fedora/Ubuntu/Arch)
- **Qt Version**: 6.5+
- **Build Type**: Release
- **Test Data**: Sample events with categories

## Prerequisites

1. Build the application with Qt6 PrintSupport
2. Ensure sample data exists (events and categories)
3. Have a PDF viewer installed (e.g., Evince, Okular, Adobe Reader)

## Test Cases

### TC-1: Week Export - Basic Functionality

**Steps**:
1. Launch Noah Planner
2. Navigate to a week with events
3. Press `Ctrl+K` to open Command Palette
4. Type "export"
5. Select "Woche als PDF exportieren"
6. In ExportDialog, leave filename empty (test auto-generation)
7. Click "Exportieren"

**Expected**:
- ✅ Dialog opens with correct date range
- ✅ Auto-generated filename appears (e.g., `wochenplan_2024-03-04.pdf`)
- ✅ Toast notification: "Wochenplan exportiert: [path]"
- ✅ PDF file created at specified location

**Actual**: _[To be filled during testing]_

---

### TC-2: Month Export - Basic Functionality

**Steps**:
1. Navigate to a month with events
2. Open Command Palette
3. Type "monat"
4. Select "Monat als PDF exportieren"
5. Specify custom filename: `/tmp/test_month.pdf`
6. Click "Exportieren"

**Expected**:
- ✅ Dialog opens with month/year displayed
- ✅ Custom filename accepted
- ✅ PDF created with month calendar layout
- ✅ Success notification shown

**Actual**: _[To be filled during testing]_

---

### TC-3: PDF Content - Week View

**Steps**:
1. Export a week with at least 10 events across multiple days
2. Open generated PDF in viewer

**Verify**:
- ✅ Header shows "Wochenplan – [date range]"
- ✅ 7 columns (Monday to Sunday)
- ✅ Day headers show day name and date
- ✅ Events display with correct times
- ✅ Category colors visible as backgrounds
- ✅ All events visible (no cutoff)
- ✅ Legend at bottom shows all categories
- ✅ Text is readable and clear
- ✅ No overlapping elements
- ✅ Margins are correct (~15mm)

**Actual**: _[To be filled during testing]_

---

### TC-4: PDF Content - Month View

**Steps**:
1. Export a month with events on multiple days
2. Open generated PDF in viewer

**Verify**:
- ✅ Header shows "Monatsplan – [month year]"
- ✅ Calendar grid with day headers (Mo, Di, Mi, etc.)
- ✅ Date numbers in each cell
- ✅ Up to 3 events per cell visible
- ✅ "+N more" indicator for overflow cells
- ✅ Category color bars on events
- ✅ Legend shows all categories
- ✅ Grid lines are clear
- ✅ No text overflow outside cells
- ✅ Month structure correct (starts on right day)

**Actual**: _[To be filled during testing]_

---

### TC-5: Category Colors and Legend

**Steps**:
1. Create events with 4+ different categories
2. Export week containing these events
3. Open PDF

**Verify**:
- ✅ Each category has distinct color
- ✅ Colors are print-friendly (not too dark/bright)
- ✅ Legend shows all categories used
- ✅ Legend labels match category names
- ✅ Color boxes in legend match event colors

**Actual**: _[To be filled during testing]_

---

### TC-6: Date Formatting

**Steps**:
1. Export weeks crossing month boundaries
   - Same month: March 4-10
   - Different months: Feb 26 - Mar 3
   - Different years: Dec 28 - Jan 3
2. Check header date format

**Expected**:
- Same month: "4.–10. März 2024"
- Different months: "26. Feb.–3. März 2024"
- Different years: "28. Dez. 2023–3. Jan. 2024"

**Actual**: _[To be filled during testing]_

---

### TC-7: Paper Sizes

**Steps**:
1. Export with default settings (A4)
2. Check PDF properties in viewer

**Verify**:
- ✅ Page size: 210 × 297 mm (A4)
- ✅ Content fills page appropriately
- ✅ Nothing cut off at edges

**Future Test** (when Letter support is configurable):
- Export with Letter setting
- Verify: 8.5 × 11 inches
- Content scales appropriately

**Actual**: _[To be filled during testing]_

---

### TC-8: Font Embedding

**Steps**:
1. Export any schedule
2. Check PDF properties/fonts in viewer
3. Verify "Inter" appears in embedded fonts list

**Expected**:
- ✅ Inter-Regular embedded
- ✅ Inter-Bold embedded (if used)
- ✅ Text displays consistently on different systems

**Actual**: _[To be filled during testing]_

---

### TC-9: Dark Theme to Light Conversion

**Steps**:
1. Enable dark theme in app
2. Note category colors in UI
3. Export schedule
4. Open PDF and compare colors

**Expected**:
- ✅ Dark UI colors converted to lighter print colors
- ✅ PDF background is white
- ✅ Text is dark/readable
- ✅ Colors maintain distinctiveness

**Actual**: _[To be filled during testing]_

---

### TC-10: Error Handling - Invalid Path

**Steps**:
1. Open export dialog
2. Enter invalid path: `/root/denied.pdf` (no permission)
3. Click "Exportieren"

**Expected**:
- ✅ Export fails gracefully
- ✅ Error toast: "Export fehlgeschlagen: [error message]"
- ✅ Dialog remains open
- ✅ No crash

**Actual**: _[To be filled during testing]_

---

### TC-11: Error Handling - Invalid Date

**Steps**:
From QML console:
```qml
planner.exportWeekPdf("invalid-date", "/tmp/test.pdf")
```

**Expected**:
- ✅ Returns false
- ✅ Error message: "Invalid week start date"
- ✅ Toast notification shown
- ✅ No PDF created

**Actual**: _[To be filled during testing]_

---

### TC-12: Empty Schedule Export

**Steps**:
1. Navigate to a week with no events
2. Export the week
3. Open PDF

**Expected**:
- ✅ PDF created successfully
- ✅ Header and legend present
- ✅ Calendar structure shown
- ✅ Empty cells clearly visible
- ✅ No errors or crashes

**Actual**: _[To be filled during testing]_

---

### TC-13: Large Schedule Export

**Steps**:
1. Create a month with 50+ events
2. Export the month
3. Open PDF

**Expected**:
- ✅ Export completes in <5 seconds
- ✅ All events processed (even if not all visible)
- ✅ "+N more" indicators show correct counts
- ✅ PDF size reasonable (<1 MB)

**Actual**: _[To be filled during testing]_

---

### TC-14: Command Palette Keywords

**Steps**:
Test each keyword combination:
1. Type "export" → verify both commands appear
2. Type "pdf" → verify both commands appear
3. Type "woche" → verify week export appears
4. Type "monat" → verify month export appears
5. Type "week" → verify week export appears
6. Type "month" → verify month export appears

**Expected**:
- ✅ All keyword combinations work
- ✅ Commands have correct titles
- ✅ Hints are descriptive

**Actual**: _[To be filled during testing]_

---

### TC-15: Dialog Cancel/Close

**Steps**:
1. Open export dialog
2. Test closing methods:
   - Click "Abbrechen" button
   - Click "×" button
   - Click outside dialog (on backdrop)
   - Press Escape key

**Expected**:
- ✅ All methods close dialog
- ✅ No export occurs
- ✅ No error messages

**Actual**: _[To be filled during testing]_

---

### TC-16: File Extension Handling

**Steps**:
1. Test various filename inputs:
   - "test" → should add .pdf
   - "test.pdf" → keep as is
   - "test.PDF" → keep as is
   - "test.txt" → add .pdf (becomes "test.txt.pdf")

**Expected**:
- ✅ .pdf extension added when missing
- ✅ Existing .pdf extension preserved
- ✅ Case-insensitive handling

**Actual**: _[To be filled during testing]_

---

### TC-17: Integration with File Dialog

**Steps**:
1. Open export dialog
2. Click "Durchsuchen..." button
3. Use system file picker to choose location
4. Select location and confirm

**Expected**:
- ✅ File dialog opens
- ✅ Default filter: "PDF files (*.pdf)"
- ✅ Selected path appears in text field
- ✅ File:// prefix removed if present

**Actual**: _[To be filled during testing]_

---

## Regression Tests

### RT-1: Existing Features Unaffected

**Verify**:
- ✅ Quick Add still works
- ✅ Command Palette other commands work
- ✅ Category picker functions
- ✅ Event creation/editing unchanged
- ✅ Zen mode still functional

**Actual**: _[To be filled during testing]_

---

## Performance Tests

### PT-1: Export Speed

**Test**: Export month with 100 events

**Expected**: <3 seconds

**Actual**: _[To be filled during testing]_

---

### PT-2: Memory Usage

**Test**: 
1. Note memory before export
2. Export 5 different months
3. Check memory after

**Expected**: 
- Memory increase <50 MB
- No memory leaks (returns to baseline)

**Actual**: _[To be filled during testing]_

---

## Cross-Platform Tests (if applicable)

### CP-1: Different Linux Distributions

Test on:
- [ ] Fedora
- [ ] Ubuntu
- [ ] Arch Linux
- [ ] Debian

**Verify**: PDF generation works identically

---

### CP-2: PDF Viewers

Test opening generated PDFs in:
- [ ] Evince
- [ ] Okular
- [ ] Firefox PDF viewer
- [ ] Chrome PDF viewer
- [ ] Adobe Reader (if available)

**Verify**: Consistent rendering across viewers

---

## Test Summary

**Total Tests**: 19 (17 functional + 2 performance)

**Status**:
- Passed: _[Count]_
- Failed: _[Count]_
- Blocked: _[Count]_
- Not Run: _[Count]_

**Issues Found**: _[List any bugs or issues]_

**Recommendations**: _[Any suggestions for improvement]_

---

## Notes

- Sample PDFs should be committed to `docs/exports/` after successful testing
- Any failing tests should have corresponding GitHub issues created
- Performance benchmarks should be documented for reference

---

**Test Date**: _[To be filled]_  
**Tester**: _[Name]_  
**Build Version**: _[Git commit hash]_  
**Qt Version**: _[Version number]_
