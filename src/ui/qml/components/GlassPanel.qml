import QtQuick
import QtQuick.Effects
import Styles 1.0 as Styles

Item {
    id: root
    property real radius: baseRadius
    property real padding: basePadding
    property bool blurEnabled: true
    property color tint: baseTint
    property color stroke: baseStroke
    default property alias contentData: content.data

    implicitWidth: content.childrenRect.width + padding * 2
    implicitHeight: content.childrenRect.height + padding * 2

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var gap: theme ? theme.gap : null
    readonly property var radii: theme ? theme.radii : null

    readonly property real baseRadius: radii ? radii.lg : 16
    readonly property real basePadding: gap ? gap.g16 : 16
    readonly property color baseTint: colors ? colors.cardGlass : Qt.rgba(0, 0, 0, 0.45)
    readonly property color baseStroke: colors ? colors.divider : Qt.rgba(1, 1, 1, 0.2)
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
