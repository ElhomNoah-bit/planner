import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Item {
    id: dialog
    anchors.fill: parent
    visible: false
    z: 250

    function open() {
        visible = true
        sync()
        Qt.callLater(() => themeDark.forceActiveFocus())
    }

    function close() {
        visible = false
    }

    function sync() {
        themeGroup.current = planner.darkTheme ? themeDark : themeSystem
        languageGroup.current = planner.language === "en" ? languageEn : languageDe
        weekStartGroup.current = planner.weekStart === "sunday" ? weekStartSunday : weekStartMonday
        weekNumbersSwitch.checked = planner.showWeekNumbers
        stressIndicatorSwitch.checked = planner.stressIndicatorEnabled
    }

    Keys.onEscapePressed: close()

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
        visible: dialog.visible
        TapHandler {
            acceptedButtons: Qt.LeftButton
            gesturePolicy: TapHandler.WithinBounds
            onTapped: dialog.close()
        }
    }

    GlassPanel {
        anchors.centerIn: parent
        width: Math.min(parent.width - Styles.ThemeStore.gap.g24 * 2, 520)
        padding: Styles.ThemeStore.gap.g24
        visible: dialog.visible

        ColumnLayout {
            anchors.fill: parent
            spacing: Styles.ThemeStore.gap.g24

            Column {
                spacing: Styles.ThemeStore.gap.g8
                Text {
                    text: qsTr("Einstellungen")
                    font.pixelSize: Styles.ThemeStore.type.lg
                    font.weight: Styles.ThemeStore.type.weightBold
                    font.family: Styles.ThemeStore.fonts.heading
                    color: Styles.ThemeStore.colors.text
                    renderType: Text.NativeRendering
                }
                Text {
                    text: qsTr("Passe Darstellung und Verhalten an.")
                    font.pixelSize: Styles.ThemeStore.type.sm
                    font.weight: Styles.ThemeStore.type.weightRegular
                    font.family: Styles.ThemeStore.fonts.body
                    color: Styles.ThemeStore.colors.text2
                    renderType: Text.NativeRendering
                }
            }

            GridLayout {
                columns: 2
                columnSpacing: Styles.ThemeStore.gap.g24
                rowSpacing: Styles.ThemeStore.gap.g24
                Layout.fillWidth: true

                Column {
                    spacing: Styles.ThemeStore.gap.g12
                    Text {
                        text: qsTr("Theme")
                        font.pixelSize: Styles.ThemeStore.type.sm
                        font.weight: Styles.ThemeStore.type.weightBold
                        font.family: Styles.ThemeStore.fonts.heading
                        color: Styles.ThemeStore.colors.text
                        renderType: Text.NativeRendering
                    }
                    ButtonGroup { id: themeGroup }
                    RadioButton {
                        id: themeDark
                        text: qsTr("Dunkel")
                        ButtonGroup.group: themeGroup
                        onToggled: if (checked) planner.darkTheme = true
                    }
                    RadioButton {
                        id: themeSystem
                        text: qsTr("System")
                        ButtonGroup.group: themeGroup
                        onToggled: if (checked) planner.darkTheme = false
                    }
                }

                Column {
                    spacing: Styles.ThemeStore.gap.g12
                    Text {
                        text: qsTr("Sprache")
                        font.pixelSize: Styles.ThemeStore.type.sm
                        font.weight: Styles.ThemeStore.type.weightBold
                        font.family: Styles.ThemeStore.fonts.heading
                        color: Styles.ThemeStore.colors.text
                        renderType: Text.NativeRendering
                    }
                    ButtonGroup { id: languageGroup }
                    RadioButton {
                        id: languageDe
                        text: qsTr("Deutsch")
                        ButtonGroup.group: languageGroup
                        onToggled: if (checked) planner.language = "de"
                    }
                    RadioButton {
                        id: languageEn
                        text: qsTr("Englisch")
                        ButtonGroup.group: languageGroup
                        onToggled: if (checked) planner.language = "en"
                    }
                }

                Column {
                    spacing: Styles.ThemeStore.gap.g12
                    Text {
                        text: qsTr("Wochenstart")
                        font.pixelSize: Styles.ThemeStore.type.sm
                        font.weight: Styles.ThemeStore.type.weightBold
                        font.family: Styles.ThemeStore.fonts.heading
                        color: Styles.ThemeStore.colors.text
                        renderType: Text.NativeRendering
                    }
                    ButtonGroup { id: weekStartGroup }
                    RadioButton {
                        id: weekStartMonday
                        text: qsTr("Montag")
                        ButtonGroup.group: weekStartGroup
                        onToggled: if (checked) planner.weekStart = "monday"
                    }
                    RadioButton {
                        id: weekStartSunday
                        text: qsTr("Sonntag")
                        ButtonGroup.group: weekStartGroup
                        onToggled: if (checked) planner.weekStart = "sunday"
                    }
                }

                Column {
                    spacing: Styles.ThemeStore.gap.g12
                    Text {
                        text: qsTr("Kalender-Wochennummern")
                        font.pixelSize: Styles.ThemeStore.type.sm
                        font.weight: Styles.ThemeStore.type.weightBold
                        font.family: Styles.ThemeStore.fonts.heading
                        color: Styles.ThemeStore.colors.text
                        renderType: Text.NativeRendering
                    }
                    Switch {
                        id: weekNumbersSwitch
                        text: checked ? qsTr("An") : qsTr("Aus")
                        onToggled: planner.showWeekNumbers = checked
                    }
                }
                
                Column {
                    spacing: Styles.ThemeStore.gap.g12
                    Text {
                        text: qsTr("Deadline-Stress-Anzeige")
                        font.pixelSize: Styles.ThemeStore.type.sm
                        font.weight: Styles.ThemeStore.type.weightBold
                        font.family: Styles.ThemeStore.fonts.heading
                        color: Styles.ThemeStore.colors.text
                        renderType: Text.NativeRendering
                    }
                    Text {
                        text: qsTr("Visuelle Hervorhebung nahender Deadlines")
                        font.pixelSize: Styles.ThemeStore.type.xs
                        font.weight: Styles.ThemeStore.type.weightRegular
                        font.family: Styles.ThemeStore.fonts.body
                        color: Styles.ThemeStore.colors.text2
                        wrapMode: Text.WordWrap
                        width: parent.width
                        renderType: Text.NativeRendering
                    }
                    Switch {
                        id: stressIndicatorSwitch
                        text: checked ? qsTr("An") : qsTr("Aus")
                        onToggled: planner.stressIndicatorEnabled = checked
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Styles.ThemeStore.gap.g12
                Item { Layout.fillWidth: true }
                PillButton {
                    text: qsTr("Schließen")
                    kind: "ghost"
                    onClicked: dialog.close()
                }
            }
        }
    }

    Connections {
        target: planner
        function onSettingsChanged() {
            if (dialog.visible) dialog.sync()
        }
        function onDarkThemeChanged() {
            if (dialog.visible) dialog.sync()
        }
    }
}
