import QtQuick
import QtQuick.Controls
import NoahPlanner 1.0
import styles 1.0 as Styles

GlassPanel {
    id: toast
    property string message: ""
    property int durationMs: 2000
    property alias running: timer.running

    readonly property var theme: Styles.ThemeStore
    readonly property var radii: theme ? theme.radii : null
    readonly property var gap: theme ? theme.gap : null
    readonly property var typeScale: theme ? theme.type : null
    readonly property var colors: theme ? theme.colors : null

    radius: radii ? radii.md : 12
    padding: gap ? gap.g16 : 16
    opacity: visible ? 1 : 0

    Behavior on opacity {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }

    Text {
        anchors.centerIn: parent
        text: toast.message
        font.pixelSize: typeScale ? typeScale.md : 14
        font.family: Styles.ThemeStore.fonts.uiFallback
        color: colors ? colors.text : "#F2F5F9"
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
