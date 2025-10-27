import QtQuick
import QtQuick.Controls
import NoahPlanner.Styles as Styles

FocusScope {
    id: root
    property string isoDate: ""
    property bool inMonth: true
    property bool selected: false
    property bool isToday: false
    property var events: []
    property int maxVisible: 3
    readonly property var dateObject: isoDate.length > 0 ? new Date(isoDate) : new Date()
    readonly property int dayNumber: dateObject.getDate()
    readonly property bool hovered: hoverHandler.hovered
    property var visibleEvents: (events || []).slice(0, maxVisible)
    property int extraCount: Math.max(0, (events || []).length - maxVisible)
    readonly property color hoverFill: Qt.lighter(Styles.ThemeStore.colors.cardBg, 1.08)

    signal activated(string isoDate)
    signal contextCreateEvent(string isoDate)
    signal contextCreateTask(string isoDate)
    signal contextJumpToToday()

    implicitWidth: 152
    implicitHeight: 120

    Accessible.role: Accessible.Button
    Accessible.name: Qt.formatDate(dateObject, "dddd, dd. MMMM")

    Rectangle {
        id: backdrop
        anchors.fill: parent
        radius: Styles.ThemeStore.r12
        border.width: root.isToday ? 2 : 1
     border.color: root.isToday
            ? Styles.ThemeStore.colors.focus
            : (root.selected ? Styles.ThemeStore.colors.accent : Styles.ThemeStore.colors.divider)
     color: root.selected
         ? Styles.ThemeStore.colors.accentBg
         : (root.hovered ? hoverFill : Styles.ThemeStore.colors.cardBg)
        antialiasing: true

        Behavior on color {
            ColorAnimation { duration: 140; easing.type: Easing.InOutQuad }
        }
        Behavior on border.color {
            ColorAnimation { duration: 140; easing.type: Easing.InOutQuad }
        }
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

    Text {
        id: dayLabel
        text: root.dayNumber
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: Styles.ThemeStore.g12
        font.pixelSize: Styles.ThemeStore.type.sm + 2
        font.family: Styles.ThemeStore.fonts.heading
        font.weight: root.isToday ? Styles.ThemeStore.type.weightBold : Styles.ThemeStore.type.weightMedium
        color: root.inMonth ? Styles.ThemeStore.colors.text : Styles.ThemeStore.colors.text2
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
            subjectColor: Styles.ThemeStore.colors.accent
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.WithinBounds
        onTapped: root.activated(root.isoDate)
        onPressedChanged: if (pressed) root.forceActiveFocus()
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        gesturePolicy: TapHandler.WithinBounds
        onTapped: (eventPoint) => {
            if (!contextMenu.visible) {
                contextMenu.popup(eventPoint.scenePosition)
            }
        }
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

    Menu {
        id: contextMenu
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        MenuItem {
            text: qsTr("Neuer Termin an diesem Tag")
            onTriggered: root.contextCreateEvent(root.isoDate)
        }
        MenuItem {
            text: qsTr("Neue Aufgabe an diesem Tag")
            onTriggered: root.contextCreateTask(root.isoDate)
        }
        MenuSeparator {}
        MenuItem {
            text: qsTr("Zu heute springen")
            onTriggered: root.contextJumpToToday()
        }
    }
}
