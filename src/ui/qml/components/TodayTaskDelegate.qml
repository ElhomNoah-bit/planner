import QtQuick
import QtQuick.Controls
import Styles 1.0 as Styles

Item {
    id: root
    property string title: ""
    property string goal: ""
    property int duration: 25
    property color subjectColor: Styles.ThemeStore.colors.accent
    property bool done: false
    property int priority: 1  // 0=Low, 1=Medium, 2=High
    signal toggled(bool done)
    signal startTimer(int minutes)

    implicitHeight: 68
    width: parent ? parent.width : 320

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject radii: Styles.ThemeStore.radii
    readonly property QtObject typeScale: Styles.ThemeStore.type

    Rectangle {
        id: container
        anchors.fill: parent
        radius: radii.md
        border.color: root.done ? colors.accent : colors.divider
        border.width: 1
        Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
        Behavior on border.color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
    }

    Row {
        anchors.fill: parent
        anchors.margins: gaps.g16
        spacing: gaps.g16

        // Priority indicator dot
        Rectangle {
            id: priorityDot
            width: 8
            height: 8
            radius: 4
            color: {
                if (root.priority === 2) return colors.prioHigh
                if (root.priority === 1) return colors.prioMedium
                return colors.prioLow
            }
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.done
            Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
        }

        Rectangle {
            id: checkbox
            width: 20
            height: 20
            radius: 10
            border.width: 2
            border.color: root.done ? colors.accent : colors.divider
            color: root.done ? colors.accent : "transparent"
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Behavior on border.color { ColorAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Text {
                anchors.centerIn: parent
                text: root.done ? "✓" : ""
                color: colors.appBg
                font.pixelSize: 12
                font.weight: Font.DemiBold
                renderType: Text.NativeRendering
            }
        }

        Column {
            width: Math.max(0, parent.width - timerPill.width - checkbox.width - priorityDot.width - 64)
            spacing: gaps.g8
            Text {
                text: root.title
                font.pixelSize: typeScale.md
                font.weight: typeScale.weightMedium
                font.family: Styles.ThemeStore.fonts.uiFallback
                color: colors.text
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }
            Text {
                text: root.goal
                font.pixelSize: typeScale.xs
                font.weight: typeScale.weightRegular
                font.family: Styles.ThemeStore.fonts.uiFallback
                color: colors.text2
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }
        }

        Rectangle {
            id: timerPill
            height: Math.max(Styles.ThemeStore.layout.pillH, 36)
            width: 70
            radius: Styles.ThemeStore.radii.md
            color: colors.hover
            border.color: colors.divider
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter
            Text {
                anchors.centerIn: parent
                text: root.duration + qsTr("m")
                font.pixelSize: typeScale.sm
                font.weight: typeScale.weightMedium
                font.family: Styles.ThemeStore.fonts.uiFallback
                color: colors.text
                renderType: Text.NativeRendering
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
