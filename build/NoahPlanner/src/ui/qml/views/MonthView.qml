import QtQuick
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner 1.0 as NP

Column {
    id: root
    property string selectedIso: PlannerBackend.selectedDate
    property var days: []
    property string locale: Qt.locale().name
    signal daySelected(string iso)

    spacing: NP.ThemeStore.spacing.gap16

    readonly property var weekdayNames: [qsTr("Mo"), qsTr("Di"), qsTr("Mi"), qsTr("Do"), qsTr("Fr"), qsTr("Sa"), qsTr("So")]
    readonly property var anchorDate: selectedIso.length > 0 ? new Date(selectedIso) : new Date()
    readonly property string monthTitle: Qt.formatDate(anchorDate, "MMMM")

    RowLayout {
        width: parent ? parent.width : implicitWidth
        spacing: NP.ThemeStore.spacing.gap16
        Repeater {
            model: weekdayNames
            delegate: Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: modelData
                font.pixelSize: 12
                font.weight: Font.Medium
                font.letterSpacing: 1
                font.family: NP.ThemeStore.defaultFontFamily
                color: NP.ThemeStore.muted
            }
        }
    }

    GridLayout {
        id: grid
        columns: 7
        columnSpacing: NP.ThemeStore.spacing.gap12
        rowSpacing: NP.ThemeStore.spacing.gap16
        width: parent ? parent.width : implicitWidth

        Repeater {
            model: days
            delegate: DayCell {
                isoDate: modelData.iso
                inMonth: modelData.inMonth
                isToday: modelData.isToday
                selected: modelData.iso === root.selectedIso
                events: modelData.events
                Layout.fillWidth: true
                Layout.preferredWidth: grid.width / 7 - grid.columnSpacing
                Layout.preferredHeight: 124
                onActivated: iso => root.daySelected(iso)
            }
        }
    }

    function rebuild() {
        var anchor = anchorDate
        var year = anchor.getFullYear()
        var month = anchor.getMonth()
        var first = new Date(year, month, 1)
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
                inMonth: current.getMonth() === month,
                isToday: Qt.formatDate(current, "yyyy-MM-dd") === Qt.formatDate(new Date(), "yyyy-MM-dd"),
                events: PlannerBackend.dayEvents(iso)
            })
        }
        days = collection
    }

    onSelectedIsoChanged: rebuild()

    Component.onCompleted: rebuild()

    Connections {
        target: PlannerBackend
        function onSelectedDateChanged() {
            root.selectedIso = PlannerBackend.selectedDate
        }
        function onFiltersChanged() {
            root.rebuild()
        }
        function onTasksChanged() {
            root.rebuild()
        }
    }
}
