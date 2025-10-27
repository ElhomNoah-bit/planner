import QtQuick
import QtQuick.Controls
import NoahPlanner 1.0 as NP

Control {
    id: pill
    property string label: ""
    property string subjectId: ""
    property color chipColor: NP.ThemeStore.accent
    property bool active: false
    signal toggled()

    implicitHeight: 32
    padding: 12

    background: Rectangle {
        id: backdrop
        radius: NP.ThemeStore.radii.xl
        color: pill.active ? Qt.rgba(0.04, 0.35, 0.84, 0.2) : Qt.rgba(1, 1, 1, NP.ThemeStore.dark ? 0.08 : 0.12)
        border.color: pill.active ? NP.ThemeStore.accent : NP.ThemeStore.border
        border.width: 1
    }

    contentItem: Row {
        spacing: 8
        anchors.centerIn: parent
        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: pill.chipColor
        }
        Text {
            id: labelText
            text: pill.label
            font.pixelSize: 13
            font.weight: pill.active ? Font.DemiBold : Font.Medium
            font.family: NP.ThemeStore.defaultFontFamily
            color: pill.active ? NP.ThemeStore.accent : NP.ThemeStore.text
        }
    }

    HoverHandler {
        id: hover
    }

    states: State {
        name: "hover"
        when: hover.hovered && !pill.active
        PropertyChanges {
            target: backdrop
            color: Qt.rgba(1, 1, 1, NP.ThemeStore.dark ? 0.12 : 0.18)
        }
    }

    TapHandler {
        onTapped: pill.toggled()
    }
}
