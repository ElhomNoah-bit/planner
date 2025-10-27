import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0 as NP

ApplicationWindow {
    id: app
    width: 1280
    height: 900
    minimumWidth: 1024
    minimumHeight: 720
    visible: true
    title: qsTr("Noah Planner")
    color: NP.ThemeStore.bg

    Component.onCompleted: {
        NP.ThemeStore.dark = PlannerBackend.darkTheme
    }

    Connections {
        target: PlannerBackend
        function onDarkThemeChanged() {
            NP.ThemeStore.dark = PlannerBackend.darkTheme
            app.color = NP.ThemeStore.bg
        }
    }

    Main {
        id: mainView
        anchors.fill: parent
    }

    ToastHost {
        anchors.fill: parent
    }
}
