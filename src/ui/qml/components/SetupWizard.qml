import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import Styles 1.0 as Styles

Dialog {
    id: wizard
    modal: true
    focus: true
    dim: true
    closePolicy: Popup.NoAutoClose
    parent: ApplicationWindow.window ? ApplicationWindow.window.overlay : Overlay.overlay
    z: 9999

    property int currentStep: 0
    readonly property int totalSteps: 4
    readonly property bool hasPlanner: planner !== undefined && planner !== null

    signal completed()

    function launch() {
        currentStep = 0
        wizard.open()
    }

    function nextStep() {
        if (currentStep < totalSteps - 1) {
            currentStep++
            Qt.callLater(() => focusStepControl())
        } else {
            completeSetup()
        }
    }

    function previousStep() {
        if (currentStep > 0) {
            currentStep--
            Qt.callLater(() => focusStepControl())
        }
    }

    function completeSetup() {
        if (hasPlanner) {
            planner.setupCompleted = true
        }
        completed()
        wizard.close()
    }

    function focusStepControl() {
        if (currentStep === 1 && languageDe) {
            languageDe.forceActiveFocus()
        } else if (currentStep === 2 && themeDark) {
            themeDark.forceActiveFocus()
        } else if (currentStep === 3 && weekStartMonday) {
            weekStartMonday.forceActiveFocus()
        } else if (primaryButton) {
            primaryButton.forceActiveFocus()
        }
    }

    onAboutToShow: {
        currentStep = 0
    }

    onOpened: {
        Qt.callLater(() => focusStepControl())
    }

    onClosed: {
        currentStep = 0
    }

    Keys.onEscapePressed: function(event) {
        event.accepted = true
    }

    Overlay.modal: Rectangle {
        color: "#00000080"
    }

    contentItem: Item {
        id: wizardContentRoot
        implicitWidth: mainPanel.implicitWidth
        implicitHeight: mainPanel.implicitHeight

        GlassPanel {
            id: mainPanel
            anchors.centerIn: parent
            padding: 0
            radius: Styles.ThemeStore.radii.lg
            property real computedParentWidth: wizard.parent ? wizard.parent.width : 0
            property real availableWidth: computedParentWidth > 0 ? computedParentWidth - Styles.ThemeStore.gap.g24 * 2 : 640
            width: Math.max(360, Math.min(640, availableWidth))

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
                            checked: hasPlanner ? planner.language === "de" : true
                            font.pixelSize: Styles.ThemeStore.type.lg
                            ButtonGroup.group: languageGroup
                            onToggled: if (checked && hasPlanner) planner.language = "de"
                        }

                        RadioButton {
                            id: languageEn
                            text: qsTr("🇬🇧 English")
                            checked: hasPlanner ? planner.language === "en" : false
                            font.pixelSize: Styles.ThemeStore.type.lg
                            ButtonGroup.group: languageGroup
                            onToggled: if (checked && hasPlanner) planner.language = "en"
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
                            checked: hasPlanner ? planner.darkTheme : true
                            font.pixelSize: Styles.ThemeStore.type.lg
                            ButtonGroup.group: themeGroup
                            onToggled: if (checked && hasPlanner) planner.darkTheme = true
                        }

                        RadioButton {
                            id: themeLight
                            text: qsTr("☀️ Helles Theme")
                            checked: hasPlanner ? !planner.darkTheme : false
                            font.pixelSize: Styles.ThemeStore.type.lg
                            ButtonGroup.group: themeGroup
                            onToggled: if (checked && hasPlanner) planner.darkTheme = false
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
                                checked: hasPlanner ? planner.weekStart === "monday" : true
                                font.pixelSize: Styles.ThemeStore.type.md
                                ButtonGroup.group: weekStartGroup
                                onToggled: if (checked && hasPlanner) planner.weekStart = "monday"
                            }

                            RadioButton {
                                id: weekStartSunday
                                text: qsTr("Sonntag")
                                checked: hasPlanner ? planner.weekStart === "sunday" : false
                                font.pixelSize: Styles.ThemeStore.type.md
                                ButtonGroup.group: weekStartGroup
                                onToggled: if (checked && hasPlanner) planner.weekStart = "sunday"
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
                                checked: hasPlanner ? planner.showWeekNumbers : false
                                font.pixelSize: Styles.ThemeStore.type.md
                                onToggled: if (hasPlanner) planner.showWeekNumbers = checked
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
                            id: primaryButton
                            text: currentStep === totalSteps - 1 ? qsTr("Fertig") : qsTr("Weiter")
                            kind: "primary"
                            onClicked: wizard.nextStep()
                        }
                    }
                }
        }
    }
}

}
