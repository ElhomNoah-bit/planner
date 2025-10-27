import QtQuick
import QtQuick.Controls
import styles 1.0 as Styles

Control {
    id: pill
    property string label: ""
    property string subjectId: ""
    property color chipColor: Styles.ThemeStore.colors.accent
    property bool active: false
    signal toggled()

    implicitHeight: 32
    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var gap: theme ? theme.gap : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var typeScale: theme ? theme.type : null

    padding: gap ? gap.g12 : 12

    background: Rectangle {
        id: backdrop
        radius: radii ? radii.xl : 20
        color: pill.active
            ? colors ? colors.accentBg : Qt.rgba(pill.chipColor.r, pill.chipColor.g, pill.chipColor.b, 0.12)
            : colors ? colors.hover : Qt.rgba(1, 1, 1, 0.08)
        border.color: pill.active ? pill.chipColor : (colors ? colors.divider : Qt.rgba(1, 1, 1, 0.18))
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
            font.pixelSize: typeScale ? typeScale.sm : 12
            font.weight: pill.active
                ? (typeScale ? typeScale.weightBold : Font.DemiBold)
                : (typeScale ? typeScale.weightMedium : Font.Medium)
            font.family: Styles.ThemeStore.fonts.uiFallback
            color: pill.active ? pill.chipColor : (colors ? colors.text : "#F2F5F9")
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
            color: colors ? colors.hover : Qt.rgba(1, 1, 1, 0.12)
        }
    }

    TapHandler {
        onTapped: pill.toggled()
    }
}
