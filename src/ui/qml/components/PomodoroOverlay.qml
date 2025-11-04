import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Item {
    id: overlay
    property alias planner: plannerRef.target
    property bool open: false

    anchors.fill: parent
    visible: open
    z: 400

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)
        visible: overlay.open

        TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: overlay.open = false
        }
    }

    GlassPanel {
        id: panel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(parent.width - Styles.ThemeStore.gap.g24 * 2, 420)
        padding: Styles.ThemeStore.gap.g24
        visible: overlay.open

        ColumnLayout {
            spacing: Styles.ThemeStore.gap.g16
            anchors.fill: parent

            Text {
                text: qsTr("Pomodoro")
                font.pixelSize: Styles.ThemeStore.type.lg
                font.weight: Styles.ThemeStore.type.weightBold
                font.family: Styles.ThemeStore.fonts.heading
                color: Styles.ThemeStore.colors.text
            }

            Text {
                text: {
                    if (!overlay.planner)
                        return ""
                    var state = overlay.planner.pomodoro || {}
                    return state.phaseLabel || ""
                }
                font.pixelSize: Styles.ThemeStore.type.sm
                font.family: Styles.ThemeStore.fonts.body
                color: Styles.ThemeStore.colors.text2
            }

            Text {
                id: timerLabel
                text: {
                    if (!overlay.planner)
                        return "00:00"
                    var state = overlay.planner.pomodoro || {}
                    return state.remainingDisplay || "00:00"
                }
                font.pixelSize: 48
                font.weight: Styles.ThemeStore.type.weightBold
                font.family: Styles.ThemeStore.fonts.heading
                color: Styles.ThemeStore.colors.textPrimary
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }

            ProgressBar {
                id: progress
                property var state: overlay.planner ? overlay.planner.pomodoro || {} : ({})
                from: 0
                to: {
                    var base = 0
                    if (state.phase === "focus")
                        base = state.focusMinutes * 60
                    else if (state.phase === "short-break")
                        base = state.breakMinutes * 60
                    else if (state.phase === "long-break")
                        base = state.longBreakMinutes * 60
                    if (base <= 0)
                        base = 1
                    return base
                }
                value: {
                    var remaining = state.remainingSeconds || 0
                    if (state.phase === "idle")
                        return 0
                    return Math.max(0, progress.to - remaining)
                }
                Layout.fillWidth: true
                background: Rectangle {
                    radius: Styles.ThemeStore.radii.sm
                    color: Styles.ThemeStore.colors.cardAlt
                }
                contentItem: Rectangle {
                    radius: Styles.ThemeStore.radii.sm
                    color: Styles.ThemeStore.colors.accent
                    width: progress.visualPosition * progress.width
                }
            }

            PomodoroStats {
                state: overlay.planner ? overlay.planner.pomodoro || {} : ({})
            }

            RowLayout {
                spacing: Styles.ThemeStore.gap.g8
                Layout.fillWidth: true

                PillButton {
                    text: {
                        if (!overlay.planner)
                            return ""
                        var running = overlay.planner.pomodoro.running
                        return running ? qsTr("Stoppen") : qsTr("Start")
                    }
                    kind: {
                        if (!overlay.planner)
                            return "primary"
                        return overlay.planner.pomodoro.running ? "danger" : "primary"
                    }
                    Layout.fillWidth: true
                    onClicked: {
                        if (!overlay.planner)
                            return
                        if (overlay.planner.pomodoro.running)
                            overlay.planner.stopPomodoro()
                        else
                            overlay.planner.startPomodoro()
                    }
                }

                PillButton {
                    text: qsTr("Phase überspringen")
                    kind: "ghost"
                    enabled: overlay.planner && overlay.planner.pomodoro.running
                    Layout.fillWidth: true
                    onClicked: overlay.planner.skipPomodoroPhase()
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                Layout.fillWidth: true

                PillButton {
                    text: qsTr("Schließen")
                    kind: "ghost"
                    onClicked: overlay.open = false
                }
            }
        }
    }

    Connections {
        id: plannerRef
        target: null
        function onPomodoroChanged() {
            // Trigger bindings
            timerLabel.text = timerLabel.text
        }
    }
}
