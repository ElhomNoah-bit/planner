import QtQuick
import QtQuick.Layouts
import NoahPlanner.Styles as Styles

Rectangle {
    id: chip
    property string label: ""
    property color subjectColor: Styles.ThemeStore.accent
    property bool muted: false
    property bool overdue: false
    property string timeText: ""
    property bool timed: timeText.length > 0

    implicitHeight: 26
    implicitWidth: Math.max(92, contentRow.implicitWidth + Styles.ThemeStore.g16)
    radius: Styles.ThemeStore.r12
    color: muted ? Styles.ThemeStore.cardAlt : Styles.ThemeStore.cardBg
    border.width: overdue ? 1 : 0
    border.color: overdue ? Styles.ThemeStore.danger : "transparent"

    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.margins: Styles.ThemeStore.g12
        spacing: Styles.ThemeStore.g8

        Rectangle {
            width: timed ? 6 : 0
            height: timed ? 6 : 0
            radius: 3
            color: muted ? Styles.ThemeStore.divider : subjectColor
            visible: timed
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                visible: timed
                text: chip.timeText
                font.pixelSize: Styles.ThemeStore.type.xs
                font.weight: Styles.ThemeStore.type.weightMedium
                font.family: Styles.ThemeStore.fonts.uiFallback
                color: Styles.ThemeStore.colors.text2
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }

            Text {
                id: labelText
                text: chip.label
                color: Styles.ThemeStore.colors.textPrimary
                font.pixelSize: Styles.ThemeStore.type.sm
                font.weight: Styles.ThemeStore.type.weightMedium
                font.family: Styles.ThemeStore.fonts.heading
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                renderType: Text.NativeRendering
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: chip.radius
        color: Styles.ThemeStore.hover
        visible: hoverHandler.hovered
        opacity: 0.2
    }

    HoverHandler {
        id: hoverHandler
    }
}
