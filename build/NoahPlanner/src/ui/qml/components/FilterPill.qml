import QtQuick
import QtQuick.Controls
import "styles" as Styles

Control {
    id: pill
    property string label: ""
    property string subjectId: ""
    property color chipColor: Styles.ThemeStore.colors.accent
    property bool active: false
    signal toggled()

    implicitHeight: Math.max(Styles.ThemeStore.layout.pillH, 36)
    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject radii: Styles.ThemeStore.radii
    readonly property QtObject typeScale: Styles.ThemeStore.type

    padding: gaps.g12

    background: Rectangle {
        id: backdrop
        radius: radii.xl
        color: pill.active ? colors.accentBg : colors.hover
        border.color: pill.active ? pill.chipColor : colors.divider
        border.width: 1
    }

    contentItem: Row {
        spacing: gaps.g8
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
            font.pixelSize: typeScale.sm
            font.weight: pill.active ? typeScale.weightBold : typeScale.weightMedium
            font.family: Styles.ThemeStore.fonts.uiFallback
            color: pill.active ? pill.chipColor : colors.text
            renderType: Text.NativeRendering
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
            color: colors.hover
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: pill.toggled()
    }
}
