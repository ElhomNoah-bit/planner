import QtQuick
import QtQuick.Controls
import NoahPlanner 1.0
import "../styles" as Styles

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

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var space: theme ? theme.space : null
    readonly property var typeScale: theme ? theme.type : null

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
        radius: (theme && theme.radii) ? theme.radii.lg : 16
        Column {
            anchors.fill: parent
            anchors.margins: space ? space.gap24 : 24
            spacing: space ? space.gap16 : 16
            Text {
                text: qsTr("Fokus-Timer")
                font.pixelSize: typeScale ? typeScale.lg : 20
                font.weight: typeScale ? typeScale.weightBold : Font.DemiBold
                font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                color: colors ? colors.text : "#FFFFFF"
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
                    ctx.strokeStyle = colors ? colors.tint : "#0A84FF"
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
                font.pixelSize: typeScale ? typeScale.display : 40
                font.weight: typeScale ? typeScale.weightBold : Font.DemiBold
                font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                color: colors ? colors.text : "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Row {
                spacing: space ? space.gap12 : 12
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
