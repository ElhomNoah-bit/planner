import QtQuick
import QtQuick.Controls
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Item {
    id: overlay
    property bool open: false
    property int minutes: 25
    property int remainingSeconds: minutes * 60
    property bool running: false
    signal closed()
    signal finished()

    anchors.fill: parent
    visible: open
    opacity: open ? 1 : 0
    z: 100

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject radii: Styles.ThemeStore.radii

    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
    }

    GlassPanel {
        id: panel
        width: 320
        height: 380
        anchors.centerIn: parent
        radius: radii.lg
        Column {
            anchors.fill: parent
            anchors.margins: gaps.g24
            spacing: gaps.g16
            Text {
                text: qsTr("Fokus-Timer")
                font.pixelSize: typeScale.lg
                font.weight: typeScale.weightMedium
                font.family: Styles.ThemeStore.fonts.uiFallback
                color: colors.text
                renderType: Text.NativeRendering
            }
            Canvas {
                id: ring
                width: 200
                height: 200
                anchors.horizontalCenter: parent.horizontalCenter
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.translate(width / 2, height / 2)
                    ctx.rotate(-Math.PI / 2)
                    var radius = 90
                    ctx.lineWidth = 12
                    ctx.strokeStyle = "rgba(255,255,255,0.12)"
                    ctx.beginPath()
                    ctx.arc(0, 0, radius, 0, Math.PI * 2)
                    ctx.stroke()
                    var total = Math.max(1, minutes * 60)
                    var progress = Math.max(0, remainingSeconds) / total
                    ctx.strokeStyle = colors.accent
                    ctx.beginPath()
                    ctx.arc(0, 0, radius, 0, Math.PI * 2 * progress)
                    ctx.stroke()
                }
                Connections {
                    target: overlay
                    function onRemainingSecondsChanged() { ring.requestPaint() }
                    function onMinutesChanged() { ring.requestPaint() }
                }
            }
            Text {
                text: Math.floor(remainingSeconds / 60) + ":" + ("0" + Math.floor(remainingSeconds % 60)).slice(-2)
                font.pixelSize: typeScale.monthTitle
                font.weight: typeScale.weightBold
                font.family: Styles.ThemeStore.fonts.uiFallback
                color: colors.text
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                renderType: Text.NativeRendering
            }
            Row {
                spacing: gaps.g12
                anchors.horizontalCenter: parent.horizontalCenter
                PillButton {
                    text: overlay.running ? qsTr("Pause") : qsTr("Start")
                    kind: "primary"
                    onClicked: overlay.running = !overlay.running
                }
                PillButton {
                    text: qsTr("Schließen")
                    kind: "ghost"
                    onClicked: {
                        overlay.open = false
                        overlay.closed()
                    }
                }
            }
        }
    }

    Timer {
        id: timer
        interval: 1000
        repeat: true
        running: overlay.running && overlay.open
        onTriggered: {
            if (overlay.remainingSeconds > 0) {
                overlay.remainingSeconds -= 1
            } else {
                overlay.running = false
                overlay.open = false
                overlay.closed()
                overlay.finished()
            }
        }
    }

    onOpenChanged: {
        if (open) {
            remainingSeconds = minutes * 60
            running = false
            ring.requestPaint()
        } else {
            timer.stop()
        }
    }
}
