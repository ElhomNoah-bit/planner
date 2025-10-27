import QtQuick
import QtQuick.Controls
import styles 1.0 as Styles

Item {
    id: host
    anchors.fill: parent
    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var gap: theme ? theme.gap : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var typeScale: theme ? theme.type : null

    property int margin: gap ? gap.g16 : 16

    function show(msg, ms) {
        textItem.text = msg
        wrapper.visible = true
        timer.interval = ms || 2000
        timer.restart()
    }

    Rectangle {
        id: wrapper
        visible: false
        opacity: 0
        radius: radii ? radii.lg : 16
        color: colors ? colors.cardGlass : "#111827CC"
        border.color: colors ? colors.divider : Qt.rgba(1, 1, 1, 0.22)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: host.margin
        width: textItem.implicitWidth + (gap ? gap.g24 : 24)
        height: textItem.implicitHeight + (gap ? gap.g24 : 24)

        Behavior on opacity {
            NumberAnimation {
                duration: 160
            }
        }

        states: [
            State {
                name: "hidden"
                when: !wrapper.visible
                PropertyChanges {
                    target: wrapper
                    opacity: 0
                }
            },
            State {
                name: "shown"
                when: wrapper.visible
                PropertyChanges {
                    target: wrapper
                    opacity: 1
                }
            }
        ]

        Text {
            id: textItem
            anchors.centerIn: parent
            color: colors ? colors.text : "#F2F5F9"
            font.pixelSize: typeScale ? typeScale.sm : 12
            font.family: Styles.ThemeStore.fonts.uiFallback
            wrapMode: Text.Wrap
            renderType: Text.NativeRendering
        }
    }

    Timer {
        id: timer
        onTriggered: wrapper.visible = false
    }

    Connections {
        target: PlannerBackend
        function onToastRequested(message) {
            host.show(message)
        }
    }
}
