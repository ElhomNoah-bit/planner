import QtQuick
import styles 1.0 as Styles

Rectangle {
    id: chip
    property string label: ""
    property color subjectColor: Styles.ThemeStore.colors.accent
    property bool muted: false

    radius: 10
    implicitHeight: 20
    implicitWidth: Math.max(60, labelText.implicitWidth + 2 * (gap ? gap.g12 : 12))
    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var typeScale: theme ? theme.type : null
    readonly property var gap: theme ? theme.gap : null

    readonly property color baseColor: muted
        ? (colors ? colors.hover : Qt.rgba(1, 1, 1, 0.08))
        : (colors ? colors.cardBg : Qt.rgba(0, 0, 0, 0.25))
    color: hover.hovered ? (colors ? colors.hover : Qt.lighter(baseColor, 1.1)) : baseColor
    border.color: muted ? (colors ? colors.divider : Qt.rgba(1, 1, 1, 0.1)) : subjectColor
    border.width: muted ? 0 : 1
    antialiasing: true

    Row {
        id: row
        anchors.fill: parent
        anchors.leftMargin: gap ? gap.g8 : 6
        anchors.rightMargin: gap ? gap.g12 : 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: gap ? gap.g8 : 6
        Rectangle {
            width: 6
            height: 6
            radius: 3
            color: chip.subjectColor
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            id: labelText
            text: chip.label
            color: colors ? colors.text : "#F2F5F9"
            font.pixelSize: typeScale ? typeScale.eventChipSize : 11
            font.weight: typeScale ? typeScale.weightMedium : Font.Medium
            font.family: Styles.ThemeStore.fonts.uiFallback
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
        }
    }

    HoverHandler {
        id: hover
    }

    Behavior on color {
        NumberAnimation { duration: 180; easing.type: Easing.InOutCubic }
    }

}
