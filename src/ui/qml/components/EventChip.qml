import QtQuick
import "styles" as Styles

Rectangle {
    id: chip
    property string label: ""
    property color subjectColor: Styles.ThemeStore.colors.accentBg
    property bool muted: false

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject gaps: Styles.ThemeStore.gap

    implicitHeight: 22
    implicitWidth: Math.max(60, labelText.implicitWidth + 16)
    radius: 11
    color: muted ? colors.hover : subjectColor
    border.width: 0

    Row {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: gaps.g8

        Rectangle {
            width: 6
            height: 6
            radius: 3
            color: muted ? colors.divider : colors.accent
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: labelText
            text: chip.label
            color: colors.text
            font.pixelSize: typeScale.eventChipSize
            font.weight: typeScale.weightMedium
            font.family: Styles.ThemeStore.fonts.uiFallback
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: chip.radius
        color: colors.hover
        visible: hoverHandler.hovered
    }

    HoverHandler {
        id: hoverHandler
    }
}
