import QtQuick
import "../styles" as Styles

Rectangle {
    id: chip
    property string label: ""
    property color subjectColor: accentColor
    property bool muted: false

    radius: 10
    height: 20
    implicitWidth: labelText.implicitWidth + 20
    readonly property color baseColor: muted ? Qt.rgba(1, 1, 1, 0.08) : chipBackground
    color: hover.hovered ? Qt.lighter(baseColor, 1.2) : baseColor
    border.color: muted ? Qt.rgba(1, 1, 1, 0.05) : subjectColor
    border.width: muted ? 0 : 1
    antialiasing: true

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var typeScale: theme ? theme.type : null

    readonly property color accentColor: colors ? colors.tint : "#0A84FF"
    readonly property color chipBackground: colors ? colors.chipBg : Qt.rgba(0, 0, 0, 0.18)
    readonly property color textColor: colors ? colors.chipFg : "#FFFFFF"
    readonly property string fontFamily: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
    readonly property int fontSize: typeScale ? typeScale.eventChipSize : 12
    readonly property int fontWeight: typeScale ? typeScale.eventChipWeight : Font.DemiBold

    Row {
        id: row
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6
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
            color: textColor
            font.pixelSize: fontSize
            font.weight: fontWeight
            font.family: fontFamily
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
