import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0

ApplicationWindow {
    id: app
    width: 1280
    height: 900
    minimumWidth: 1024
    minimumHeight: 720
    visible: true
    title: qsTr("Noah Planner")
    color: ThemeStore.bg

    Component.onCompleted: {
        ThemeStore.dark = PlannerBackend.darkTheme
        toasts.show("Hello, Noah!", 1200)
    }

    Connections {
        target: PlannerBackend
        function onDarkThemeChanged() {
            ThemeStore.dark = PlannerBackend.darkTheme
            app.color = ThemeStore.bg
        }
    }

    Main {
        id: mainView
        anchors.fill: parent
    }

    ToastHost {
        id: toasts
        anchors.fill: parent
    }
}
