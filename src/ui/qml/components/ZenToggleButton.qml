import QtQuick
import QtQuick.Controls
import NoahPlanner.Styles as Styles

Rectangle {
    id: root
    property bool active: false
    signal toggled()

    implicitWidth: Styles.ThemeStore.layout.pillH
    implicitHeight: Styles.ThemeStore.layout.pillH
    radius: Styles.ThemeStore.r8
    color: active ? Styles.ThemeStore.colors.accentBg : "transparent"
    border.width: 1
    border.color: active ? Styles.ThemeStore.colors.accent : Styles.ThemeStore.colors.divider

    Behavior on color {
        ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
    }
    Behavior on border.color {
        ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
    }

    Text {
        anchors.centerIn: parent
        text: "◉"
        font.pixelSize: Styles.ThemeStore.type.lg
        font.family: Styles.ThemeStore.fonts.heading
        color: active ? Styles.ThemeStore.colors.accent : Styles.ThemeStore.colors.text2
        renderType: Text.NativeRendering

        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.InOutQuad }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Styles.ThemeStore.colors.hover
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
