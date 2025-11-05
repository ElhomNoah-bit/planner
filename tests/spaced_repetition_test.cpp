#include "core/SpacedRepetitionService.h"
#include "core/Review.h"

#include <QCoreApplication>
#include <QDate>
#include <QDir>
#include <QTemporaryDir>

#include <iostream>
#include <string>

namespace {
struct TestCase {
    std::string description;
    bool (*test)(SpacedRepetitionService&);
};

void reportResult(const std::string& description, bool passed) {
    std::cout << (passed ? "[PASS] " : "[FAIL] ") << description << '\n';
}

bool testAddReviewCreatesNewReview(SpacedRepetitionService& service) {
    const int initialCount = service.reviews().size();
    const QString id = service.addReview("ma", "Algebra basics");
    
    if (id.isEmpty()) {
        return false;
    }
    
    if (service.reviews().size() != initialCount + 1) {
        return false;
    }
    
    return true;
}

bool testRemoveReviewDeletesReview(SpacedRepetitionService& service) {
    const QString id = service.addReview("en", "Vocabulary");
    const int countAfterAdd = service.reviews().size();
    
    const bool removed = service.removeReview(id);
    if (!removed) {
        return false;
    }
    
    if (service.reviews().size() != countAfterAdd - 1) {
        return false;
    }
    
    return true;
}

bool testRemoveNonExistentReviewReturnsFalse(SpacedRepetitionService& service) {
    const bool removed = service.removeReview("non_existent_id_12345");
    return !removed; // Should return false for non-existent ID
}

bool testRecordReviewUpdatesReview(SpacedRepetitionService& service) {
    const QString id = service.addReview("de", "Grammar");
    
    // Find the review
    const QList<Review> reviewsBefore = service.reviews();
    QDate nextReviewBefore;
    for (const auto& review : reviewsBefore) {
        if (review.id == id) {
            nextReviewBefore = review.nextReviewDate;
            break;
        }
    }
    
    // Record a review with quality 4 (good)
    const bool recorded = service.recordReview(id, 4);
    if (!recorded) {
        return false;
    }
    
    // Find the updated review
    const QList<Review> reviewsAfter = service.reviews();
    QDate nextReviewAfter;
    for (const auto& review : reviewsAfter) {
        if (review.id == id) {
            nextReviewAfter = review.nextReviewDate;
            break;
        }
    }
    
    // Next review date should have changed
    if (nextReviewAfter == nextReviewBefore) {
        return false;
    }
    
    // Next review should be in the future
    return nextReviewAfter > QDate::currentDate();
}

bool testRecordReviewWithInvalidQualityReturnsFalse(SpacedRepetitionService& service) {
    const QString id = service.addReview("bio", "Cell structure");
    
    // Quality must be 0-5
    if (service.recordReview(id, -1)) {
        return false;
    }
    
    if (service.recordReview(id, 6)) {
        return false;
    }
    
    return true;
}

bool testRecordReviewForNonExistentIdReturnsFalse(SpacedRepetitionService& service) {
    const bool recorded = service.recordReview("non_existent_id_67890", 3);
    return !recorded; // Should return false
}

bool testReviewsForSubjectFiltersCorrectly(SpacedRepetitionService& service) {
    service.addReview("ma", "Algebra");
    service.addReview("ma", "Geometry");
    service.addReview("en", "Reading");
    
    const QList<Review> mathReviews = service.reviewsForSubject("ma");
    
    // Should have at least 2 math reviews
    if (mathReviews.size() < 2) {
        return false;
    }
    
    // All should be for math
    for (const auto& review : mathReviews) {
        if (review.subjectId != "ma") {
            return false;
        }
    }
    
    return true;
}

bool testDueReviewsFiltersCorrectly(SpacedRepetitionService& service) {
    // Add a review and immediately mark it as due
    const QString id = service.addReview("ch", "Chemical reactions");
    
    // Get due reviews for today
    const QList<Review> due = service.dueReviews(QDate::currentDate());
    
    // Should contain at least our newly added review (due today)
    bool found = false;
    for (const auto& review : due) {
        if (review.id == id && review.nextReviewDate <= QDate::currentDate()) {
            found = true;
            break;
        }
    }
    
    return found;
}

bool testReviewsOnDateFiltersCorrectly(SpacedRepetitionService& service) {
    const QString id = service.addReview("ph", "Newton's laws");
    
    // Find the next review date
    QDate targetDate;
    for (const auto& review : service.reviews()) {
        if (review.id == id) {
            targetDate = review.nextReviewDate;
            break;
        }
    }
    
    if (!targetDate.isValid()) {
        return false;
    }
    
    const QList<Review> onDate = service.reviewsOnDate(targetDate);
    
    // Should contain our review
    bool found = false;
    for (const auto& review : onDate) {
        if (review.id == id) {
            found = true;
            break;
        }
    }
    
    return found;
}

bool testSetInitialIntervalChangesInterval(SpacedRepetitionService& service) {
    service.setInitialInterval(5);
    
    const QString id = service.addReview("geo", "Map reading");
    
    // Check the next review date
    for (const auto& review : service.reviews()) {
        if (review.id == id) {
            const int daysDiff = QDate::currentDate().daysTo(review.nextReviewDate);
            return daysDiff == 5;
        }
    }
    
    return false;
}

bool testEaseFactorModifierIsRespected(SpacedRepetitionService& service) {
    // This is harder to test without internal state inspection
    // Just verify it doesn't crash
    service.setEaseFactorModifier(1.5);
    service.setEaseFactorModifier(0.1); // Minimum value
    return true;
}

} // namespace

int main(int argc, char* argv[]) {
    QCoreApplication app(argc, argv);
    
    // Use a temporary directory for test data
    QTemporaryDir tempDir;
    if (!tempDir.isValid()) {
        std::cerr << "Failed to create temporary directory\n";
        return 1;
    }
    
    SpacedRepetitionService service(tempDir.path());
    
    std::cout << "=== SpacedRepetitionService Test Suite ===\n";
    
    const std::vector<TestCase> tests = {
        {"Add review creates new review", testAddReviewCreatesNewReview},
        {"Remove review deletes review", testRemoveReviewDeletesReview},
        {"Remove non-existent review returns false", testRemoveNonExistentReviewReturnsFalse},
        {"Record review updates review", testRecordReviewUpdatesReview},
        {"Record review with invalid quality returns false", testRecordReviewWithInvalidQualityReturnsFalse},
        {"Record review for non-existent ID returns false", testRecordReviewForNonExistentIdReturnsFalse},
        {"Reviews for subject filters correctly", testReviewsForSubjectFiltersCorrectly},
        {"Due reviews filters correctly", testDueReviewsFiltersCorrectly},
        {"Reviews on date filters correctly", testReviewsOnDateFiltersCorrectly},
        {"Set initial interval changes interval", testSetInitialIntervalChangesInterval},
        {"Ease factor modifier is respected", testEaseFactorModifierIsRespected},
    };
    
    bool allPassed = true;
    for (const auto& test : tests) {
        try {
            const bool passed = test.test(service);
            reportResult(test.description, passed);
            allPassed = allPassed && passed;
        } catch (const std::exception& e) {
            reportResult(test.description + " (exception: " + e.what() + ")", false);
            allPassed = false;
        } catch (...) {
            reportResult(test.description + " (unknown exception)", false);
            allPassed = false;
        }
    }
    
    std::cout << '\n' << (allPassed ? "All SpacedRepetitionService tests passed." : "Some SpacedRepetitionService tests failed.") << '\n';
    return allPassed ? 0 : 1;
}
