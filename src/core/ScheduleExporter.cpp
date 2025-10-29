#include "ScheduleExporter.h"
#include "EventRepository.h"
#include "CategoryRepository.h"
#include "Category.h"
#include "models/EventModel.h"

#include <QFile>
#include <QFontDatabase>
#include <QLocale>
#include <QPainter>
#include <QPdfWriter>
#include <QPageSize>
#include <QDateTime>
#include <QMap>
#include <QDebug>

namespace {

constexpr int DPI = 300;  // High quality PDF
constexpr double MM_TO_POINTS = 2.83465;  // Conversion factor

// Layout constants (in mm)
constexpr double MARGIN_TOP = 15.0;
constexpr double MARGIN_BOTTOM = 15.0;
constexpr double MARGIN_LEFT = 15.0;
constexpr double MARGIN_RIGHT = 15.0;
constexpr double HEADER_HEIGHT = 20.0;
constexpr double LEGEND_HEIGHT = 15.0;
constexpr double SPACING = 5.0;

// Colors for print (light theme)
const QColor PRINT_BACKGROUND = QColor(255, 255, 255);
const QColor PRINT_TEXT = QColor(33, 33, 33);
const QColor PRINT_BORDER = QColor(200, 200, 200);
const QColor PRINT_HEADER = QColor(60, 60, 60);

QString germanDayName(const QDate& date) {
    static const QStringList dayNames = {
        "Montag", "Dienstag", "Mittwoch", "Donnerstag", 
        "Freitag", "Samstag", "Sonntag"
    };
    int dayOfWeek = date.dayOfWeek();  // 1 = Monday, 7 = Sunday
    if (dayOfWeek >= 1 && dayOfWeek <= 7) {
        return dayNames[dayOfWeek - 1];
    }
    return QString();
}

QString germanMonthName(int month) {
    static const QStringList monthNames = {
        "Januar", "Februar", "März", "April", "Mai", "Juni",
        "Juli", "August", "September", "Oktober", "November", "Dezember"
    };
    if (month >= 1 && month <= 12) {
        return monthNames[month - 1];
    }
    return QString();
}

} // anonymous namespace

ScheduleExporter::ScheduleExporter(QObject* parent)
    : QObject(parent)
{
}

bool ScheduleExporter::exportWeek(const QDate& weekStart,
                                  const QString& filePath,
                                  EventRepository* eventRepo,
                                  CategoryRepository* categoryRepo)
{
    if (!weekStart.isValid()) {
        m_lastError = "Invalid week start date";
        return false;
    }

    // Ensure we start on Monday
    QDate monday = weekStart;
    while (monday.dayOfWeek() != Qt::Monday) {
        monday = monday.addDays(-1);
    }

    QDate sunday = monday.addDays(6);
    return exportRange(monday, sunday, ExportRange::Week, filePath, eventRepo, categoryRepo);
}

bool ScheduleExporter::exportMonth(const QDate& month,
                                   const QString& filePath,
                                   EventRepository* eventRepo,
                                   CategoryRepository* categoryRepo)
{
    if (!month.isValid()) {
        m_lastError = "Invalid month date";
        return false;
    }

    QDate start(month.year(), month.month(), 1);
    QDate end(month.year(), month.month(), start.daysInMonth());

    return exportRange(start, end, ExportRange::Month, filePath, eventRepo, categoryRepo);
}

