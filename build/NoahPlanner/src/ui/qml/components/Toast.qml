import QtQuick
import QtQuick.Controls
import NoahPlanner 1.0
import NoahPlanner 1.0 as NP

GlassPanel {
    id: toast
    property string message: ""
    property int durationMs: 2000
    property alias running: timer.running

    radius: NP.ThemeStore.radii.md
    padding: 16
    opacity: visible ? 1 : 0

    Behavior on opacity {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }

    Text {
        anchors.centerIn: parent
        text: toast.message
        font.pixelSize: 14
        font.family: NP.ThemeStore.defaultFontFamily
        color: NP.ThemeStore.text
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
