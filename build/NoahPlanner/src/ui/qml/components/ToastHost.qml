import QtQuick
import NoahPlanner 1.0

Item {
    id: host
    anchors.fill: parent
    property string currentMessage: ""

    Toast {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32
        visible: currentMessage.length > 0
        message: currentMessage
        onVisibleChanged: {
            if (!visible) {
                host.currentMessage = ""
            }
        }
    }

    Connections {
        target: PlannerBackend
        function onToastRequested(message) {
            host.currentMessage = message
            toast.visible = true
        }
    }
}
