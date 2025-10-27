import QtQuick
import NoahPlanner.Styles as Styles

FocusScope {
    id: root
    property string isoDate: ""
    property bool inMonth: true
    property bool selected: false
    property bool isToday: false
    property var events: []
    property int maxVisible: 2
    readonly property var dateObject: isoDate.length > 0 ? new Date(isoDate) : new Date()
    readonly property int dayNumber: dateObject.getDate()
    readonly property bool hovered: hoverHandler.hovered
    property var visibleEvents: (events || []).slice(0, maxVisible)
    property int extraCount: Math.max(0, (events || []).length - maxVisible)

    signal activated(string isoDate)

    implicitWidth: 152
    implicitHeight: 120

    Rectangle {
        id: backdrop
        anchors.fill: parent
        radius: Styles.ThemeStore.r12
        border.width: 1
        border.color: root.selected ? Styles.ThemeStore.accent : Styles.ThemeStore.divider
        color: root.selected
               ? Styles.ThemeStore.accentBg
               : (root.hovered ? Styles.ThemeStore.hover : Styles.ThemeStore.cardBg)
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -1
        radius: Styles.ThemeStore.r12 + 2
        color: "transparent"
        border.width: 1
        border.color: Styles.ThemeStore.focus
        visible: root.activeFocus
        opacity: 0.9
    }

    Rectangle {
        width: 12
        height: 12
        radius: 6
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Styles.ThemeStore.g12
        color: "transparent"
        border.width: 2
        border.color: Styles.ThemeStore.focus
        visible: root.isToday
    }

    Text {
        id: dayLabel
        text: root.dayNumber
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: Styles.ThemeStore.g12
        font.pixelSize: Styles.ThemeStore.sm
        font.family: Styles.ThemeStore.fontFamily
        color: root.inMonth ? Styles.ThemeStore.text : Styles.ThemeStore.text2
        opacity: root.inMonth ? 1 : 0.6
        renderType: Text.NativeRendering
    }

    Column {
        id: list
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: dayLabel.bottom
        anchors.topMargin: Styles.ThemeStore.g12
        anchors.leftMargin: Styles.ThemeStore.g12
        anchors.rightMargin: Styles.ThemeStore.g12
        anchors.bottomMargin: Styles.ThemeStore.g12
        spacing: Styles.ThemeStore.g8

        Repeater {
            model: root.visibleEvents
            delegate: EventChip {
                width: list.width
                label: modelData.title
                subjectColor: modelData.color
            }
        }

        EventChip {
            width: list.width
            visible: root.extraCount > 0
            label: "+" + root.extraCount
            muted: true
            subjectColor: Styles.ThemeStore.accent
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.WithinBounds
        onTapped: root.activated(root.isoDate)
        onPressedChanged: if (pressed) root.forceActiveFocus()
    }

    HoverHandler {
        id: hoverHandler
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            event.accepted = true
            root.activated(root.isoDate)
        }
    }
}
