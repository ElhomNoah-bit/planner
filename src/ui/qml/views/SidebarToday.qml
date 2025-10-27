import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner 1.0 as NP

GlassPanel {
    id: root
    property string selectedIso: PlannerBackend.selectedDate
    property var summary: PlannerBackend.daySummary(selectedIso)
    signal startTimerRequested(int minutes)

    width: 320
    padding: 20

    Column {
        anchors.fill: parent
        spacing: NP.ThemeStore.spacing.gap16

        Column {
            spacing: 4
            Text {
                text: qsTr("Heute")
                font.pixelSize: 22
                font.weight: Font.DemiBold
                font.family: NP.ThemeStore.defaultFontFamily
                color: NP.ThemeStore.text
            }
            Text {
                text: summary.total > 0 ? summary.done + "/" + summary.total + qsTr(" erledigt") : qsTr("Keine Aufgaben")
                font.pixelSize: NP.ThemeStore.typography.metaSize
                font.weight: NP.ThemeStore.typography.metaWeight
                font.family: NP.ThemeStore.defaultFontFamily
                color: NP.ThemeStore.muted
            }
        }

        ListView {
            id: tasksView
            width: parent.width
            model: PlannerBackend.todayTasks
            clip: true
            spacing: NP.ThemeStore.spacing.gap12
            interactive: true
            boundsBehavior: Flickable.StopAtBounds
            flickDeceleration: 3500
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOff
            }
            implicitHeight: 240
            delegate: TodayTaskDelegate {
                width: tasksView.width
                title: model.title
                goal: model.goal
                duration: model.duration
                subjectColor: model.color
                done: model.done
                onToggled: function(next) { PlannerBackend.toggleTaskDone(index, next) }
                onStartTimer: root.startTimerRequested(minutes)
            }
        }

        Column {
            spacing: 8
            Text {
                text: qsTr("Klassenarbeiten")
                font.pixelSize: 18
                font.weight: Font.DemiBold
                font.family: NP.ThemeStore.defaultFontFamily
                color: NP.ThemeStore.text
            }
            ListView {
                id: examsView
                width: parent.width
                model: PlannerBackend.exams
                clip: true
                implicitHeight: 140
                spacing: 8
                delegate: GlassPanel {
                    width: examsView.width
                    radius: NP.ThemeStore.radii.md
                    padding: 14
                    Column {
                        spacing: 6
                        property var subject: PlannerBackend.subjectById(model.subjectId)
                        Row {
                            spacing: 8
                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5
                                color: subject.color
                            }
                            Text {
                                text: subject.name
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                font.family: NP.ThemeStore.defaultFontFamily
                                color: NP.ThemeStore.text
                            }
                            Text {
                                text: Qt.formatDate(model.date, "dd.MM.yyyy")
                                font.pixelSize: NP.ThemeStore.typography.metaSize
                                font.weight: NP.ThemeStore.typography.metaWeight
                                font.family: NP.ThemeStore.defaultFontFamily
                                color: NP.ThemeStore.muted
                            }
                        }
                        Text {
                            text: model.topics.join(", ")
                            font.pixelSize: NP.ThemeStore.typography.metaSize
                            font.weight: NP.ThemeStore.typography.metaWeight
                            font.family: NP.ThemeStore.defaultFontFamily
                            color: NP.ThemeStore.muted
                            wrapMode: Text.WrapAnywhere
                        }
                        PillButton {
                            text: qsTr("Zum Tag")
                            subtle: true
                            onClicked: PlannerBackend.selectDateIso(Qt.formatDate(model.date, "yyyy-MM-dd"))
                        }
                    }
                }
            }
        }
    }

    function refreshSummary() {
        summary = PlannerBackend.daySummary(selectedIso)
    }

    Connections {
        target: PlannerBackend
        function onSelectedDateChanged() {
            root.selectedIso = PlannerBackend.selectedDate
            root.refreshSummary()
        }
        function onTasksChanged() {
            root.refreshSummary()
        }
        function onFiltersChanged() {
            root.refreshSummary()
        }
    }
}
