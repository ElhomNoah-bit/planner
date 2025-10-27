import QtQuick
import NoahPlanner 1.0
import "../styles" as Styles

Rectangle {
    id: chip
    property string label: ""
    property color subjectColor: accentColor
    property bool muted: false

    radius: 14
    height: 26
    readonly property color baseColor: muted ? Qt.rgba(1, 1, 1, 0.1) : chipBackground
    color: hover.hovered ? Qt.lighter(baseColor, 1.15) : baseColor
    border.color: Qt.rgba(1, 1, 1, 0.04)
    border.width: 1
    antialiasing: true

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var typeScale: theme ? theme.type : null

    readonly property color accentColor: colors ? colors.tint : "#0A84FF"
    readonly property color chipBackground: colors ? colors.chipBg : Qt.rgba(0, 0, 0, 0.1)
    readonly property color textColor: colors ? colors.chipFg : "#FFFFFF"
    readonly property string fontFamily: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
    readonly property int fontSize: typeScale ? typeScale.eventChipSize : 12
    readonly property int fontWeight: typeScale ? typeScale.eventChipWeight : Font.DemiBold

    Row {
        id: row
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6
        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: chip.subjectColor
        }
        Text {
            text: chip.label
            color: textColor
            font.pixelSize: fontSize
            font.weight: fontWeight
            font.family: fontFamily
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
    }

    HoverHandler {
        id: hover
    }

    Behavior on color {
        NumberAnimation { duration: 180; easing.type: Easing.InOutCubic }
    }

}
