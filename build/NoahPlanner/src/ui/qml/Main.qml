import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Item {
    id: root
    anchors.fill: parent

    property string selectedIso: PlannerBackend.selectedDate
    property string currentView: PlannerBackend.viewMode
    property bool darkTheme: PlannerBackend.darkTheme
    property var subjectsModel: PlannerBackend.subjects

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject metrics: Styles.ThemeStore.layout

    readonly property var selectedDateObj: selectedIso.length > 0 ? new Date(selectedIso) : new Date()
    readonly property var summaryToday: PlannerBackend.daySummary(selectedIso)
    readonly property string headerSubtitle: summaryToday.total > 0
        ? qsTr("%1 von %2 Aufgaben erledigt").arg(summaryToday.done).arg(summaryToday.total)
        : qsTr("Keine Aufgaben für diesen Tag")

    Rectangle {
        anchors.fill: parent
        z: -1
        color: colors ? colors.appBg : "transparent"
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: gaps.g24

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: gaps.g24

            Item {
                id: gridContainer
                Layout.fillWidth: true
                Layout.fillHeight: true

                MonthView {
                    anchors.fill: parent
                }
            }

            SidebarToday {
                Layout.preferredWidth: metrics.sidebarW
                Layout.fillHeight: true
            }
        }
    }

    TimerOverlay {
        id: timerOverlay
        function openTimer(minutes) {
            timerOverlay.minutes = minutes
            timerOverlay.open = true
        }
        onFinished: PlannerBackend.showToast(qsTr("Timer abgeschlossen"))
    }

    Connections {
        target: PlannerBackend
        function onSelectedDateChanged() {
            root.selectedIso = PlannerBackend.selectedDate
        }
        function onViewModeChanged() {
            root.currentView = PlannerBackend.viewMode
        }
        function onSubjectsChanged() {
            root.subjectsModel = PlannerBackend.subjects
        }
        function onFiltersChanged() {
            root.subjectsModel = PlannerBackend.subjects
        }
        function onDarkThemeChanged() {
            root.darkTheme = PlannerBackend.darkTheme
        }
    }

    Component.onCompleted: {
        root.subjectsModel = PlannerBackend.subjects
    }

    function shiftMonth(offset) {
        var d = new Date(selectedIso)
        d.setMonth(d.getMonth() + offset)
        var iso = Qt.formatDate(d, "yyyy-MM-dd")
        PlannerBackend.selectDateIso(iso)
    }
}
