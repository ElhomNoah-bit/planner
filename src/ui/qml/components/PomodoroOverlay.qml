import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import Styles 1.0

Item {
    id: overlay
    property alias planner: plannerRef.target
    property bool open: false

    anchors.fill: parent
    visible: open
    z: 400

    Rectangle {
        anchors.fill: parent
        color: ThemeStore.overlayBg
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
        width: Math.min(parent.width - ThemeStore.gapXl * 2, 420)
        padding: ThemeStore.gapXl
        visible: overlay.open
        radius: ThemeStore.radii.lg

        ColumnLayout {
            spacing: ThemeStore.gapLg
            anchors.fill: parent

            Text {
                text: qsTr("Pomodoro")
                font.pixelSize: ThemeStore.type.lg
                font.weight: ThemeStore.type.weightBold
                font.family: ThemeStore.fonts.heading
                color: ThemeStore.colors.text
            }

            Text {
                text: {
                    if (!overlay.planner)
                        return ""
                    var state = overlay.planner.pomodoro || {}
                    return state.phaseLabel || ""
                }
                font.pixelSize: ThemeStore.type.sm
                font.family: ThemeStore.fonts.body
                color: ThemeStore.colors.text2
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
                font.weight: ThemeStore.type.weightBold
                font.family: ThemeStore.fonts.heading
                color: ThemeStore.colors.text
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
                    radius: ThemeStore.radii.sm
                    color: ThemeStore.surfaceRaised
                }
                contentItem: Rectangle {
                    radius: ThemeStore.radii.sm
                    color: ThemeStore.accent
                    width: progress.visualPosition * progress.width
                }
            }

            PomodoroStats {
                state: overlay.planner ? overlay.planner.pomodoro || {} : ({})
            }

            RowLayout {
                spacing: ThemeStore.gapSm
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

    Shortcut {
        sequences: [ "Esc" ]
        context: Qt.WindowShortcut
        enabled: overlay.open
        onActivated: overlay.open = false
    }
}
