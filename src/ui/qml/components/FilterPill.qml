import QtQuick
import QtQuick.Controls
import "../styles" as Styles

Control {
    id: pill
    property string label: ""
    property string subjectId: ""
    property color chipColor: (Styles.ThemeStore && Styles.ThemeStore.colors) ? Styles.ThemeStore.colors.tint : "#0A84FF"
    property bool active: false
    signal toggled()

    implicitHeight: 32
    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var space: theme ? theme.space : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var typeScale: theme ? theme.type : null

    padding: space ? space.gap12 : 12

    background: Rectangle {
        id: backdrop
        radius: radii ? radii.xl : 22
        color: pill.active
            ? Qt.rgba(pill.chipColor.r, pill.chipColor.g, pill.chipColor.b, 0.22)
            : Qt.rgba(1, 1, 1, theme ? theme.glassBack : 0.12)
        border.color: pill.active
            ? pill.chipColor
            : (colors ? colors.divider : Qt.rgba(1, 1, 1, 0.18))
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
            font.pixelSize: typeScale ? typeScale.sm : 13
            font.weight: pill.active
                ? (typeScale ? typeScale.weightBold : Font.DemiBold)
                : (typeScale ? typeScale.weightMedium : Font.Medium)
            font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
            color: pill.active
                ? pill.chipColor
                : (colors ? colors.text : "#FFFFFF")
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
            color: Qt.rgba(1, 1, 1, Math.min(1.0, (theme ? theme.glassBack : 0.12) + 0.04))
        }
    }

    TapHandler {
        onTapped: pill.toggled()
    }
}
