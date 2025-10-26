import QtQuick
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner 1.0 as NP

Item {
    id: root
    property string anchorIso: PlannerBackend.selectedDate
    property string weekStartIso: ""
    property var events: []
    property var eventsByDay: []
    property int startHour: 8
    property int endHour: 20
    property real minuteHeight: 1.1
    signal daySelected(string iso)

    readonly property real timelineHeight: (endHour - startHour) * 60 * minuteHeight
    readonly property var weekdayNames: [qsTr("Mo"), qsTr("Di"), qsTr("Mi"), qsTr("Do"), qsTr("Fr"), qsTr("Sa"), qsTr("So")]

    Rectangle {
        anchors.fill: parent
        radius: NP.ThemeStore.radii.lg
        color: Qt.rgba(1, 1, 1, NP.ThemeStore.dark ? 0.03 : 0.05)
        border.color: Qt.rgba(1, 1, 1, 0.06)
        border.width: 1
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: timelineHeight + 120
        clip: true

        Item {
            id: content
            width: parent.width
            height: timelineHeight + 120

            Row {
                id: row
                anchors.fill: parent
                anchors.margins: 16
                spacing: NP.ThemeStore.spacing.gap12

                Column {
                    id: timeAxis
                    width: 44
                    spacing: 0
                    Repeater {
                        model: endHour - startHour + 1
                        delegate: Item {
                            width: parent.width
                            height: 60 * minuteHeight
                            Text {
                                anchors.right: parent.right
                                anchors.rightMargin: 4
                                anchors.verticalCenter: parent.verticalCenter
                                text: (startHour + index) + ":00"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                font.preferredFamilies: NP.ThemeStore.fonts.stack
                                color: NP.ThemeStore.muted
                            }
                        }
                    }
                }

                Repeater {
                    model: 7
                    delegate: Item {
                        width: (content.width - timeAxis.width - row.spacing * 6) / 7
                        height: content.height
                        property var dayEvents: root.eventsByDay.length > index ? root.eventsByDay[index] : []
                        property string dayIso: root.isoForDay(index)

                        Column {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 4
                            Text {
                                text: root.weekdayNames[index]
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                font.preferredFamilies: NP.ThemeStore.fonts.stack
                                color: NP.ThemeStore.muted
                            }
                            Text {
                                text: dayIso ? dayIso.split("-")[2] : ""
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                font.preferredFamilies: NP.ThemeStore.fonts.stack
                                color: NP.ThemeStore.text
                            }
                        }

                        Item {
                            id: timeline
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: 44
                            height: root.timelineHeight

                            Rectangle {
                                anchors.fill: parent
                                radius: 12
                                color: Qt.rgba(1, 1, 1, 0.02)
                                border.color: Qt.rgba(1, 1, 1, 0.05)
                                border.width: 1
                            }

                            Repeater {
                                model: dayEvents
                                delegate: Rectangle {
                                    width: timeline.width - 10
                                    x: 5
                                    y: Math.max(0, (modelData.startMinutes - root.startHour * 60) * root.minuteHeight)
                                    height: Math.max(36, modelData.duration * root.minuteHeight)
                                    radius: 16
                                    readonly property color eventColor: modelData.color || NP.ThemeStore.accent
                                    color: Qt.rgba(eventColor.r, eventColor.g, eventColor.b, 0.22)
                                    border.color: eventColor
                                    border.width: 1
                                    Text {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.right: parent.right
                                        anchors.rightMargin: 12
                                        text: modelData.title
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        font.preferredFamilies: NP.ThemeStore.fonts.stack
                                        color: NP.ThemeStore.text
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            onDoubleClicked: root.daySelected(dayIso)
                        }
                    }
                }
            }
        }
    }

    function rebuild() {
        weekStartIso = weekStart(anchorIso)
        events = PlannerBackend.weekEvents(weekStartIso)
        eventsByDay = []
        for (var i = 0; i < 7; ++i) {
            eventsByDay.push([])
        }
        for (var j = 0; j < events.length; ++j) {
            var event = events[j]
            var dayIndex = event.dayIndex || 0
            if (dayIndex >= 0 && dayIndex < eventsByDay.length) {
                eventsByDay[dayIndex].push(event)
            }
        }
    }

    function weekStart(iso) {
        var date = iso.length > 0 ? new Date(iso) : new Date()
        var diff = (date.getDay() + 6) % 7
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

    Component.onCompleted: rebuild()

    onAnchorIsoChanged: rebuild()

    Connections {
        target: PlannerBackend
        function onSelectedDateChanged() {
            root.anchorIso = PlannerBackend.selectedDate
            root.rebuild()
        }
        function onFiltersChanged() {
            root.rebuild()
        }
        function onTasksChanged() {
            root.rebuild()
        }
    }
}
