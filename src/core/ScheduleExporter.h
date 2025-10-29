#pragma once

#include <QDate>
#include <QObject>
#include <QString>

// Forward declarations
class EventRepository;
class CategoryRepository;
struct EventRecord;
struct Category;

/**
 * @brief Exports schedule data to PDF format
 * 
 * Supports weekly and monthly exports with:
 * - Category colors and legend
 * - Localized date formats
 * - Embedded Inter font
 * - Automatic dark-to-light theme conversion
 * - A4 and Letter paper size support
 */
class ScheduleExporter : public QObject {
    Q_OBJECT

public:
    enum class ExportRange {
        Week,
        Month
    };
    Q_ENUM(ExportRange)

    enum class PaperSize {
        A4,
        Letter
    };
    Q_ENUM(PaperSize)

    explicit ScheduleExporter(QObject* parent = nullptr);

    /**
     * @brief Export a week schedule to PDF
     * @param weekStart Start date of the week (should be Monday)
     * @param filePath Output PDF file path
     * @param eventRepo Event repository for loading events
     * @param categoryRepo Category repository for colors/legend
     * @return true if export succeeded, false otherwise
     */
    bool exportWeek(const QDate& weekStart, 
                    const QString& filePath,
                    EventRepository* eventRepo,
                    CategoryRepository* categoryRepo);

    /**
     * @brief Export a month schedule to PDF
     * @param month Date within the month to export (day is ignored)
     * @param filePath Output PDF file path
     * @param eventRepo Event repository for loading events
     * @param categoryRepo Category repository for colors/legend
     * @return true if export succeeded, false otherwise
     */
    bool exportMonth(const QDate& month,
                     const QString& filePath,
                     EventRepository* eventRepo,
                     CategoryRepository* categoryRepo);

    void setPaperSize(PaperSize size) { m_paperSize = size; }
    PaperSize paperSize() const { return m_paperSize; }

    QString lastError() const { return m_lastError; }

private:
    PaperSize m_paperSize = PaperSize::A4;
    QString m_lastError;

    bool exportRange(const QDate& start,
                    const QDate& end,
                    ExportRange rangeType,
                    const QString& filePath,
                    EventRepository* eventRepo,
                    CategoryRepository* categoryRepo);

    void drawHeader(QPainter* painter,
                   const QRectF& rect,
                   const QString& title,
                   const QDate& start,
                   const QDate& end);

    void drawWeekView(QPainter* painter,
                     const QRectF& contentRect,
                     const QDate& weekStart,
                     const QVector<EventRecord>& events,
                     const QVector<Category>& categories);

    void drawMonthView(QPainter* painter,
                      const QRectF& contentRect,
                      const QDate& month,
                      const QVector<EventRecord>& events,
                      const QVector<Category>& categories);

    void drawLegend(QPainter* painter,
                   const QRectF& rect,
                   const QVector<Category>& categories);

    QColor convertToPrintColor(const QColor& color) const;
    QString formatDateRange(const QDate& start, const QDate& end) const;
    QFont loadInterFont(int pointSize, bool bold = false) const;
};
