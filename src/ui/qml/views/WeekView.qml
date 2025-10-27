import QtQuick
import QtQuick.Layouts
import NoahPlanner 1.0
import "styles" as Styles

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

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject radii: Styles.ThemeStore.radii

    Rectangle {
        anchors.fill: parent
        radius: radii.lg
        color: colors.cardBg
        border.width: 1
        border.color: colors.divider
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: timelineHeight + gaps.g24
        clip: true

        Item {
            id: content
            width: parent.width
            height: timelineHeight + gaps.g24

            Row {
                id: row
                anchors.fill: parent
                anchors.margins: gaps.g16
                spacing: gaps.g12

                Column {
                    id: timeAxis
                    width: 44
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
                                font.pixelSize: typeScale.xs
                                font.weight: typeScale.weightMedium
                                font.family: Styles.ThemeStore.fonts.uiFallback
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
                        width: (content.width - timeAxis.width - row.spacing * 6) / 7
                        height: content.height
                        property var dayEvents: root.eventsByDay.length > index ? root.eventsByDay[index] : []
                        property string dayIso: root.isoForDay(index)

                        Column {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: gaps.g4
                            Text {
                                text: root.weekdayNames[index]
                                font.pixelSize: typeScale.sm
                                font.weight: typeScale.weightMedium
                                font.family: Styles.ThemeStore.fonts.uiFallback
                                color: colors.text2
                                opacity: 0.7
                                renderType: Text.NativeRendering
                            }
                            Text {
                                text: dayIso ? dayIso.split("-")[2] : ""
                                font.pixelSize: typeScale.md
                                font.weight: typeScale.weightBold
                                font.family: Styles.ThemeStore.fonts.uiFallback
                                color: colors.text
                                renderType: Text.NativeRendering
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
                                radius: radii.md
                                color: colors.cardGlass
                                border.width: 1
                                border.color: colors.divider
                            }

                            Repeater {
                                model: dayEvents
                                delegate: Rectangle {
                                    width: timeline.width - 10
                                    x: 5
                                    y: Math.max(0, (modelData.startMinutes - root.startHour * 60) * root.minuteHeight)
                                    height: Math.max(36, modelData.duration * root.minuteHeight)
                                    radius: radii.lg
                                    readonly property color eventColor: modelData.color || colors.accent
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
                                        font.pixelSize: typeScale.sm
                                        font.weight: typeScale.weightMedium
                                        font.family: Styles.ThemeStore.fonts.uiFallback
                                        color: colors.text
                                        elide: Text.ElideRight
                                        renderType: Text.NativeRendering
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
