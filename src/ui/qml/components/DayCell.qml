import QtQuick
import "styles" as Styles

FocusScope {
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

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject radii: Styles.ThemeStore.radii
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property color baseAccent: colors.accent
    readonly property color baseAccentBg: colors.accentBg

    readonly property var dateObject: isoDate.length > 0 ? new Date(isoDate) : new Date()
    readonly property int dayNumber: dateObject.getDate()

    Rectangle {
        id: backdrop
        anchors.fill: parent
        radius: radii.lg
        color: root.selected ? baseAccentBg : colors.cardBg
        border.width: 1
        border.color: root.selected ? baseAccent : colors.divider
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -1
        radius: radii.lg + 2
        color: "transparent"
        border.width: 1
        border.color: colors.focus
        visible: root.activeFocus
    }

    Rectangle {
        anchors.fill: parent
        radius: radii.lg
        color: colors.hover
        visible: hoverArea.containsMouse && !root.selected
    }

    Item {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: gaps.g12
        height: 24

        Rectangle {
            width: 8
            height: 8
            radius: 4
            anchors.top: parent.top
            anchors.right: parent.right
            color: baseAccentBg
            border.width: 1
            border.color: baseAccent
            visible: root.isToday
        }

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: root.dayNumber
            font.pixelSize: typeScale.dateSize
            font.weight: typeScale.weightMedium
            font.family: Styles.ThemeStore.fonts.uiFallback
            color: root.inMonth ? colors.text : colors.text2
            opacity: root.inMonth ? 1 : 0.6
            renderType: Text.NativeRendering
        }
    }

    Column {
        id: list
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: gaps.g12
        anchors.topMargin: gaps.g24
        spacing: gaps.g8

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
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated(root.isoDate)
        onPressed: root.forceActiveFocus()
    }

    property var visibleEvents: (events || []).slice(0, maxVisible)
    property int extraCount: Math.max(0, (events || []).length - maxVisible)

    Keys.onReturnPressed: root.activated(root.isoDate)
    Keys.onEnterPressed: root.activated(root.isoDate)
    Keys.onSpacePressed: root.activated(root.isoDate)
}
