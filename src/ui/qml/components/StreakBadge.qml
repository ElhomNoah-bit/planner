import QtQuick
import QtQuick.Layouts
import NoahPlanner.Styles as Styles

Item {
    id: root
    property int streak: 0
    property bool showLabel: true

    implicitWidth: badge.implicitWidth
    implicitHeight: badge.implicitHeight

    ColumnLayout {
        id: badge
        spacing: Styles.ThemeStore.gap.g4
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            width: 64
            height: 64
            radius: width / 2
            color: Styles.ThemeStore.colors.accentBg
            border.color: Styles.ThemeStore.colors.accent
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: root.streak
                font.pixelSize: Styles.ThemeStore.type.lg + 2
                font.weight: Styles.ThemeStore.type.weightBold
                font.family: Styles.ThemeStore.fonts.heading
                color: Styles.ThemeStore.colors.textPrimary
            }
        }

        Text {
            visible: root.showLabel
            text: qsTr("Tage in Folge")
            font.pixelSize: Styles.ThemeStore.type.xs
            font.weight: Styles.ThemeStore.type.weightRegular
            font.family: Styles.ThemeStore.fonts.body
            color: Styles.ThemeStore.colors.text2
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
