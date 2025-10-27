import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import "../styles" as Styles

GlassPanel {
    id: root
    property string selectedIso: PlannerBackend.selectedDate
    property var summary: PlannerBackend.daySummary(selectedIso)
    signal startTimerRequested(int minutes)

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var space: theme ? theme.space : null
    readonly property var typeScale: theme ? theme.type : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var surface: theme ? theme.surface : null
    readonly property var layout: theme ? theme.layout : null

    width: layout ? layout.sidebarW : 340
    padding: layout ? layout.margin : (space ? space.gap24 : 24)

    ColumnLayout {
        anchors.fill: parent
        spacing: space ? space.gap16 : 16

        Column {
            Layout.fillWidth: true
            spacing: space ? space.gap4 : 4
            Text {
                text: qsTr("Heute")
                font.pixelSize: typeScale ? typeScale.lg : 18
                font.weight: typeScale ? typeScale.weightBold : Font.DemiBold
                font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                color: colors ? colors.text : "#FFFFFF"
                renderType: Text.NativeRendering
            }
            Text {
                text: summary.total > 0 ? summary.done + "/" + summary.total + qsTr(" erledigt") : qsTr("Keine Aufgaben")
                font.pixelSize: typeScale ? typeScale.metaSize : 12
                font.weight: typeScale ? typeScale.metaWeight : Font.Normal
                font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                color: colors ? colors.textMuted : "#9AA3AF"
                renderType: Text.NativeRendering
            }
        }

        GlassPanel {
            Layout.fillWidth: true
            Layout.fillHeight: true
            tint: surface ? surface.level1Glass : Qt.rgba(0.07, 0.07, 0.09, 0.9)
            padding: space ? space.gap16 : 16

            Flickable {
                id: contentFlick
                anchors.fill: parent
                contentWidth: width
                contentHeight: contentColumn.implicitHeight
                clip: true

                Column {
                    id: contentColumn
                    width: parent.width
                    spacing: space ? space.gap16 : 16

                    Column {
                        spacing: space ? space.gap8 : 8
                        Text {
                            text: qsTr("Nächste Aufgaben")
                            font.pixelSize: typeScale ? typeScale.md : 15
                            font.weight: typeScale ? typeScale.weightBold : Font.DemiBold
                            font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                            color: colors ? colors.text : "#FFFFFF"
                            renderType: Text.NativeRendering
                        }

                        Column {
                            id: tasksColumn
                            width: parent.width
                            spacing: space ? space.gap12 : 12
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
                                spacing: space ? space.gap4 : 4
                                Text {
                                    text: qsTr("Alles erledigt - super!")
                                    font.pixelSize: typeScale ? typeScale.sm : 13
                                    font.weight: typeScale ? typeScale.weightMedium : Font.Medium
                                    font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                                    color: colors ? colors.textMuted : "#9AA3AF"
                                    horizontalAlignment: Text.AlignHCenter
                                    width: parent.width
                                    renderType: Text.NativeRendering
                                }
                            }
                        }
                    }

                    Rectangle {
                        height: 1
                        color: colors ? colors.divider : Qt.rgba(1, 1, 1, 0.12)
                        opacity: theme && theme.text ? theme.text.subtle : 0.55
                        width: parent.width
                    }

                    Column {
                        spacing: space ? space.gap8 : 8
                        Text {
                            text: qsTr("Klassenarbeiten")
                            font.pixelSize: typeScale ? typeScale.md : 15
                            font.weight: typeScale ? typeScale.weightBold : Font.DemiBold
                            font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                            color: colors ? colors.text : "#FFFFFF"
                            renderType: Text.NativeRendering
                        }

                        Column {
                            id: examsColumn
                            width: parent.width
                            spacing: space ? space.gap12 : 12
                            visible: examsRepeater.count > 0
                            height: visible ? implicitHeight : 0
                            Repeater {
                                id: examsRepeater
                                model: PlannerBackend.exams
                                delegate: GlassPanel {
                                    width: examsColumn.width
                                    radius: radii ? radii.md : 14
                                    padding: space ? space.gap12 : 12
                                    Column {
                                        spacing: space ? space.gap8 : 8
                                        property var subject: PlannerBackend.subjectById(model.subjectId)
                                        Row {
                                            spacing: space ? space.gap8 : 8
                                            Rectangle {
                                                width: 10
                                                height: 10
                                                radius: 5
                                                color: subject.color
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                            Text {
                                                text: subject.name
                                                font.pixelSize: typeScale ? typeScale.md : 14
                                                font.weight: typeScale ? typeScale.weightBold : Font.DemiBold
                                                font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                                                color: colors ? colors.text : "#FFFFFF"
                                                renderType: Text.NativeRendering
                                            }
                                            Text {
                                                text: Qt.formatDate(model.date, "dd.MM.yyyy")
                                                font.pixelSize: typeScale ? typeScale.metaSize : 12
                                                font.weight: typeScale ? typeScale.metaWeight : Font.Normal
                                                font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                                                color: colors ? colors.textMuted : "#9AA3AF"
                                                renderType: Text.NativeRendering
                                            }
                                        }
                                        Text {
                                            text: model.topics.join(", ")
                                            font.pixelSize: typeScale ? typeScale.metaSize : 12
                                            font.weight: typeScale ? typeScale.metaWeight : Font.Normal
                                            font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                                            color: colors ? colors.textMuted : "#9AA3AF"
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
                            font.pixelSize: typeScale ? typeScale.sm : 13
                            font.weight: typeScale ? typeScale.weightMedium : Font.Medium
                            font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                            color: colors ? colors.textMuted : "#9AA3AF"
                            renderType: Text.NativeRendering
                        }
                    }
                }

                ScrollIndicator.vertical: ScrollIndicator { }
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
