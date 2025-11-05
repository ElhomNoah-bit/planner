import QtQuick
import QtQuick.Layouts
import Styles 1.0 as Styles

Item {
    id: stats
    property var state: ({})

    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    ColumnLayout {
        id: column
        spacing: Styles.ThemeStore.gap.g4

        Text {
            text: qsTr("Abschlüsse")
            font.pixelSize: Styles.ThemeStore.type.xs
            font.weight: Styles.ThemeStore.type.weightMedium
            font.family: Styles.ThemeStore.fonts.body
            color: Styles.ThemeStore.colors.text2
        }

        Text {
            text: (stats.state && stats.state.completedCycles) ? stats.state.completedCycles : 0
            font.pixelSize: Styles.ThemeStore.type.sm
            font.weight: Styles.ThemeStore.type.weightBold
            font.family: Styles.ThemeStore.fonts.heading
            color: Styles.ThemeStore.colors.text
        }
    }
}
