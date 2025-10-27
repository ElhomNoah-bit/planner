import QtQuick
import styles 1.0 as Styles

Item {
    id: root
    property string isoDate: ""
    property bool inMonth: true
    property bool selected: false
    property bool isToday: false
    property var events: []
    property int maxVisible: 2
    signal activated(string isoDate)

    implicitWidth: 152
    implicitHeight: 120

    property var dateObject: isoDate.length > 0 ? new Date(isoDate) : new Date()
    readonly property int dayNumber: dateObject.getDate()

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var typeScale: theme ? theme.type : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var gap: theme ? theme.gap : null

    readonly property int dateSize: typeScale ? typeScale.dateSize : 12
    readonly property int dateWeight: typeScale ? typeScale.weightMedium : Font.Medium
    readonly property color accentColor: colors ? colors.accent : "#0A84FF"
    readonly property color bgColor: root.selected
        ? (colors ? colors.accentBg : Qt.rgba(0.04, 0.35, 0.84, 0.18))
        : (colors ? colors.cardBg : Qt.rgba(0, 0, 0, 0.25))

    Rectangle {
        id: backdrop
        anchors.fill: parent
        radius: radii ? radii.lg : 16
        color: hoverArea.containsMouse && !root.selected
            ? (colors ? colors.hover : Qt.rgba(1, 1, 1, 0.1))
            : bgColor
        border.color: root.selected ? accentColor : (colors ? colors.divider : Qt.rgba(1, 1, 1, 0.12))
        border.width: root.selected ? 1 : 1
        opacity: root.inMonth ? 1 : 0.45
        Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
        Behavior on border.color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
    }

    Item {
        id: dayHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: gap ? gap.g12 : 12
        height: 28

        Rectangle {
            id: dayHalo
            width: 20
            height: 20
            radius: 10
            anchors.top: parent.top
            anchors.right: parent.right
            color: root.isToday ? (colors ? colors.accentBg : Qt.rgba(0.04, 0.35, 0.84, 0.18)) : "transparent"
            border.color: root.isToday ? accentColor : "transparent"
            border.width: root.isToday ? 1 : 0
        }

        Text {
            anchors.right: dayHalo.right
            anchors.verticalCenter: dayHalo.verticalCenter
            text: root.dayNumber
            font.pixelSize: dateSize
            font.weight: dateWeight
            font.family: Styles.ThemeStore.fonts.uiFallback
            color: root.isToday
                ? (colors ? colors.accent : "#0A84FF")
                : (root.inMonth ? (colors ? colors.text : "#F2F5F9") : (colors ? colors.text2 : "#B7C0CC"))
            renderType: Text.NativeRendering
        }
    }

    Column {
        id: list
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: gap ? gap.g12 : 12
        anchors.topMargin: gap ? gap.g24 : 24
        spacing: gap ? gap.g8 : 8
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
            subjectColor: baseAccent
            width: list.width
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated(root.isoDate)
    }

    property var visibleEvents: (events || []).slice(0, maxVisible)
    property int extraCount: Math.max(0, (events || []).length - maxVisible)
}
