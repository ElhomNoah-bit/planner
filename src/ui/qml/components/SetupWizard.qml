import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import Styles 1.0 as Styles

Item {
    id: wizard
    anchors.fill: parent
    visible: false
    z: 300

    property int currentStep: 0
    readonly property int totalSteps: 4

    signal completed()

    function open() {
        currentStep = 0
        visible = true
        welcomeStep.forceActiveFocus()
    }

    function close() {
        visible = false
    }

    function nextStep() {
        if (currentStep < totalSteps - 1) {
            currentStep++
        } else {
            completeSetup()
        }
    }

    function previousStep() {
        if (currentStep > 0) {
            currentStep--
        }
    }

    function completeSetup() {
        planner.setupCompleted = true
        completed()
        close()
    }

    Keys.onEscapePressed: {
        // Disable ESC key during setup
        event.accepted = true
    }

    // Dark overlay
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        visible: wizard.visible
    }

    // Main wizard panel
    GlassPanel {
        id: mainPanel
        anchors.centerIn: parent
        width: Math.min(parent.width - Styles.ThemeStore.gap.g24 * 2, 640)
        padding: 0
        visible: wizard.visible

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Header
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: Styles.ThemeStore.colors.primary
                radius: Styles.ThemeStore.radii.lg

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.ThemeStore.gap.g24
                    spacing: Styles.ThemeStore.gap.g16

                    Column {
                        Layout.fillWidth: true
                        spacing: Styles.ThemeStore.gap.g4

                        Text {
                            text: qsTr("Noah Planner Setup")
                            font.pixelSize: Styles.ThemeStore.type.xl
                            font.weight: Styles.ThemeStore.type.weightBold
                            font.family: Styles.ThemeStore.fonts.heading
                            color: "white"
                            renderType: Text.NativeRendering
                        }

                        Text {
                            text: qsTr("Schritt %1 von %2").arg(currentStep + 1).arg(totalSteps)
                            font.pixelSize: Styles.ThemeStore.type.sm
                            font.family: Styles.ThemeStore.fonts.body
                            color: Qt.rgba(1, 1, 1, 0.8)
                            renderType: Text.NativeRendering
                        }
                    }
                }
            }

            // Progress bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 4
                color: Styles.ThemeStore.colors.border

                Rectangle {
                    width: parent.width * ((currentStep + 1) / totalSteps)
                    height: parent.height
                    color: Styles.ThemeStore.colors.accent
                    
                    Behavior on width {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                }
            }

            // Content area
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 400
                Layout.margins: Styles.ThemeStore.gap.g24

                // Step 0: Welcome
                Column {
                    id: welcomeStep
                    anchors.fill: parent
                    spacing: Styles.ThemeStore.gap.g24
                    visible: currentStep === 0

                    Item { height: Styles.ThemeStore.gap.g24 }

                    Text {
                        width: parent.width
                        text: qsTr("Willkommen bei Noah Planner!")
                        font.pixelSize: Styles.ThemeStore.type.xxl
                        font.weight: Styles.ThemeStore.type.weightBold
                        font.family: Styles.ThemeStore.fonts.heading
                        color: Styles.ThemeStore.colors.text
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        renderType: Text.NativeRendering
                    }

                    Text {
                        width: parent.width
                        text: qsTr("Deine persönliche Lern- und Planungs-App")
                        font.pixelSize: Styles.ThemeStore.type.lg
                        font.family: Styles.ThemeStore.fonts.body
                        color: Styles.ThemeStore.colors.text2
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        renderType: Text.NativeRendering
                    }

                    Item { height: 20 }

                    Column {
                        width: parent.width
                        spacing: Styles.ThemeStore.gap.g16

                        Text {
                            width: parent.width
                            text: qsTr("Mit Noah Planner kannst du:")
                            font.pixelSize: Styles.ThemeStore.type.md
                            font.weight: Styles.ThemeStore.type.weightBold
                            font.family: Styles.ThemeStore.fonts.heading
                            color: Styles.ThemeStore.colors.text
                            renderType: Text.NativeRendering
                        }

                        Repeater {
                            model: [
                                qsTr("• Deine Aufgaben und Termine organisieren"),
                                qsTr("• Prüfungen planen und verfolgen"),
                                qsTr("• Mit Fokus-Sessions produktiv lernen"),
                                qsTr("• Deinen Fortschritt visualisieren")
                            ]

                            Text {
                                width: parent.width
                                text: modelData
                                font.pixelSize: Styles.ThemeStore.type.md
                                font.family: Styles.ThemeStore.fonts.body
                                color: Styles.ThemeStore.colors.text2
                                wrapMode: Text.WordWrap
                                renderType: Text.NativeRendering
                            }
                        }
                    }

                    Item { height: 20 }
                }

                // Step 1: Language
                Column {
                    anchors.fill: parent
                    spacing: Styles.ThemeStore.gap.g24
                    visible: currentStep === 1

                    Item { height: Styles.ThemeStore.gap.g16 }

                    Text {
                        width: parent.width
                        text: qsTr("Sprache wählen")
                        font.pixelSize: Styles.ThemeStore.type.xxl
                        font.weight: Styles.ThemeStore.type.weightBold
                        font.family: Styles.ThemeStore.fonts.heading
                        color: Styles.ThemeStore.colors.text
                        horizontalAlignment: Text.AlignHCenter
                        renderType: Text.NativeRendering
                    }

                    Text {
                        width: parent.width
                        text: qsTr("Wähle deine bevorzugte Sprache für die App")
                        font.pixelSize: Styles.ThemeStore.type.md
                        font.family: Styles.ThemeStore.fonts.body
                        color: Styles.ThemeStore.colors.text2
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        renderType: Text.NativeRendering
                    }

                    Item { height: 40 }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Styles.ThemeStore.gap.g16

                        ButtonGroup { id: languageGroup }

                        RadioButton {
                            id: languageDe
                            text: qsTr("🇩🇪 Deutsch")
                            checked: planner.language === "de"
                            font.pixelSize: Styles.ThemeStore.type.lg
                            ButtonGroup.group: languageGroup
                            onToggled: if (checked) planner.language = "de"
                        }

                        RadioButton {
                            id: languageEn
                            text: qsTr("🇬🇧 English")
                            checked: planner.language === "en"
                            font.pixelSize: Styles.ThemeStore.type.lg
                            ButtonGroup.group: languageGroup
                            onToggled: if (checked) planner.language = "en"
                        }
                    }

                    Item { height: 40 }
                }

                // Step 2: Theme
                Column {
                    anchors.fill: parent
                    spacing: Styles.ThemeStore.gap.g24
                    visible: currentStep === 2

                    Item { height: Styles.ThemeStore.gap.g16 }

                    Text {
                        width: parent.width
                        text: qsTr("Design wählen")
                        font.pixelSize: Styles.ThemeStore.type.xxl
                        font.weight: Styles.ThemeStore.type.weightBold
                        font.family: Styles.ThemeStore.fonts.heading
                        color: Styles.ThemeStore.colors.text
                        horizontalAlignment: Text.AlignHCenter
                        renderType: Text.NativeRendering
                    }

                    Text {
                        width: parent.width
                        text: qsTr("Wähle zwischen hellem und dunklem Theme")
                        font.pixelSize: Styles.ThemeStore.type.md
                        font.family: Styles.ThemeStore.fonts.body
                        color: Styles.ThemeStore.colors.text2
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        renderType: Text.NativeRendering
                    }

                    Item { height: 40 }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Styles.ThemeStore.gap.g16

                        ButtonGroup { id: themeGroup }

                        RadioButton {
                            id: themeDark
                            text: qsTr("🌙 Dunkles Theme")
                            checked: planner.darkTheme
                            font.pixelSize: Styles.ThemeStore.type.lg
                            ButtonGroup.group: themeGroup
                            onToggled: if (checked) planner.darkTheme = true
                        }

                        RadioButton {
                            id: themeLight
                            text: qsTr("☀️ Helles Theme")
                            checked: !planner.darkTheme
                            font.pixelSize: Styles.ThemeStore.type.lg
                            ButtonGroup.group: themeGroup
                            onToggled: if (checked) planner.darkTheme = false
                        }
                    }

                    Item { height: 40 }
                }

                // Step 3: Calendar settings
                Column {
                    anchors.fill: parent
                    spacing: Styles.ThemeStore.gap.g24
                    visible: currentStep === 3

                    Item { height: Styles.ThemeStore.gap.g16 }

                    Text {
                        width: parent.width
                        text: qsTr("Kalender-Einstellungen")
                        font.pixelSize: Styles.ThemeStore.type.xxl
                        font.weight: Styles.ThemeStore.type.weightBold
                        font.family: Styles.ThemeStore.fonts.heading
                        color: Styles.ThemeStore.colors.text
                        horizontalAlignment: Text.AlignHCenter
                        renderType: Text.NativeRendering
                    }

                    Text {
                        width: parent.width
                        text: qsTr("Passe den Kalender an deine Bedürfnisse an")
                        font.pixelSize: Styles.ThemeStore.type.md
                        font.family: Styles.ThemeStore.fonts.body
                        color: Styles.ThemeStore.colors.text2
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        renderType: Text.NativeRendering
                    }

                    Item { height: Styles.ThemeStore.gap.g8 }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Styles.ThemeStore.gap.g24
                        width: parent.width * 0.8

                        Column {
                            width: parent.width
                            spacing: Styles.ThemeStore.gap.g12

                            Text {
                                text: qsTr("Wochenstart")
                                font.pixelSize: Styles.ThemeStore.type.md
                                font.weight: Styles.ThemeStore.type.weightBold
                                font.family: Styles.ThemeStore.fonts.heading
                                color: Styles.ThemeStore.colors.text
                                renderType: Text.NativeRendering
                            }

                            ButtonGroup { id: weekStartGroup }

                            RadioButton {
                                id: weekStartMonday
                                text: qsTr("Montag")
                                checked: planner.weekStart === "monday"
                                font.pixelSize: Styles.ThemeStore.type.md
                                ButtonGroup.group: weekStartGroup
                                onToggled: if (checked) planner.weekStart = "monday"
                            }

                            RadioButton {
                                id: weekStartSunday
                                text: qsTr("Sonntag")
                                checked: planner.weekStart === "sunday"
                                font.pixelSize: Styles.ThemeStore.type.md
                                ButtonGroup.group: weekStartGroup
                                onToggled: if (checked) planner.weekStart = "sunday"
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: Styles.ThemeStore.gap.g12

                            Text {
                                text: qsTr("Kalender-Wochennummern")
                                font.pixelSize: Styles.ThemeStore.type.md
                                font.weight: Styles.ThemeStore.type.weightBold
                                font.family: Styles.ThemeStore.fonts.heading
                                color: Styles.ThemeStore.colors.text
                                renderType: Text.NativeRendering
                            }

                            Switch {
                                id: weekNumbersSwitch
                                text: checked ? qsTr("Anzeigen") : qsTr("Verstecken")
                                checked: planner.showWeekNumbers
                                font.pixelSize: Styles.ThemeStore.type.md
                                onToggled: planner.showWeekNumbers = checked
                            }
                        }
                    }

                    Item { height: 20 }
                }
            }

            // Footer with buttons
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: Qt.rgba(0, 0, 0, 0.05)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Styles.ThemeStore.gap.g24
                    spacing: Styles.ThemeStore.gap.g12

                    PillButton {
                        text: qsTr("Zurück")
                        kind: "ghost"
                        visible: currentStep > 0
                        onClicked: wizard.previousStep()
                    }

                    Item { Layout.fillWidth: true }

                    PillButton {
                        text: currentStep === totalSteps - 1 ? qsTr("Fertig") : qsTr("Weiter")
                        kind: "primary"
                        onClicked: wizard.nextStep()
                    }
                }
            }
        }
    }
}
