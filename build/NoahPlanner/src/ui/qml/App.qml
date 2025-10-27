import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import styles 1.0 as Styles

ApplicationWindow {
    id: app
    width: 1280
    height: 900
    minimumWidth: 1024
    minimumHeight: 720
    visible: true
    title: qsTr("Noah Planner")
    color: Styles.ThemeStore.colors.appBg

    Component.onCompleted: {
        toasts.show("Hello, Noah!", 1200)
    }

    Connections {
        target: PlannerBackend
        function onDarkThemeChanged() {
            app.color = Styles.ThemeStore.colors.appBg
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
