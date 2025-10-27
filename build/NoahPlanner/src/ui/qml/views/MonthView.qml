import QtQuick
import QtQuick.Layouts
import "styles" as Styles

Item {
    id: month
    anchors.fill: parent

    property string selectedIso: PlannerBackend.selectedDate
    property var days: []
    property string locale: Qt.locale().name
    signal daySelected(string iso)

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject metrics: Styles.ThemeStore.layout

    readonly property var weekdayNames: [qsTr("Mo"), qsTr("Di"), qsTr("Mi"), qsTr("Do"), qsTr("Fr"), qsTr("Sa"), qsTr("So")]
    readonly property var anchorDate: selectedIso.length > 0 ? new Date(selectedIso) : new Date()

    ColumnLayout {
        anchors.fill: parent
        spacing: gaps.g8

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: gaps.g8
            spacing: metrics.gridGap
            Repeater {
                model: weekdayNames
                delegate: Text {
                    Layout.fillWidth: true
                    text: modelData
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: typeScale.sm
                    font.weight: typeScale.weightMedium
                    font.family: Styles.ThemeStore.fonts.uiFallback
                    color: colors.text2
                    renderType: Text.NativeRendering
                }
            }
        }

        GridLayout {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 7
            columnSpacing: metrics.gridGap
            rowSpacing: metrics.gridGap
            property real cellWidth: columns > 0 ? (width - columnSpacing * (columns - 1)) / columns : width
            property real cellHeight: (height - rowSpacing * 5) / 6

            Repeater {
                model: days
                delegate: DayCell {
                    isoDate: modelData.iso
                    inMonth: modelData.inMonth
                    isToday: modelData.isToday
                    selected: modelData.iso === month.selectedIso
                    events: modelData.events
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: Math.max(120, grid.cellWidth)
                    Layout.preferredHeight: Math.max(100, grid.cellHeight)
                    onActivated: iso => month.daySelected(iso)
                }
            }
        }
    }

    function rebuild() {
        var anchor = anchorDate
        var year = anchor.getFullYear()
        var monthIndex = anchor.getMonth()
        var first = new Date(year, monthIndex, 1)
        var offset = (first.getDay() + 6) % 7
        var start = new Date(first)
        start.setDate(first.getDate() - offset)
        var collection = []
        for (var i = 0; i < 42; ++i) {
            var current = new Date(start)
            current.setDate(start.getDate() + i)
            var iso = Qt.formatDate(current, "yyyy-MM-dd")
            collection.push({
                iso: iso,
                inMonth: current.getMonth() === monthIndex,
                isToday: Qt.formatDate(current, "yyyy-MM-dd") === Qt.formatDate(new Date(), "yyyy-MM-dd"),
                events: PlannerBackend.dayEvents(iso)
            })
        }
        if (Qt.application.arguments && Qt.application.arguments.indexOf("--debug-events") !== -1) {
            for (var j = 0; j < collection.length; ++j) {
                if (j % 10 === 0) {
                    collection[j].events.push({ title: qsTr("Projekt Status"), color: colors.accent })
                }
                if (j % 15 === 0) {
                    collection[j].events.push({ title: qsTr("Mathe lernen"), color: colors.accent })
                }
            }
        }
        days = collection
    }

    onSelectedIsoChanged: rebuild()

    Component.onCompleted: rebuild()

    Connections {
        target: PlannerBackend
        function onSelectedDateChanged() {
            month.selectedIso = PlannerBackend.selectedDate
        }
        function onFiltersChanged() {
            month.rebuild()
        }
        function onTasksChanged() {
            month.rebuild()
        }
    }
}
