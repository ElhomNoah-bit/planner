# Spaced Repetition System Documentation

## Overview

The Noah Planner now includes a complete spaced repetition system based on the SM-2 (SuperMemo 2) algorithm. This feature helps users optimize learning by scheduling reviews at scientifically optimal intervals.

## Architecture

### Core Components

#### 1. Review Data Structure (`src/core/Review.h`)
```cpp
struct Review {
    QString id;              // Unique identifier
    QString subjectId;       // Associated subject
    QString topic;           // Topic being reviewed
    QDate lastReviewDate;    // Last review date
    QDate nextReviewDate;    // Next optimal review date
    int repetitionNumber;    // Number of successful reviews
    double easeFactor;       // Ease factor (SM-2 algorithm)
    int intervalDays;        // Current interval
    int quality;             // Last response quality (0-5)
};
```

#### 2. SpacedRepetitionService (`src/core/SpacedRepetitionService.h/cpp`)

**Purpose**: Core service implementing the SM-2 algorithm

**Key Methods**:
- `addReview(subjectId, topic)` - Add a new review item
- `recordReview(reviewId, quality)` - Record review performance
- `dueReviews(date)` - Get reviews due on/before a date
- `reviewsForSubject(subjectId)` - Get all reviews for a subject
- `setInitialInterval(days)` - Configure initial review interval

**SM-2 Algorithm Implementation**:
The service implements the SuperMemo 2 algorithm:

1. **Quality Ratings** (0-5):
   - 0: Complete blackout
   - 1: Incorrect but correct answer remembered
   - 2: Incorrect but seemed easy to recall
   - 3: Correct with serious difficulty
   - 4: Correct after hesitation
   - 5: Perfect response

2. **Ease Factor Calculation**:
   ```
   EF' = EF + (0.1 - (5-q) * (0.08 + (5-q) * 0.02))
   Minimum EF: 1.3
   Default EF: 2.5
   ```

3. **Interval Calculation**:
   - First repetition: configurable (default 1 day)
   - Second repetition: 6 days
   - Subsequent: previous_interval * ease_factor
   - Reset to initial if quality < 3

#### 3. ReviewModel (`src/models/ReviewModel.h/cpp`)

**Purpose**: Qt model for exposing reviews to QML

**Roles**:
- IdRole
- SubjectIdRole
- TopicRole
- LastReviewDateRole
- NextReviewDateRole
- RepetitionNumberRole
- EaseFactorRole
- IntervalDaysRole
- QualityRole
- IsDueRole

#### 4. PlannerBackend Integration (`src/ui/PlannerBackend.h/cpp`)

**New Properties**:
- `dueReviews` - List of reviews due today
- `dueReviewCount` - Number of due reviews

**New Methods**:
- `addReview(subjectId, topic)` - Add review from QML
- `recordReview(reviewId, quality)` - Record review from QML
- `removeReview(reviewId)` - Remove a review
- `getReviewsForSubject(subjectId)` - Query reviews
- `getAllReviews()` - Get all reviews
- `getReviewsOnDate(isoDate)` - Get reviews on specific date
- `setReviewInitialInterval(days)` - Configure settings
- `refreshReviews()` - Force refresh of due reviews list

**Signals**:
- `dueReviewsChanged()` - Emitted when due reviews change

### UI Components

#### 1. ReviewIndicator (`src/ui/qml/components/ReviewIndicator.qml`)

**Purpose**: Badge showing number of due reviews

**Features**:
- Shows count of due reviews
- Clickable to open review dialog
- Tooltip with details
- Only visible when reviews are due

**Usage**:
```qml
ReviewIndicator {
    dueCount: backend.dueReviewCount
    onClicked: reviewDialog.open()
}
```

#### 2. ReviewDialog (`src/ui/qml/components/ReviewDialog.qml`)

**Purpose**: Complete review management interface

**Features**:
- View all reviews
- Filter by due/all
- Add new reviews
- Perform reviews with quality ratings
- Delete reviews
- Shows SM-2 statistics (repetitions, ease factor, interval)

**Usage**:
```qml
ReviewDialog {
    backend: planner
    // Call open() to show
}
```

#### 3. Settings Integration (`src/ui/qml/components/SettingsDialog.qml`)

**New Setting**:
- "Review Intervall (Tage)" - SpinBox to configure initial interval (1-7 days)

### Data Persistence

#### reviews.json Structure

