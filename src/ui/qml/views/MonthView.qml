import QtQuick
import QtQuick.Layouts
import styles 1.0 as Styles

Item {
    id: month
    anchors.fill: parent

    property string selectedIso: PlannerBackend.selectedDate
    property var days: []
    property string locale: Qt.locale().name
    signal daySelected(string iso)

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var gap: theme ? theme.gap : null
    readonly property var typeScale: theme ? theme.type : null
    readonly property var layout: theme ? theme.layout : null

    readonly property var weekdayNames: [qsTr("Mo"), qsTr("Di"), qsTr("Mi"), qsTr("Do"), qsTr("Fr"), qsTr("Sa"), qsTr("So")]
    readonly property var anchorDate: selectedIso.length > 0 ? new Date(selectedIso) : new Date()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: layout ? layout.margin : (gap ? gap.g24 : 24)
        spacing: gap ? gap.g16 : 16

        RowLayout {
            Layout.fillWidth: true
            spacing: layout ? layout.gridGap : (gap ? gap.g12 : 12)
            Repeater {
                model: weekdayNames
                delegate: Text {
                    Layout.fillWidth: true
                    text: modelData
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: typeScale ? typeScale.sm : 12
                    font.weight: typeScale ? typeScale.weightMedium : Font.Medium
                    font.family: Styles.ThemeStore.fonts.uiFallback
                    color: colors ? colors.text2 : "#B7C0CC"
                    renderType: Text.NativeRendering
                }
            }
        }

        GridLayout {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 7
            columnSpacing: layout ? layout.gridGap : (gap ? gap.g12 : 12)
            rowSpacing: layout ? layout.gridGap : (gap ? gap.g12 : 12)
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
                    collection[j].events.push({ title: qsTr("Projekt Status"), color: colors ? colors.accent : "#0A84FF" })
                }
                if (j % 15 === 0) {
                    collection[j].events.push({ title: qsTr("Mathe lernen"), color: "#FF9F0A" })
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
