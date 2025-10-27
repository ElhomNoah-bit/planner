import QtQuick
import QtQuick.Controls
import NoahPlanner.Styles as Styles

Item {
    id: host
    anchors.fill: parent
    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject radii: Styles.ThemeStore.radii
    readonly property QtObject typeScale: Styles.ThemeStore.type

    property int margin: gaps.g16

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
        radius: radii.lg
        color: colors.cardGlass
        border.color: colors.divider
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: host.margin
        width: textItem.implicitWidth + gaps.g24
        height: textItem.implicitHeight + gaps.g24

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
            color: colors.text
            font.pixelSize: typeScale.sm
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
