import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Item {
    id: controls
    property alias planner: plannerRef.target
    property int defaultMinutes: 25

    implicitWidth: column.implicitWidth
    implicitHeight: column.implicitHeight

    Connections {
        id: plannerRef
        target: null
    }

    Timer {
        interval: 1000 * 5
        running: controls.planner && controls.planner.focusSessionActive
        repeat: true
        onTriggered: controls.planner.refreshFocusHistory()
    }

    property real progressValue: {
        if (!controls.planner)
            return 0
        var info = controls.planner.focusSession || {}
        return info.progress || 0
    }

    ColumnLayout {
        id: column
        spacing: Styles.ThemeStore.gap.g8
        Layout.fillWidth: true

        Text {
            text: controls.planner && controls.planner.focusSessionActive ? qsTr("Fokus läuft") : qsTr("Neue Fokus-Sitzung")
            font.pixelSize: Styles.ThemeStore.type.sm
            font.weight: Styles.ThemeStore.type.weightBold
            font.family: Styles.ThemeStore.fonts.heading
            color: Styles.ThemeStore.colors.text
        }

        Text {
            text: {
                if (!controls.planner)
                    return ""
                var info = controls.planner.focusSession || {}
                if (controls.planner.focusSessionActive) {
                    var elapsed = info.elapsedMinutes || 0
                    var goal = info.goalMinutes || controls.defaultMinutes
                    return qsTr("%1 von %2 Minuten abgeschlossen").arg(elapsed).arg(goal)
                }
                if (info.lastMinutes)
                    return qsTr("Letzte Sitzung: %1 Minuten").arg(info.lastMinutes)
                return qsTr("Keine Sitzungen protokolliert")
            }
            font.pixelSize: Styles.ThemeStore.type.xs
            font.family: Styles.ThemeStore.fonts.body
            color: Styles.ThemeStore.colors.text2
            wrapMode: Text.WordWrap
        }

        ProgressBar {
            id: progressBar
            visible: controls.planner && controls.planner.focusSessionActive
            from: 0
            to: 1
            value: progressValue
            Layout.fillWidth: true
            background: Rectangle {
                radius: Styles.ThemeStore.radii.sm
                color: Styles.ThemeStore.colors.cardAlt
            }
            contentItem: Rectangle {
                radius: Styles.ThemeStore.radii.sm
                color: Styles.ThemeStore.colors.accent
                width: progressBar.visualPosition * progressBar.width
            }
        }

        RowLayout {
            spacing: Styles.ThemeStore.gap.g8
            Layout.fillWidth: true

            PillButton {
                text: controls.planner && controls.planner.focusSessionActive ? qsTr("Stoppen") : qsTr("Start %1 min").arg(controls.defaultMinutes)
                kind: controls.planner && controls.planner.focusSessionActive ? "danger" : "primary"
                Layout.fillWidth: true
                onClicked: {
                    if (!controls.planner)
                        return
                    if (controls.planner.focusSessionActive) {
                        controls.planner.stopFocusSession(true)
                    } else {
                        controls.planner.startFocusSession(controls.defaultMinutes)
                    }
                }
            }

            PillButton {
                visible: controls.planner && controls.planner.focusSessionActive
                text: qsTr("Abbrechen")
                kind: "ghost"
                Layout.fillWidth: true
                onClicked: controls.planner.cancelFocusSession()
            }
        }
    }
}
