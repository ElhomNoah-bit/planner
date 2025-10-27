import QtQuick
import NoahPlanner 1.0 as NP

Item {
    id: root
    property string isoDate: ""
    property bool inMonth: true
    property bool selected: false
    property bool isToday: false
    property var events: []
    property int maxVisible: 3
    signal activated(string isoDate)

    implicitWidth: 152
    implicitHeight: 120

    property var dateObject: isoDate.length > 0 ? new Date(isoDate) : new Date()
    readonly property int dayNumber: dateObject.getDate()

    Rectangle {
        anchors.fill: parent
        radius: NP.ThemeStore.radii.md
        color: Qt.rgba(1, 1, 1, selected ? 0.04 : 0)
        border.color: selected ? NP.ThemeStore.accent : Qt.rgba(1, 1, 1, 0.02)
        border.width: selected ? 1 : 0
    }

    Rectangle {
        id: dayBadge
        visible: selected
        radius: NP.ThemeStore.radii.md
        height: 26
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8
        color: Qt.rgba(0.04, 0.35, 0.84, 0.18)
        border.color: NP.ThemeStore.accent
        border.width: 1
        width: label.implicitWidth + 16
        Text {
            id: label
            anchors.centerIn: parent
            text: root.dayNumber
            font.pixelSize: NP.ThemeStore.typography.dateSize
            font.weight: NP.ThemeStore.typography.dateWeight
            font.preferredFamilies: NP.ThemeStore.fonts.stack
            color: NP.ThemeStore.accent
        }
    }

    Text {
        id: dayText
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8
        visible: !selected
        text: root.dayNumber
        font.pixelSize: NP.ThemeStore.typography.dateSize
        font.weight: NP.ThemeStore.typography.dateWeight
        font.preferredFamilies: NP.ThemeStore.fonts.stack
        color: root.isToday ? NP.ThemeStore.accent : (root.inMonth ? NP.ThemeStore.text : NP.ThemeStore.muted)
    }

    Column {
        id: list
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8
        anchors.topMargin: 38
        spacing: 6
        Repeater {
            model: visibleEvents
            delegate: EventChip {
                label: modelData.title
                subjectColor: modelData.color
                width: list.width
            }
        }
        EventChip {
            visible: extraCount > 0
            label: "+" + extraCount
            muted: true
            subjectColor: NP.ThemeStore.accent
            width: list.width
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated(root.isoDate)
    }

    property var visibleEvents: (events || []).slice(0, maxVisible)
    property int extraCount: Math.max(0, (events || []).length - maxVisible)
}
