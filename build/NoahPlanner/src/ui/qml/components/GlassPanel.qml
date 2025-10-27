import QtQuick
import QtQuick.Effects
import NoahPlanner 1.0
import "../styles" as Styles

Item {
    id: root
    property real radius: baseRadius
    property real padding: basePadding
    property bool blurEnabled: true
    property color tint: baseTint
    property color stroke: baseStroke
    default property alias contentData: content.data

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var space: theme ? theme.space : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var surface: theme ? theme.surface : null
    readonly property var state: theme ? theme.state : null

    readonly property real baseRadius: radii ? radii.lg : 18
    readonly property real basePadding: space ? space.gap16 : 16
    readonly property color baseTint: surface ? surface.level1Glass : Qt.rgba(0, 0, 0, 0.1)
    readonly property color baseStroke: colors ? colors.divider : Qt.rgba(1, 1, 1, theme ? theme.glassBorder : 0.2)
    readonly property real baseBlur: 16

    Rectangle {
        id: backdrop
        anchors.fill: parent
        radius: root.radius
        color: root.tint
        border.color: root.stroke
        border.width: 1
        layer.enabled: root.blurEnabled
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: Math.min(root.baseBlur, 64)
            blur: 1.0
        }
    }

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
