import QtQuick
import NoahPlanner.Styles as Styles

Rectangle {
    id: chip
    property string label: ""
    property color subjectColor: Styles.ThemeStore.accent
    property bool muted: false
    property bool overdue: false

    implicitHeight: 26
    implicitWidth: Math.max(72, labelText.implicitWidth + Styles.ThemeStore.g16)
    radius: Styles.ThemeStore.r12
    color: muted ? Styles.ThemeStore.cardAlt : Styles.ThemeStore.accentBg
    border.width: overdue ? 1 : 0
    border.color: overdue ? Styles.ThemeStore.danger : "transparent"

    Row {
        anchors.fill: parent
        anchors.leftMargin: Styles.ThemeStore.g12
        anchors.rightMargin: Styles.ThemeStore.g12
        spacing: Styles.ThemeStore.g8
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            width: 6
            height: 6
            radius: 3
            color: muted ? Styles.ThemeStore.divider : subjectColor
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: labelText
            text: chip.label
            color: Styles.ThemeStore.text
            font.pixelSize: Styles.ThemeStore.sm
            font.family: Styles.ThemeStore.fontFamily
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: chip.radius
        color: Styles.ThemeStore.hover
        visible: hoverHandler.hovered
        opacity: 0.2
    }

    HoverHandler {
        id: hoverHandler
    }
}
