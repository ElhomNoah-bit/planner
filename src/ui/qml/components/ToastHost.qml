import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: host
    anchors.fill: parent
    property int margin: 16

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
        radius: 12
        color: "#111827CC"
        border.color: "#FFFFFF22"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: host.margin
        width: textItem.implicitWidth + 24
        height: textItem.implicitHeight + 24

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
            color: "white"
            font.pixelSize: 13
            wrapMode: Text.Wrap
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