**Location**: `~/.local/share/NoahPlanner/reviews.json`

**Format**:
```json
{
  "reviews": [
    {
      "id": "ma_Quadratische_Gleichungen",
      "subjectId": "ma",
      "topic": "Quadratische Gleichungen",
      "lastReviewDate": "2024-11-01",
      "nextReviewDate": "2024-11-07",
      "repetitionNumber": 2,
      "easeFactor": 2.5,
      "intervalDays": 6,
      "quality": 4
    }
  ]
}
```

**Seed Data**: Included in `data/reviews.json` for initial setup

## Usage Guide

### For Users

#### Adding a Review
1. Open Settings or Reviews Dialog
2. Click "Neues Review" button
3. Enter subject ID and topic
4. Click "Hinzufügen"

#### Performing a Review
1. When ReviewIndicator shows due reviews
2. Click on the indicator or open Reviews Dialog
3. Click "Review" button on a due item
4. Rate your recall quality (0-5)
5. System automatically calculates next review date

#### Understanding Quality Ratings
- **5**: Perfect - you knew it immediately
- **4**: Good - small hesitation
- **3**: OK - struggled but got it
- **2**: Failed - but recognized the answer
- **1**: Failed - barely remembered
- **0**: Total blank

### For Developers

#### Integrating Review Indicators

In a sidebar or header component:
```qml
import QtQuick
import QtQuick.Controls

RowLayout {
    // ... other components
    
    ReviewIndicator {
        dueCount: backend.dueReviewCount
        onClicked: reviewDialog.open()
    }
}

ReviewDialog {
    id: reviewDialog
    backend: backend
}
```

#### Programmatically Adding Reviews

From C++:
```cpp
QString reviewId = backend.addReview("ma", "Trigonometrie");
```

From QML:
```qml
backend.addReview("en", "Past Perfect Tense")
```

#### Querying Reviews

From QML:
```qml
// Get all reviews for math
var mathReviews = backend.getReviewsForSubject("ma")

// Get all reviews
var allReviews = backend.getAllReviews()

// Get reviews on specific date
var todayReviews = backend.getReviewsOnDate("2024-11-05")

// Get count of due reviews
console.log("Due:", backend.dueReviewCount)
```

#### Automatic Review Scheduling

The system automatically:
1. Calculates next review date based on SM-2
2. Updates due reviews list daily
3. Shows indicators when reviews are due
4. Adjusts intervals based on performance

## Integration Points

### With Existing Features

1. **Subjects**: Reviews are linked to subject IDs from subjects.json
2. **Calendar**: Can display review indicators on calendar dates
3. **Sidebar**: ReviewIndicator can be added to sidebar
4. **Settings**: Review preferences in settings dialog

### Future Enhancements

1. **Calendar View Integration**: Show review indicators on calendar days
2. **Statistics**: Track review performance over time
3. **Automatic Task Generation**: Create review tasks in daily plan
4. **Notifications**: Remind users of due reviews
5. **Subject Performance**: Correlate review success with subject grades

## Testing

### Manual Testing Checklist

- [ ] Add a new review
- [ ] Perform a review with quality 5 (check interval increases)
- [ ] Perform a review with quality 2 (check reset to initial)
- [ ] View all reviews
- [ ] Filter to show only due reviews
- [ ] Delete a review
- [ ] Change initial interval setting
- [ ] Verify data persists after restart
- [ ] Check dueReviewCount updates correctly

### Test Data

Use `data/reviews.json` for seed data with example reviews.

## Technical Notes

### Thread Safety
- All operations are performed on the main thread
- File I/O is synchronous (acceptable for JSON files)

### Performance
- In-memory list of reviews (fast access)
- Linear search for queries (acceptable for typical review counts < 1000)
- File saved on each modification (ensures data integrity)

### Error Handling
- Invalid quality ratings (< 0 or > 5) are rejected
- Missing data directory is created automatically
- Corrupted JSON falls back to empty review list

## References

- SuperMemo 2 Algorithm: https://www.supermemo.com/en/archives1990-2015/english/ol/sm2
- Qt Documentation: https://doc.qt.io/qt-6/
- Project Architecture: See `docs/README.md`

## Changelog

### Version 1.0 (2024-11-05)
- Initial implementation of spaced repetition system
- SM-2 algorithm with full quality ratings
- UI components for review management
- Settings integration
- Data persistence in reviews.json