bool ScheduleExporter::exportRange(const QDate& start,
                                   const QDate& end,
                                   ExportRange rangeType,
                                   const QString& filePath,
                                   EventRepository* eventRepo,
                                   CategoryRepository* categoryRepo)
{
    if (!eventRepo || !categoryRepo) {
        m_lastError = "Repository pointers are null";
        return false;
    }

    if (!start.isValid() || !end.isValid() || start > end) {
        m_lastError = "Invalid date range";
        return false;
    }

    // Load data
    QVector<EventRecord> events = eventRepo->loadBetween(start, end, false);
    QVector<Category> categories = categoryRepo->loadAll();

    // Setup PDF writer
    QPdfWriter writer(filePath);
    writer.setResolution(DPI);
    
    // Set page size
    if (m_paperSize == PaperSize::A4) {
        writer.setPageSize(QPageSize(QPageSize::A4));
    } else {
        writer.setPageSize(QPageSize(QPageSize::Letter));
    }

    writer.setPageMargins(QMarginsF(MARGIN_LEFT, MARGIN_TOP, MARGIN_RIGHT, MARGIN_BOTTOM), QPageLayout::Millimeter);
    writer.setTitle(rangeType == ExportRange::Week ? "Wochenplan" : "Monatsplan");
    writer.setCreator("Noah Planner");

    QPainter painter(&writer);
    if (!painter.isActive()) {
        m_lastError = "Failed to initialize PDF painter";
        return false;
    }

    // Enable antialiasing for better quality
    painter.setRenderHint(QPainter::Antialiasing, true);
    painter.setRenderHint(QPainter::TextAntialiasing, true);

    // Calculate layout
    QRectF pageRect = writer.pageLayout().paintRectPixels(DPI);
    
    double headerHeightPx = HEADER_HEIGHT * MM_TO_POINTS;
    double legendHeightPx = LEGEND_HEIGHT * MM_TO_POINTS;
    double spacingPx = SPACING * MM_TO_POINTS;

    QRectF headerRect(pageRect.left(), pageRect.top(), pageRect.width(), headerHeightPx);
    QRectF contentRect(pageRect.left(), headerRect.bottom() + spacingPx,
                      pageRect.width(), pageRect.height() - headerHeightPx - legendHeightPx - 2 * spacingPx);
    QRectF legendRect(pageRect.left(), contentRect.bottom() + spacingPx,
                     pageRect.width(), legendHeightPx);

    // Draw components
    QString title = rangeType == ExportRange::Week ? "Wochenplan" : "Monatsplan";
    drawHeader(&painter, headerRect, title, start, end);

    if (rangeType == ExportRange::Week) {
        drawWeekView(&painter, contentRect, start, events, categories);
    } else {
        drawMonthView(&painter, contentRect, start, events, categories);
    }

    drawLegend(&painter, legendRect, categories);

    painter.end();

    if (!QFile::exists(filePath)) {
        m_lastError = "PDF file was not created";
        return false;
    }

    m_lastError.clear();
    return true;
}

void ScheduleExporter::drawHeader(QPainter* painter,
                                  const QRectF& rect,
                                  const QString& title,
                                  const QDate& start,
                                  const QDate& end)
{
    painter->save();

    // Title
    QFont titleFont = loadInterFont(18, true);
    painter->setFont(titleFont);
    painter->setPen(PRINT_HEADER);

    QString dateRange = formatDateRange(start, end);
    QString fullTitle = QString("%1 – %2").arg(title, dateRange);

    painter->drawText(rect, Qt::AlignLeft | Qt::AlignVCenter, fullTitle);

    // Draw separator line
    painter->setPen(QPen(PRINT_BORDER, 1));
    painter->drawLine(rect.bottomLeft(), rect.bottomRight());

    painter->restore();
}

void ScheduleExporter::drawWeekView(QPainter* painter,
                                    const QRectF& contentRect,
                                    const QDate& weekStart,
                                    const QVector<EventRecord>& events,
                                    const QVector<Category>& categories)
{
    painter->save();

    // Create category color map
    QMap<QString, QColor> categoryColors;
    for (const auto& cat : categories) {
        categoryColors[cat.id] = convertToPrintColor(cat.color);
    }

    double columnWidth = contentRect.width() / 7.0;
    double rowHeight = 60.0;  // Height for time slots

    QFont dayFont = loadInterFont(10, true);
    QFont eventFont = loadInterFont(8);

    // Draw days
    for (int day = 0; day < 7; ++day) {
        QDate currentDate = weekStart.addDays(day);
        double x = contentRect.left() + day * columnWidth;

        // Day header
        QRectF dayHeaderRect(x, contentRect.top(), columnWidth, 40);
        painter->setPen(PRINT_BORDER);
        painter->drawRect(dayHeaderRect);

        painter->setFont(dayFont);
        painter->setPen(PRINT_HEADER);
        
        QString dayLabel = QString("%1\n%2")
            .arg(germanDayName(currentDate))
            .arg(currentDate.toString("dd.MM."));
        
        painter->drawText(dayHeaderRect.adjusted(5, 0, -5, 0), 
                         Qt::AlignCenter | Qt::TextWordWrap, 
                         dayLabel);

        // Draw events for this day
        QVector<EventRecord> dayEvents;
        for (const auto& event : events) {
            QDate eventDate = event.start.date();
            if (event.allDay && eventDate == currentDate) {
                dayEvents.append(event);
            } else if (!event.allDay && eventDate == currentDate) {
                dayEvents.append(event);
            }
        }

        double eventY = dayHeaderRect.bottom() + 5;
        double maxY = contentRect.bottom();

        painter->setFont(eventFont);
        for (const auto& event : dayEvents) {
            if (eventY >= maxY) break;

            QRectF eventRect(x + 3, eventY, columnWidth - 6, rowHeight - 5);

            // Background color from category
            QColor bgColor = PRINT_BACKGROUND;
            if (!event.categoryId.isEmpty() && categoryColors.contains(event.categoryId)) {
                bgColor = categoryColors[event.categoryId];
                bgColor.setAlpha(50);  // Light background
            }

            painter->fillRect(eventRect, bgColor);
            painter->setPen(QPen(PRINT_BORDER, 1));
            painter->drawRect(eventRect);

            // Event text
            painter->setPen(PRINT_TEXT);
            QString eventText = event.title;
            if (!event.allDay && event.start.isValid()) {
                eventText = QString("%1\n%2").arg(event.start.toString("HH:mm"), event.title);
            }

            painter->drawText(eventRect.adjusted(3, 2, -3, -2), 
                            Qt::AlignLeft | Qt::AlignTop | Qt::TextWordWrap,
                            eventText);

            eventY += rowHeight;
        }
    }

    painter->restore();
}

