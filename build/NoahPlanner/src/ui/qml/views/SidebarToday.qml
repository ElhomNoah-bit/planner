import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import "styles" as Styles

Rectangle {
    id: root
    property string selectedIso: PlannerBackend.selectedDate
    property var summary: PlannerBackend.daySummary(selectedIso)
    signal startTimerRequested(int minutes)

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject radii: Styles.ThemeStore.radii
    readonly property QtObject metrics: Styles.ThemeStore.layout

    width: metrics.sidebarW
    radius: radii.xl
    color: colors.cardGlass
    border.width: 1
    border.color: colors.divider

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: metrics.margin
        spacing: gaps.g16

        Column {
            Layout.fillWidth: true
            spacing: gaps.g4
            Text {
                text: qsTr("Heute")
                font.pixelSize: typeScale.lg
                font.weight: typeScale.weightMedium
                font.family: Styles.ThemeStore.fonts.uiFallback
                color: colors.text
                renderType: Text.NativeRendering
            }
            Text {
                text: summary.total > 0 ? summary.done + "/" + summary.total + qsTr(" erledigt") : qsTr("Keine Aufgaben")
                font.pixelSize: typeScale.xs
                font.weight: typeScale.weightRegular
                font.family: Styles.ThemeStore.fonts.uiFallback
                color: colors.text2
                renderType: Text.NativeRendering
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Flickable {
                id: contentFlick
                anchors.fill: parent
                contentWidth: width
                contentHeight: contentColumn.implicitHeight
                clip: true
                interactive: contentHeight > height

                Column {
                    id: contentColumn
                    width: parent.width
                    spacing: gaps.g16

                    Column {
                        spacing: gaps.g8
                        Text {
                            text: qsTr("Nächste Aufgaben")
                            font.pixelSize: typeScale.sm
                            font.weight: typeScale.weightMedium
                            font.family: Styles.ThemeStore.fonts.uiFallback
                            color: colors.text2
                            renderType: Text.NativeRendering
                        }

                        Column {
                            id: tasksColumn
                            width: parent.width
                            spacing: gaps.g12
                            visible: tasksRepeater.count > 0
                            height: visible ? implicitHeight : 0
                            Repeater {
                                id: tasksRepeater
                                model: PlannerBackend.todayTasks
                                delegate: TodayTaskDelegate {
                                    width: tasksColumn.width
                                    title: model.title
                                    goal: model.goal
                                    duration: model.duration
                                    subjectColor: model.color
                                    done: model.done
                                    onToggled: function(next) { PlannerBackend.toggleTaskDone(index, next) }
                                    onStartTimer: root.startTimerRequested(minutes)
                                }
                            }
                        }

                        Item {
                            visible: tasksRepeater.count === 0
                            width: parent.width
                            height: 80
                            Column {
                                anchors.centerIn: parent
                                spacing: gaps.g4
                                Text {
                                    text: qsTr("Alles erledigt - super!")
                                    font.pixelSize: typeScale.sm
                                    font.weight: typeScale.weightMedium
                                    font.family: Styles.ThemeStore.fonts.uiFallback
                                    color: colors.text2
                                    horizontalAlignment: Text.AlignHCenter
                                    width: parent.width
                                    renderType: Text.NativeRendering
                                }
                            }
                        }
                    }

                    Rectangle {
                        height: 1
                        color: colors.divider
                        width: parent.width
                    }

                    Column {
                        spacing: gaps.g8
                        Text {
                            text: qsTr("Klassenarbeiten")
                            font.pixelSize: typeScale.sm
                            font.weight: typeScale.weightMedium
                            font.family: Styles.ThemeStore.fonts.uiFallback
                            color: colors.text2
                            renderType: Text.NativeRendering
                        }

                        Column {
                            id: examsColumn
                            width: parent.width
                            spacing: gaps.g12
                            visible: examsRepeater.count > 0
                            height: visible ? implicitHeight : 0
                            Repeater {
                                id: examsRepeater
                                model: PlannerBackend.exams
                                delegate: GlassPanel {
                                    width: examsColumn.width
                                    radius: radii.md
                                    padding: gaps.g12
                                    Column {
                                        spacing: gaps.g8
                                        property var subject: PlannerBackend.subjectById(model.subjectId)
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
                                                font.family: Styles.ThemeStore.fonts.uiFallback
                                                color: colors.text
                                                renderType: Text.NativeRendering
                                            }
                                            Text {
                                                text: Qt.formatDate(model.date, "dd.MM.yyyy")
                                                font.pixelSize: typeScale.xs
                                                font.weight: typeScale.weightRegular
                                                font.family: Styles.ThemeStore.fonts.uiFallback
                                                color: colors.text2
                                                renderType: Text.NativeRendering
                                            }
                                        }
                                        Text {
                                            text: model.topics.join(", ")
                                            font.pixelSize: typeScale.xs
                                            font.weight: typeScale.weightRegular
                                            font.family: Styles.ThemeStore.fonts.uiFallback
                                            color: colors.text2
                                            opacity: 0.7
                                            wrapMode: Text.WrapAnywhere
                                            renderType: Text.NativeRendering
                                        }
                                        PillButton {
                                            text: qsTr("Zum Tag")
                                            kind: "ghost"
                                            onClicked: PlannerBackend.selectDateIso(Qt.formatDate(model.date, "yyyy-MM-dd"))
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            visible: examsRepeater.count === 0
                            text: qsTr("Keine Prüfungen in Sicht")
                            font.pixelSize: typeScale.sm
                            font.weight: typeScale.weightMedium
                            font.family: Styles.ThemeStore.fonts.uiFallback
                            color: colors.text2
                            renderType: Text.NativeRendering
                        }
                    }
                }

                ScrollIndicator.vertical: ScrollIndicator {}
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
