import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Item {
    id: root
    implicitWidth: Styles.ThemeStore.layout.sidebarW * 2
    implicitHeight: Styles.ThemeStore.layout.headerH + 640

    property string viewMode: "month"
    property bool onlyOpen: false
    property bool zenMode: false

    signal quickAddRequested(string isoDate, string kind)
    signal jumpToTodayRequested()

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject metrics: Styles.ThemeStore.layout

    RowLayout {
        anchors.fill: parent
        spacing: gaps.g24

        StackLayout {
            id: viewStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.viewMode === "week" ? 1 : root.viewMode === "list" ? 2 : 0

            MonthView {
                id: monthView
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: viewStack.currentIndex === 0
                zenMode: root.zenMode
                onDaySelected: iso => planner.selectDateIso(iso)
                onQuickAddRequested: (iso, kind) => root.quickAddRequested(iso, kind)
                onJumpToTodayRequested: root.jumpToTodayRequested()
            }

            WeekView {
                id: weekView
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: viewStack.currentIndex === 1
                zenMode: root.zenMode
                onDaySelected: iso => planner.selectDateIso(iso)
            }

            AgendaView {
                id: agendaView
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: viewStack.currentIndex === 2
            }
        }

        SidebarToday {
            id: sidebar
            Layout.preferredWidth: metrics.sidebarW
            Layout.fillHeight: true
            zenMode: root.zenMode
            onStartTimerRequested: timerOverlay.openTimer(minutes)
        }
    }

    TimerOverlay {
        id: timerOverlay
        function openTimer(minutes) {
            timerOverlay.minutes = minutes
            timerOverlay.open = true
        }
        onFinished: planner.showToast(qsTr("Timer abgeschlossen"))
    }

    function goToday() {
        planner.jumpToToday()
    }
}
