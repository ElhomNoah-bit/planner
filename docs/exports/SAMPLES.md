# Sample PDF Placeholder

This directory will contain sample PDF exports once the application is built and tested.

## Expected Files

- `sample_week_2024-03.pdf` - Example week view export
- `sample_month_2024-03.pdf` - Example month view export
- `sample_with_categories.pdf` - Example showing category colors and legend

## How to Generate Samples

Once Qt6 is installed and the application builds successfully:

1. Launch the application:
   ```bash
   ./build/noah_planner
   ```

2. Create test data:
   - Add several events across different days
   - Assign different categories to events
   - Include both all-day and timed events

3. Export samples:
   - Press `Ctrl+K` to open Command Palette
   - Type "export week" and save to this directory
   - Type "export month" and save to this directory

4. Commit the samples:
   ```bash
   git add docs/exports/*.pdf
   git commit -m "Add sample PDF exports"
   git push
   ```

## Verification Checklist

Before committing samples, verify:
- [ ] PDF opens in multiple viewers (Evince, Firefox, Chrome)
- [ ] All text is readable
- [ ] Category colors are visible and distinct
- [ ] Legend is present and correct
- [ ] No content is cut off
- [ ] Date formatting is correct
- [ ] File size is reasonable (<500 KB)

## Note

Due to the lack of Qt6 in the current build environment, sample PDFs cannot be generated automatically. They will be added in a follow-up commit after manual testing on a system with Qt6 installed.
