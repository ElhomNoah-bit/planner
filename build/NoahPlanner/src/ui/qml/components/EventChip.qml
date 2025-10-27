import QtQuick
import NoahPlanner 1.0 as NP

Rectangle {
    id: chip
    property string label: ""
    property color subjectColor: NP.ThemeStore.accent
    property bool muted: false

    radius: 14
    height: 26
    readonly property color baseColor: muted ? Qt.rgba(1, 1, 1, 0.1) : NP.ThemeStore.chipBg
    color: hover.hovered ? Qt.lighter(baseColor, 1.15) : baseColor
    border.color: Qt.rgba(1, 1, 1, 0.04)
    border.width: 1
    antialiasing: true

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
            color: NP.ThemeStore.text
            font.pixelSize: NP.ThemeStore.typography.eventChipSize
            font.weight: NP.ThemeStore.typography.eventChipWeight
            font.preferredFamilies: NP.ThemeStore.fonts.stack
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
