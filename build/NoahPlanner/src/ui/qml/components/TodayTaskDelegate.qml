import QtQuick
import QtQuick.Controls
import NoahPlanner 1.0 as NP

Item {
    id: root
    property string title: ""
    property string goal: ""
    property int duration: 25
    property color subjectColor: NP.ThemeStore.accent
    property bool done: false
    signal toggled(bool done)
    signal startTimer(int minutes)

    implicitHeight: 68
    width: parent ? parent.width : 320

    Rectangle {
        id: container
        anchors.fill: parent
        radius: NP.ThemeStore.radii.md
        color: root.done ? Qt.rgba(0.04, 0.35, 0.84, 0.12) : Qt.rgba(1, 1, 1, NP.ThemeStore.dark ? 0.08 : 0.12)
        border.color: root.done ? NP.ThemeStore.accent : NP.ThemeStore.border
        border.width: 1
    }

    Row {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        Rectangle {
            id: checkbox
            width: 20
            height: 20
            radius: 10
            border.width: 2
            border.color: root.done ? NP.ThemeStore.accent : NP.ThemeStore.border
            color: root.done ? NP.ThemeStore.accent : Qt.rgba(0, 0, 0, 0)
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Behavior on border.color { ColorAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Text {
                anchors.centerIn: parent
                text: root.done ? "✓" : ""
                color: "#FFFFFF"
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
        }

        Column {
            width: Math.max(0, parent.width - timerPill.width - checkbox.width - 48)
            spacing: 6
            Text {
                text: root.title
                font.pixelSize: 15
                font.weight: Font.DemiBold
                font.family: NP.ThemeStore.defaultFontFamily
                color: NP.ThemeStore.text
                elide: Text.ElideRight
            }
            Text {
                text: root.goal
                font.pixelSize: NP.ThemeStore.typography.metaSize
                font.weight: NP.ThemeStore.typography.metaWeight
                font.family: NP.ThemeStore.defaultFontFamily
                color: NP.ThemeStore.muted
                elide: Text.ElideRight
            }
        }

        Rectangle {
            id: timerPill
            height: 30
            width: 60
            radius: 18
            color: Qt.rgba(1, 1, 1, NP.ThemeStore.dark ? 0.12 : 0.16)
            border.color: NP.ThemeStore.border
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter
            Text {
                anchors.centerIn: parent
                text: root.duration + qsTr("m")
                font.pixelSize: 13
                font.weight: Font.DemiBold
                font.family: NP.ThemeStore.defaultFontFamily
                color: NP.ThemeStore.text
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.startTimer(root.duration)
            }
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.toggled(!root.done)
    }
}
