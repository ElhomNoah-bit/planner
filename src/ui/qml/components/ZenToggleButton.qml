import QtQuick
import QtQuick.Controls
import QtQuick
import QtQuick.Layouts
import Styles 1.0
    id: root
    property bool active: false
    signal toggled()

    implicitWidth: Styles.ThemeStore.layout.pillH
    implicitWidth: ThemeStore.layout.pillH
    implicitHeight: ThemeStore.layout.pillH
    radius: ThemeStore.radiusLg
    color: active ? ThemeStore.colors.accentBg : "transparent"
    border.color: active ? ThemeStore.colors.accent : ThemeStore.colors.divider

    Behavior on color {
        ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
    }
    Behavior on border.color {
        ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
    }

    Text {
        anchors.centerIn: parent
        text: "◉"
        font.pixelSize: ThemeStore.type.lg
        font.family: ThemeStore.fonts.heading
        color: active ? ThemeStore.colors.accent : ThemeStore.colors.text2
        renderType: Text.NativeRendering

        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: ThemeStore.colors.hover
        visible: hoverHandler.hovered
        opacity: 0.2
    }

    HoverHandler {
        id: hoverHandler
    }

    TapHandler {
        onTapped: root.toggled()
    }

    ToolTip {
        visible: hoverHandler.hovered
        text: qsTr("Zen-Modus (Ctrl/Cmd+.)")
        delay: 500
    }
}
