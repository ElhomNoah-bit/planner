import QtQuick
import Qt5Compat.GraphicalEffects
import NoahPlanner 1.0 as NP

Item {
    id: root
    property real radius: NP.ThemeStore.radii.lg
    property real padding: NP.ThemeStore.spacing.gap16
    property bool blurEnabled: true
    property color tint: NP.ThemeStore.panel
    property color stroke: NP.ThemeStore.border
    default property alias contentData: content.data

    Rectangle {
        id: backdrop
        anchors.fill: parent
        radius: root.radius
        color: root.tint
        border.color: root.stroke
        border.width: 1
        layer.enabled: root.blurEnabled
        layer.effect: FastBlur {
            radius: NP.ThemeStore.blur.medium
            transparentBorder: true
        }
    }

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
