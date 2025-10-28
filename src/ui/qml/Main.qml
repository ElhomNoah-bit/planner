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

    signal quickAddRequested(string isoDate, string kind)
    signal jumpToTodayRequested()

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject metrics: Styles.ThemeStore.layout

    RowLayout {
        anchors.fill: parent
        spacing: gaps.g24

        Loader {
            id: viewLoader
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: root.componentForMode(root.viewMode)
        }

        SidebarToday {
            id: sidebar
            Layout.preferredWidth: metrics.sidebarW
            Layout.fillHeight: true
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

    function componentForMode(mode) {
        switch (mode) {
        case "week":
            return weekViewComponent
        case "list":
            return listViewComponent
        default:
            return monthViewComponent
        }
    }

    function goToday() {
        if (viewLoader.item && viewLoader.item.goToday) {
            viewLoader.item.goToday()
        } else {
            planner.refreshToday()
        }
    }

    Component {
        id: monthViewComponent
        MonthView {
            anchors.fill: parent
            onDaySelected: iso => planner.selectDateIso(iso)
            function goToday() { planner.refreshToday() }
            onQuickAddRequested: (iso, kind) => root.quickAddRequested(iso, kind)
            onJumpToTodayRequested: root.jumpToTodayRequested()
        }
    }

    Component {
        id: weekViewComponent
        WeekView {
            anchors.fill: parent
            onDaySelected: iso => planner.selectDateIso(iso)
            function goToday() { planner.refreshToday() }
        }
    }

    Component {
        id: listViewComponent
        AgendaView {
            anchors.fill: parent
        }
    }
}