void ScheduleExporter::drawMonthView(QPainter* painter,
                                     const QRectF& contentRect,
                                     const QDate& month,
                                     const QVector<EventRecord>& events,
                                     const QVector<Category>& categories)
{
    painter->save();

    // Create category color map
    QMap<QString, QColor> categoryColors;
    for (const auto& cat : categories) {
        categoryColors[cat.id] = convertToPrintColor(cat.color);
    }

    // Calculate grid
    int daysInMonth = month.daysInMonth();
    QDate firstDay(month.year(), month.month(), 1);
    int startDayOfWeek = firstDay.dayOfWeek();  // 1 = Monday

    // We need to show a grid with week days, starting from Monday
    int rows = qCeil((daysInMonth + startDayOfWeek - 1) / 7.0);
    double cellWidth = contentRect.width() / 7.0;
    double cellHeight = contentRect.height() / (rows + 1);  // +1 for header row

    QFont dayFont = loadInterFont(8, true);
    QFont dateFont = loadInterFont(7);
    QFont eventFont = loadInterFont(6);

    // Draw day headers
    QStringList dayHeaders = {"Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"};
    for (int col = 0; col < 7; ++col) {
        QRectF headerRect(contentRect.left() + col * cellWidth, contentRect.top(),
                         cellWidth, cellHeight * 0.6);
        
        painter->setPen(PRINT_BORDER);
        painter->drawRect(headerRect);
        
        painter->setFont(dayFont);
        painter->setPen(PRINT_HEADER);
        painter->drawText(headerRect, Qt::AlignCenter, dayHeaders[col]);
    }

    // Draw days
    int currentDay = 1;
    for (int row = 0; row < rows && currentDay <= daysInMonth; ++row) {
        for (int col = 0; col < 7 && currentDay <= daysInMonth; ++col) {
            // Skip cells before the first day
            if (row == 0 && col < startDayOfWeek - 1) {
                continue;
            }

            QDate cellDate(month.year(), month.month(), currentDay);
            double cellX = contentRect.left() + col * cellWidth;
            double cellY = contentRect.top() + (row + 1) * cellHeight * 0.6 + row * cellHeight * 0.4;

            QRectF cellRect(cellX, cellY, cellWidth, cellHeight);

            // Draw cell border
            painter->setPen(QPen(PRINT_BORDER, 0.5));
            painter->setBrush(Qt::NoBrush);
            painter->drawRect(cellRect);

            // Draw date number
            painter->setFont(dateFont);
            painter->setPen(PRINT_HEADER);
            QRectF dateRect(cellX + 2, cellY + 2, cellWidth - 4, 15);
            painter->drawText(dateRect, Qt::AlignLeft | Qt::AlignTop, QString::number(currentDay));

            // Draw events for this day
            QVector<EventRecord> dayEvents;
            for (const auto& event : events) {
                QDate eventDate = event.start.date();
                if (eventDate == cellDate) {
                    dayEvents.append(event);
                }
            }

            double eventY = dateRect.bottom() + 2;
            painter->setFont(eventFont);
            
            int eventCount = 0;
            const int maxEventsPerCell = 3;
            
            for (const auto& event : dayEvents) {
                if (eventCount >= maxEventsPerCell) {
                    // Show "+N more" indicator
                    painter->setPen(PRINT_TEXT);
                    painter->drawText(QRectF(cellX + 2, eventY, cellWidth - 4, 10),
                                    Qt::AlignLeft | Qt::AlignTop,
                                    QString("+%1").arg(dayEvents.size() - maxEventsPerCell));
                    break;
                }

                QRectF eventRect(cellX + 2, eventY, cellWidth - 4, 10);

                // Draw category color indicator
                if (!event.categoryId.isEmpty() && categoryColors.contains(event.categoryId)) {
                    QColor color = categoryColors[event.categoryId];
                    painter->fillRect(QRectF(cellX + 2, eventY, 3, 10), color);
                }

                // Draw event title (truncated)
                painter->setPen(PRINT_TEXT);
                QString shortTitle = event.title;
                QFontMetrics fm(eventFont);
                shortTitle = fm.elidedText(shortTitle, Qt::ElideRight, cellWidth - 10);
                
                painter->drawText(eventRect.adjusted(5, 0, 0, 0), 
                                Qt::AlignLeft | Qt::AlignVCenter,
                                shortTitle);

                eventY += 10;
                eventCount++;
            }

            currentDay++;
        }
    }

    painter->restore();
}

