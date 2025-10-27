import QtQuick
import QtQuick.Controls
import styles 1.0 as Styles

Item {
    id: root
    property string title: ""
    property string goal: ""
    property int duration: 25
    property color subjectColor: Styles.ThemeStore.colors.accent
    property bool done: false
    signal toggled(bool done)
    signal startTimer(int minutes)

    implicitHeight: 68
    width: parent ? parent.width : 320

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var gap: theme ? theme.gap : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var typeScale: theme ? theme.type : null

    Rectangle {
        id: container
        anchors.fill: parent
        radius: radii ? radii.md : 12
        color: root.done ? (colors ? colors.accentBg : Qt.rgba(0.04, 0.35, 0.84, 0.18)) : (colors ? colors.cardBg : Qt.rgba(0, 0, 0, 0.25))
        border.color: root.done ? (colors ? colors.accent : "#0A84FF") : (colors ? colors.divider : Qt.rgba(1, 1, 1, 0.18))
        border.width: 1
        Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
        Behavior on border.color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
    }

    Row {
        anchors.fill: parent
        anchors.margins: gap ? gap.g16 : 16
        spacing: gap ? gap.g16 : 16

        Rectangle {
            id: checkbox
            width: 20
            height: 20
            radius: 10
            border.width: 2
            border.color: root.done ? (colors ? colors.accent : "#0A84FF") : (colors ? colors.divider : Qt.rgba(1, 1, 1, 0.2))
            color: root.done ? (colors ? colors.accent : "#0A84FF") : "transparent"
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Behavior on border.color { ColorAnimation { duration: 140; easing.type: Easing.OutCubic } }
            Text {
                anchors.centerIn: parent
                text: root.done ? "✓" : ""
                color: colors ? colors.appBg : "#0F1115"
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
        }

        Column {
            width: Math.max(0, parent.width - timerPill.width - checkbox.width - 48)
            spacing: gap ? gap.g8 : 8
            Text {
                text: root.title
                font.pixelSize: typeScale ? typeScale.md : 14
                font.weight: typeScale ? typeScale.weightMedium : Font.Medium
                font.family: Styles.ThemeStore.fonts.uiFallback
                color: colors ? colors.text : "#F2F5F9"
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }
            Text {
                text: root.goal
                font.pixelSize: typeScale ? typeScale.metaSize : 11
                font.weight: typeScale ? typeScale.weightRegular : Font.Normal
                font.family: Styles.ThemeStore.fonts.uiFallback
                color: colors ? colors.text2 : "#B7C0CC"
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }
        }

        Rectangle {
            id: timerPill
            height: Styles.ThemeStore.layout.pillH
            width: 70
            radius: Styles.ThemeStore.radii.md
            color: colors ? colors.hover : Qt.rgba(1, 1, 1, 0.12)
            border.color: colors ? colors.divider : Qt.rgba(1, 1, 1, 0.18)
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter
            Text {
                anchors.centerIn: parent
                text: root.duration + qsTr("m")
                font.pixelSize: typeScale ? typeScale.sm : 12
                font.weight: typeScale ? typeScale.weightMedium : Font.Medium
                font.family: Styles.ThemeStore.fonts.uiFallback
                color: colors ? colors.text : "#F2F5F9"
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
