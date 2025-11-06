import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import Styles 1.0 as Styles

Item {
    id: dialog
    anchors.fill: parent
    visible: false
    z: 250

    property bool syncing: false

    function open() {
        visible = true
        sync()
        Qt.callLater(() => themeDark.forceActiveFocus())
    }

    function close() {
        visible = false
    }

    function sync() {
        if (!planner) {
            return
        }
        syncing = true
        themeDark.checked = !!planner.darkTheme
        themeLight.checked = !planner.darkTheme
        languageDe.checked = planner.language !== "en"
        languageEn.checked = planner.language === "en"
        weekStartMonday.checked = planner.weekStart !== "sunday"
        weekStartSunday.checked = planner.weekStart === "sunday"
        weekNumbersSwitch.checked = !!planner.showWeekNumbers

        if (typeof planner.reviewInitialInterval === "number" && isFinite(planner.reviewInitialInterval)) {
            reviewIntervalSpinBox.value = Math.max(reviewIntervalSpinBox.from, Math.min(reviewIntervalSpinBox.to, Math.round(planner.reviewInitialInterval)))
        }
        syncing = false
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
                        onToggled: if (checked && !dialog.syncing && planner) planner.darkTheme = true
                    }
                    RadioButton {
                        id: themeLight
                        text: qsTr("Hell")
                        ButtonGroup.group: themeGroup
                        onToggled: if (checked && !dialog.syncing && planner) planner.darkTheme = false
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
                        onToggled: if (checked && !dialog.syncing && planner) planner.language = "de"
                    }
                    RadioButton {
                        id: languageEn
                        text: qsTr("Englisch")
                        ButtonGroup.group: languageGroup
                        onToggled: if (checked && !dialog.syncing && planner) planner.language = "en"
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
                        onToggled: if (checked && !dialog.syncing && planner) planner.weekStart = "monday"
                    }
                    RadioButton {
                        id: weekStartSunday
                        text: qsTr("Sonntag")
                        ButtonGroup.group: weekStartGroup
                        onToggled: if (checked && !dialog.syncing && planner) planner.weekStart = "sunday"
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
                        onToggled: if (!dialog.syncing && planner) planner.showWeekNumbers = checked
                    }
                }
                
                Column {
                    spacing: Styles.ThemeStore.gap.g12
                    Text {
                        text: qsTr("Review Intervall (Tage)")
                        font.pixelSize: Styles.ThemeStore.type.sm
                        font.weight: Styles.ThemeStore.type.weightBold
                        font.family: Styles.ThemeStore.fonts.heading
                        color: Styles.ThemeStore.colors.text
                        renderType: Text.NativeRendering
                    }
                    SpinBox {
                        id: reviewIntervalSpinBox
                        from: 1
                        to: 7
                        value: 1
                        onValueModified: {
                            if (!dialog.syncing && planner && planner.setReviewInitialInterval) {
                                planner.setReviewInitialInterval(value)
                            }
                        }
                    }
                    Text {
                        text: qsTr("Initiales Intervall für neue Reviews")
                        font.pixelSize: Styles.ThemeStore.type.xs
                        color: Styles.ThemeStore.colors.text2
                        renderType: Text.NativeRendering
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
        ignoreUnknownSignals: true
        function onDarkThemeChanged() {
            if (dialog.visible) dialog.sync()
        }
        function onViewModeChanged() {
            if (dialog.visible) dialog.sync()
        }
        function onOnlyOpenChanged() {
            if (dialog.visible) dialog.sync()
        }
        function onZenModeChanged() {
            if (dialog.visible) dialog.sync()
        }
    }
}