void ScheduleExporter::drawLegend(QPainter* painter,
                                  const QRectF& rect,
                                  const QVector<Category>& categories)
{
    if (categories.isEmpty()) {
        return;
    }

    painter->save();

    QFont legendFont = loadInterFont(8);
    painter->setFont(legendFont);

    // Draw legend title
    painter->setPen(PRINT_HEADER);
    painter->drawText(QRectF(rect.left(), rect.top(), rect.width(), 15),
                     Qt::AlignLeft | Qt::AlignVCenter,
                     "Kategorien:");

    // Draw category boxes
    double x = rect.left() + 80;
    double y = rect.top();
    double boxSize = 10;
    double spacing = 5;

    for (const auto& category : categories) {
        // Draw color box
        QRectF colorBox(x, y + 2, boxSize, boxSize);
        painter->fillRect(colorBox, convertToPrintColor(category.color));
        painter->setPen(QPen(PRINT_BORDER, 0.5));
        painter->drawRect(colorBox);

        // Draw label
        painter->setPen(PRINT_TEXT);
        QRectF labelRect(x + boxSize + 3, y, 100, 15);
        painter->drawText(labelRect, Qt::AlignLeft | Qt::AlignVCenter, category.name);

        x += boxSize + 100 + spacing;

        // Wrap to next line if needed
        if (x > rect.right() - 100) {
            x = rect.left() + 80;
            y += 15;
        }
    }

    painter->restore();
}

QColor ScheduleExporter::convertToPrintColor(const QColor& color) const
{
    // For dark theme colors, ensure they work well on white background
    // We brighten dark colors and keep light colors as is
    
    int h, s, v, a;
    color.getHsv(&h, &s, &v, &a);
    
    // If color is too dark (value < 128), brighten it
    if (v < 128) {
        v = qMin(255, v + 80);
    }
    
    // Reduce saturation slightly for better print quality
    s = qMin(255, int(s * 0.85));
    
    return QColor::fromHsv(h, s, v, a);
}

QString ScheduleExporter::formatDateRange(const QDate& start, const QDate& end) const
{
    if (!start.isValid() || !end.isValid()) {
        return QString();
    }

    if (start.year() == end.year() && start.month() == end.month()) {
        // Same month: "1.–7. März 2024"
        return QString("%1.–%2. %3 %4")
            .arg(start.day())
            .arg(end.day())
            .arg(germanMonthName(start.month()))
            .arg(start.year());
    } else if (start.year() == end.year()) {
        // Same year: "28. Feb.–6. März 2024"
        return QString("%1. %2–%3. %4 %5")
            .arg(start.day())
            .arg(germanMonthName(start.month()).left(3) + ".")
            .arg(end.day())
            .arg(germanMonthName(end.month()))
            .arg(start.year());
    } else {
        // Different years: "28. Dez. 2023–3. Jan. 2024"
        return QString("%1. %2 %3–%4. %5 %6")
            .arg(start.day())
            .arg(germanMonthName(start.month()).left(3) + ".")
            .arg(start.year())
            .arg(end.day())
            .arg(germanMonthName(end.month()).left(3) + ".")
            .arg(end.year());
    }
}

QFont ScheduleExporter::loadInterFont(int pointSize, bool bold) const
{
    // Try to load embedded Inter font
    static int regularFontId = -1;
    static int boldFontId = -1;
    
    if (regularFontId == -1) {
        regularFontId = QFontDatabase::addApplicationFont(":/fonts/Inter-Regular.ttf");
    }
    if (boldFontId == -1) {
        boldFontId = QFontDatabase::addApplicationFont(":/fonts/Inter-Bold.ttf");
    }

    QFont font;
    if (bold && boldFontId != -1) {
        QStringList families = QFontDatabase::applicationFontFamilies(boldFontId);
        if (!families.isEmpty()) {
            font = QFont(families.at(0), pointSize, QFont::Bold);
        }
    } else if (!bold && regularFontId != -1) {
        QStringList families = QFontDatabase::applicationFontFamilies(regularFontId);
        if (!families.isEmpty()) {
            font = QFont(families.at(0), pointSize, QFont::Normal);
        }
    }

    // Fallback to system font if Inter is not available
    if (font.family().isEmpty()) {
        font = QFont("sans-serif", pointSize, bold ? QFont::Bold : QFont::Normal);
    }

    return font;
}
