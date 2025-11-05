import QtQuick
import QtQuick.Controls
import Styles 1.0 as Styles

GlassPanel {
    id: toast
    property string message: ""
    property int durationMs: 2000
    property alias running: timer.running

    readonly property QtObject radii: Styles.ThemeStore.radii
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject colors: Styles.ThemeStore.colors

    radius: radii.md
    padding: gaps.g16
    opacity: visible ? 1 : 0

    Behavior on opacity {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }

    Text {
        anchors.centerIn: parent
        text: toast.message
        font.pixelSize: typeScale.md
        font.family: Styles.ThemeStore.fonts.uiFallback
        color: colors.text
        renderType: Text.NativeRendering
    }

    Timer {
        id: timer
        interval: toast.durationMs
        repeat: false
        onTriggered: toast.visible = false
    }

    onVisibleChanged: {
        if (visible) {
            timer.restart()
        } else {
            timer.stop()
        }
    }
}
