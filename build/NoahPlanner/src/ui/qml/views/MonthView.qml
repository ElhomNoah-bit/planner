import QtQuick
import QtQuick.Layouts
import NoahPlanner.Styles as Styles

Item {
    id: month
    Layout.fillWidth: true
    Layout.fillHeight: true

    property string selectedIso: planner.selectedDate
    property var days: []
    property string locale: Qt.locale().name
    signal daySelected(string iso)
    signal quickAddRequested(string iso, string kind)
    signal jumpToTodayRequested()

    property string weekStartSetting: "monday"
    property bool showWeekNumbersSetting: false
    property var weekdayLabels: []
    property var weekNumbers: []

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject metrics: Styles.ThemeStore.layout
    readonly property var anchorDate: selectedIso.length > 0 ? new Date(selectedIso) : new Date()
    readonly property real weekNumberWidth: showWeekNumbersSetting ? 48 : 0

    ColumnLayout {
        width: parent.width
        height: parent.height
        spacing: gaps.g8

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: gaps.g8
            spacing: gaps.g8
            Item {
                visible: month.showWeekNumbersSetting
                Layout.preferredWidth: weekNumberWidth
            }
            Repeater {
                model: month.weekdayLabels
                delegate: Text {
                    Layout.fillWidth: true
                    text: modelData
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: typeScale.sm
                    font.weight: typeScale.weightMedium
                    font.family: Styles.ThemeStore.fonts.heading
                    color: colors.text2
                    renderType: Text.NativeRendering
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: metrics.gridGap

            ColumnLayout {
                visible: month.showWeekNumbersSetting
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: weekNumberWidth
                spacing: metrics.gridGap
                Repeater {
                    model: month.weekNumbers
                    delegate: Text {
                        text: modelData
                        font.pixelSize: typeScale.xs
                        font.weight: typeScale.weightMedium
                        font.family: Styles.ThemeStore.fonts.body
                        color: colors.text2
                        horizontalAlignment: Text.AlignHCenter
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
                        onContextCreateEvent: month.quickAddRequested(iso, "event")
                        onContextCreateTask: month.quickAddRequested(iso, "task")
                        onContextJumpToToday: month.jumpToTodayRequested()
                    }
                }
            }
        }
    }

    function rebuild() {
        var anchor = anchorDate
        var year = anchor.getFullYear()
        var monthIndex = anchor.getMonth()
        var first = new Date(year, monthIndex, 1)
        var offset = weekStartSetting === "sunday"
                     ? first.getDay()
                     : ((first.getDay() + 6) % 7)
        var start = new Date(first)
        start.setDate(first.getDate() - offset)
        var collection = []
        var weeks = []
        for (var i = 0; i < 42; ++i) {
            var current = new Date(start)
            current.setDate(start.getDate() + i)
            var iso = Qt.formatDate(current, "yyyy-MM-dd")
            collection.push({
                iso: iso,
                inMonth: current.getMonth() === monthIndex,
                isToday: Qt.formatDate(current, "yyyy-MM-dd") === Qt.formatDate(new Date(), "yyyy-MM-dd"),
                events: planner.dayEvents(iso)
            })
            if (i % 7 === 0) {
                weeks.push(Qt.formatDate(current, "ww"))
            }
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
        weekNumbers = weeks
    }

    onSelectedIsoChanged: rebuild()
    onWeekStartSettingChanged: {
        updateWeekdayNames()
        rebuild()
    }
    onShowWeekNumbersSettingChanged: rebuild()

    Component.onCompleted: {
        updateWeekdayNames()
        rebuild()
    }

    function updateWeekdayNames() {
        var base = [qsTr("Mo"), qsTr("Di"), qsTr("Mi"), qsTr("Do"), qsTr("Fr"), qsTr("Sa"), qsTr("So")]
        if (weekStartSetting === "sunday") {
            var reordered = []
            reordered.push(base[6])
            for (var i = 0; i < 6; ++i) reordered.push(base[i])
            weekdayLabels = reordered
        } else {
            weekdayLabels = base
        }
    }

    Connections {
        target: planner
        function onSelectedDateChanged() {
            month.selectedIso = planner.selectedDate
        }
        function onEventsChanged() {
            month.rebuild()
        }
        function onOnlyOpenChanged() {
            month.rebuild()
        }
    }

}
