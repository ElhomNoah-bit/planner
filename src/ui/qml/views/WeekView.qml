import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles
import "../components"

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    property string anchorIso: planner.selectedDate
    property string weekStartIso: ""
    property var eventsByDay: []
    property var allDayByDay: []
    property int startHour: 8
    property int endHour: 20
    property real minuteHeight: 1.1
    property int currentMinutes: (new Date()).getHours() * 60 + (new Date()).getMinutes()
    property bool zenMode: false
    signal daySelected(string iso)

    property string weekStartSetting: "monday"
    property var weekdayLabels: []

    readonly property real timelineHeight: (endHour - startHour) * 60 * minuteHeight

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject radii: Styles.ThemeStore.radii
    readonly property QtObject fonts: Styles.ThemeStore.fonts

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.currentMinutes = (new Date()).getHours() * 60 + (new Date()).getMinutes()
    }

    Rectangle {
        anchors.fill: parent
        radius: radii.lg
        color: colors.cardBg
        border.width: 1
        border.color: colors.divider
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: timelineHeight + gaps.g32
        clip: true

        Item {
            id: content
            width: parent.width
            height: timelineHeight + gaps.g32

            Row {
                id: row
                anchors.fill: parent
                anchors.margins: gaps.g16
                spacing: gaps.g12

                Column {
                    id: timeAxis
                    width: 48
                    Repeater {
                        model: endHour - startHour + 1
                        delegate: Item {
                            width: parent.width
                            height: 60 * minuteHeight
                            Label {
                                anchors.right: parent.right
                                anchors.rightMargin: 4
                                anchors.verticalCenter: parent.verticalCenter
                                text: (startHour + index) + ":00"
                                font.pixelSize: typeScale.xs
                                font.weight: typeScale.weightMedium
                                font.family: fonts.uiFallback
                                color: colors.text2
                                opacity: 0.7
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }

                Repeater {
                    model: 7
                    delegate: Item {
                        id: dayItem
                        width: (content.width - timeAxis.width - row.spacing * 6) / 7
                        height: content.height
                        property var dayEvents: root.eventsByDay.length > index ? root.eventsByDay[index] : []
                        property var allDayEvents: root.allDayByDay.length > index ? root.allDayByDay[index] : []
                        property string dayIso: root.isoForDay(index)
                        readonly property bool isToday: dayIso === Qt.formatDate(new Date(), "yyyy-MM-dd")
                        readonly property bool isSelected: dayIso === root.anchorIso
                        opacity: root.zenMode && !isSelected
                                 ? Styles.ThemeStore.opacityMuted
                                 : Styles.ThemeStore.opacityFull

                        Behavior on opacity {
                            NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                        }

                        Column {
                            id: dayColumn
                            anchors.fill: parent
                            spacing: gaps.g8

                            Text {
                                text: root.weekdayLabels[index]
                                font.pixelSize: typeScale.sm
                                font.weight: typeScale.weightMedium
                                font.family: fonts.heading
                                color: colors.text2
                                opacity: 0.7
                                renderType: Text.NativeRendering
                            }
                            Text {
                                text: dayIso ? dayIso.split("-")[2] : ""
                                font.pixelSize: typeScale.md
                                font.weight: typeScale.weightBold
                                font.family: fonts.uiFallback
                                color: colors.text
                                renderType: Text.NativeRendering
                            }

                            Repeater {
                                model: allDayEvents
                                delegate: EventChip {
                                    width: parent.width
                                    label: modelData.title
                                    subjectColor: modelData.colorHint && modelData.colorHint.length ? modelData.colorHint : colors.accent
                                    timeText: modelData.startTimeLabel && modelData.startTimeLabel.length ? modelData.startTimeLabel : qsTr("Ganztägig")
                                    overdue: modelData.overdue
                                    categoryColor: modelData.categoryColor || ""
                                }
                            }
                            Item {
                                id: timeline
                                width: parent.width
                                height: root.timelineHeight

                                Rectangle {
                                    anchors.fill: parent
                                    radius: radii.md
                                    color: colors.cardGlass
                                    border.width: 1
                                    border.color: colors.divider
                                }

                                Rectangle {
                                    width: timeline.width
                                    height: 1
                                    color: "#FF4D4F"
                                    y: Math.max(0, (root.currentMinutes - root.startHour * 60) * root.minuteHeight)
                                    visible: dayItem.isToday && root.currentMinutes >= root.startHour * 60 && root.currentMinutes <= root.endHour * 60
                                    opacity: 0.9
                                }

                                Repeater {
                                    model: dayEvents
                                    delegate: Rectangle {
                                        readonly property real totalColumns: Math.max(1, modelData.columnCount || 1)
                                        readonly property real columnWidth: (timeline.width - 10) / totalColumns
                                        width: Math.max(60, columnWidth - 6)
                                        x: 5 + (columnWidth) * (modelData.column || 0)
                                        y: Math.max(0, (modelData.startMinutes - root.startHour * 60) * root.minuteHeight)
                                        height: Math.max(40, modelData.duration * root.minuteHeight)
                                        radius: radii.md
                                        readonly property color eventColor: modelData.colorHint && modelData.colorHint.length ? modelData.colorHint : colors.accent
                                        color: Qt.rgba(eventColor.r, eventColor.g, eventColor.b, 0.18)
                                        border.color: eventColor
                                        border.width: 1

                                        Column {
                                            anchors.fill: parent
                                            anchors.margins: gaps.g8
                                            spacing: gaps.g4

                                            Text {
                                                text: {
                                                    var startLabel = modelData.startTimeLabel || ""
                                                    var endLabel = modelData.endTimeLabel || ""
                                                    if (startLabel.length && endLabel.length)
                                                        return startLabel + " – " + endLabel
                                                    return startLabel
                                                }
                                                font.pixelSize: typeScale.xs
                                                font.weight: typeScale.weightMedium
                                                font.family: fonts.body
                                                color: colors.text2
                                                renderType: Text.NativeRendering
                                            }

                                            Text {
                                                text: modelData.title
                                                font.pixelSize: typeScale.sm
                                                font.weight: typeScale.weightMedium
                                                font.family: fonts.heading
                                                color: colors.text
                                                elide: Text.ElideRight
                                                renderType: Text.NativeRendering
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        TapHandler {
                            acceptedDevices: PointerDevice.Mouse
                            gesturePolicy: TapHandler.DragThreshold
                            onDoubleTapped: root.daySelected(dayIso)
                        }
                    }
                }
            }
        }

        ScrollIndicator.vertical: ScrollIndicator { }
    }

    function rebuild() {
        weekStartIso = weekStart(anchorIso)
        var rawEvents = planner.weekEvents(weekStartIso)
        eventsByDay = []
        allDayByDay = []
        var earliest = 24 * 60
        var latest = 0
        for (var i = 0; i < 7; ++i) {
            eventsByDay.push([])
            allDayByDay.push([])
        }
        for (var j = 0; j < rawEvents.length; ++j) {
            var event = rawEvents[j]
            var dayIndex = event.dayIndex || 0
            if (dayIndex < 0 || dayIndex >= 7)
                continue
            if (event.allDay) {
                allDayByDay[dayIndex].push(event)
            } else {
                event.startMinutes = event.startMinutes || 0
                event.duration = event.duration || 60
                event.endMinutes = event.startMinutes + event.duration
                earliest = Math.min(earliest, event.startMinutes)
                latest = Math.max(latest, event.endMinutes)
                eventsByDay[dayIndex].push(event)
            }
        }
        for (var d = 0; d < eventsByDay.length; ++d) {
            var dayList = eventsByDay[d]
            dayList.sort(function(a, b) { return a.startMinutes - b.startMinutes })
            var columns = []
            for (var idx = 0; idx < dayList.length; ++idx) {
                var ev = dayList[idx]
                var placed = false
                for (var c = 0; c < columns.length; ++c) {
                    var colEvents = columns[c]
                    var lastEvent = colEvents[colEvents.length - 1]
                    if (lastEvent.endMinutes <= ev.startMinutes) {
                        colEvents.push(ev)
                        ev.column = c
                        placed = true
                        break
                    }
                }
                if (!placed) {
                    columns.push([ev])
                    ev.column = columns.length - 1
                }
            }
            var count = Math.max(1, columns.length)
            for (var n = 0; n < dayList.length; ++n) {
                dayList[n].columnCount = count
            }
        }

        if (earliest === 24 * 60 && latest === 0) {
            startHour = 8
            endHour = 20
        } else {
            startHour = Math.max(6, Math.floor(earliest / 60))
            endHour = Math.min(23, Math.ceil(latest / 60))
            if (endHour - startHour < 4)
                endHour = Math.min(23, startHour + 4)
        }
    }

    function weekStart(iso) {
        var date = iso.length > 0 ? new Date(iso) : new Date()
        var diff = weekStartSetting === "sunday" ? date.getDay() : (date.getDay() + 6) % 7
        date.setDate(date.getDate() - diff)
        return Qt.formatDate(date, "yyyy-MM-dd")
    }

    function isoForDay(index) {
        if (weekStartIso.length === 0)
            return ""
        var startDate = new Date(weekStartIso)
        startDate.setDate(startDate.getDate() + index)
        return Qt.formatDate(startDate, "yyyy-MM-dd")
    }

    Component.onCompleted: {
        updateWeekdayLabels()
        rebuild()
    }

    onAnchorIsoChanged: rebuild()

    Connections {
        target: planner
        function onSelectedDateChanged() {
            root.anchorIso = planner.selectedDate
            root.rebuild()
        }
        function onEventsChanged() {
            root.rebuild()
        }
        function onOnlyOpenChanged() {
            root.rebuild()
        }
    }

    function updateWeekdayLabels() {
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
}
