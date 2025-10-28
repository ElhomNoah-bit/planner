import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Item {
    id: root
    implicitWidth: Styles.ThemeStore.layout.sidebarW
    property string selectedIso: planner.selectedDate
    property var summary: planner.daySummary(selectedIso)
    signal startTimerRequested(int minutes)

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject radii: Styles.ThemeStore.radii

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight
        clip: true

        ColumnLayout {
            id: contentColumn
            width: flick.width
            spacing: gaps.g16

            GlassPanel {
                Layout.fillWidth: true
                padding: gaps.g16
                Column {
                    spacing: gaps.g8
                    Text {
                        text: qsTr("Heute")
                        font.pixelSize: typeScale.lg
                        font.weight: typeScale.weightBold
                        font.family: Styles.ThemeStore.fonts.heading
                        color: colors.text
                        renderType: Text.NativeRendering
                    }
                    Text {
                        text: summary.total > 0
                              ? qsTr("%1 von %2 Aufgaben erledigt").arg(summary.done).arg(summary.total)
                              : qsTr("Keine Aufgaben für diesen Tag")
                        font.pixelSize: typeScale.sm
                        font.weight: typeScale.weightRegular
                        font.family: Styles.ThemeStore.fonts.body
                        color: colors.text2
                        renderType: Text.NativeRendering
                    }
                }
            }

            GlassPanel {
                Layout.fillWidth: true
                padding: gaps.g16
                Column {
                    spacing: gaps.g12
                    Text {
                        text: qsTr("Nächste Aufgaben")
                        font.pixelSize: typeScale.sm
                        font.weight: typeScale.weightBold
                        font.family: Styles.ThemeStore.fonts.heading
                        color: colors.text
                        renderType: Text.NativeRendering
                    }
                    Loader {
                        id: tasksLoader
                        active: planner.todayTasks && planner.todayTasks.count > 0
                        sourceComponent: tasksList
                        onActiveChanged: emptyTasks.visible = !active
                    }
                    Text {
                        id: emptyTasks
                        visible: false
                        text: qsTr("Keine Einträge")
                        width: parent.width
                        font.pixelSize: typeScale.sm
                        font.weight: typeScale.weightRegular
                        font.family: Styles.ThemeStore.fonts.body
                        color: colors.text2
                        horizontalAlignment: Text.AlignHCenter
                        renderType: Text.NativeRendering
                    }
                }
            }

            GlassPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                padding: gaps.g16
                Column {
                    spacing: gaps.g12
                    Text {
                        text: qsTr("Klassenarbeiten")
                        font.pixelSize: typeScale.sm
                        font.weight: typeScale.weightBold
                        font.family: Styles.ThemeStore.fonts.heading
                        color: colors.text
                        renderType: Text.NativeRendering
                    }
                    Loader {
                        id: examsLoader
                        active: planner.exams && planner.exams.count > 0
                        sourceComponent: examsList
                        onActiveChanged: emptyExams.visible = !active
                    }
                    Text {
                        id: emptyExams
                        visible: false
                        text: qsTr("Keine Einträge")
                        width: parent.width
                        font.pixelSize: typeScale.sm
                        font.weight: typeScale.weightRegular
                        font.family: Styles.ThemeStore.fonts.body
                        color: colors.text2
                        horizontalAlignment: Text.AlignHCenter
                        renderType: Text.NativeRendering
                    }
                }
            }
        }

        ScrollIndicator.vertical: ScrollIndicator {}
    }

    Component {
        id: tasksList
        Column {
            width: flick.width - gaps.g16 * 2
            spacing: gaps.g12
            Repeater {
                model: planner.todayTasks
                delegate: TodayTaskDelegate {
                    width: parent ? parent.width : 320
                    title: model.title
                    goal: model.goal
                    duration: model.duration
                    subjectColor: model.color
                    done: model.done
                    onToggled: function(next) { planner.toggleTaskDone(index, next) }
                    onStartTimer: root.startTimerRequested(minutes)
                }
            }
        }
    }

    Component {
        id: examsList
        Column {
            width: flick.width - gaps.g16 * 2
            spacing: gaps.g12
            Repeater {
                model: planner.exams
                delegate: GlassPanel {
                    padding: gaps.g12
                    radius: radii.md
                    Column {
                        spacing: gaps.g8
                        property var subject: planner.subjectById(model.subjectId)
                        Row {
                            spacing: gaps.g8
                            Rectangle {
                                width: 10
                                height: 10
                                radius: 5
                                color: subject.color
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: subject.name
                                font.pixelSize: typeScale.md
                                font.weight: typeScale.weightMedium
                                font.family: Styles.ThemeStore.fonts.heading
                                color: colors.text
                                renderType: Text.NativeRendering
                            }
                            Text {
                                text: Qt.formatDate(model.date, "dd.MM.yyyy")
                                font.pixelSize: typeScale.xs
                                font.weight: typeScale.weightRegular
                                font.family: Styles.ThemeStore.fonts.body
                                color: colors.text2
                                renderType: Text.NativeRendering
                            }
                        }
                        Text {
                            text: model.topics.join(", ")
                            font.pixelSize: typeScale.xs
                            font.weight: typeScale.weightRegular
                            font.family: Styles.ThemeStore.fonts.body
                            color: colors.text2
                            opacity: 0.8
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            renderType: Text.NativeRendering
                        }
                        PillButton {
                            text: qsTr("Zum Tag")
                            kind: "ghost"
                            onClicked: planner.selectDateIso(Qt.formatDate(model.date, "yyyy-MM-dd"))
                        }
                    }
                }
            }
        }
    }

    function refreshSummary() {
        summary = planner.daySummary(selectedIso)
    }

    Connections {
        target: planner
        function onSelectedDateChanged() {
            root.selectedIso = planner.selectedDate
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
