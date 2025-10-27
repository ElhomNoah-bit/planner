import QtQuick
import QtQuick.Controls
import "../styles" as Styles

Item {
    id: root
    property string title: ""
    property string goal: ""
    property int duration: 25
    property color subjectColor: (Styles.ThemeStore && Styles.ThemeStore.colors) ? Styles.ThemeStore.colors.tint : "#0A84FF"
    property bool done: false
    signal toggled(bool done)
    signal startTimer(int minutes)

    implicitHeight: 68
    width: parent ? parent.width : 320

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var space: theme ? theme.space : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var typeScale: theme ? theme.type : null

    Rectangle {
        id: container
        anchors.fill: parent
        radius: radii ? radii.md : 14
        color: root.done
            ? Qt.rgba(0.04, 0.35, 0.84, 0.18)
            : Qt.rgba(1, 1, 1, theme ? theme.glassBack : 0.12)
        border.color: root.done
            ? (colors ? colors.tint : "#0A84FF")
            : (colors ? colors.divider : Qt.rgba(1, 1, 1, 0.18))
        border.width: 1
    }

    Row {
        anchors.fill: parent
        anchors.margins: space ? space.gap16 : 16
        spacing: space ? space.gap16 : 16

        Rectangle {
            id: checkbox
            width: 20
            height: 20
            radius: 10
            border.width: 2
            border.color: root.done ? (colors ? colors.tint : "#0A84FF") : (colors ? colors.divider : Qt.rgba(1, 1, 1, 0.2))
            color: root.done ? (colors ? colors.tint : "#0A84FF") : Qt.rgba(0, 0, 0, 0)
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
            spacing: space ? space.gap8 : 6
            Text {
                text: root.title
                font.pixelSize: typeScale ? typeScale.md : 15
                font.weight: typeScale ? typeScale.weightBold : Font.DemiBold
                font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                color: colors ? colors.text : "#FFFFFF"
                elide: Text.ElideRight
            }
            Text {
                text: root.goal
                font.pixelSize: typeScale ? typeScale.metaSize : 12
                font.weight: typeScale ? typeScale.metaWeight : Font.Normal
                font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                color: colors ? colors.textMuted : "#A0A0A0"
                elide: Text.ElideRight
            }
        }

        Rectangle {
            id: timerPill
            height: 30
            width: 60
            radius: 18
            color: Qt.rgba(1, 1, 1, theme ? theme.glassBack + 0.04 : 0.16)
            border.color: colors ? colors.divider : Qt.rgba(1, 1, 1, 0.18)
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter
            Text {
                anchors.centerIn: parent
                text: root.duration + qsTr("m")
                font.pixelSize: 13
                font.weight: Font.DemiBold
                font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                color: colors ? colors.text : "#FFFFFF"
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
