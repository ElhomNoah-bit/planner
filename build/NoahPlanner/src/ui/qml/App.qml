import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import "styles" as Styles

ApplicationWindow {
    id: app
    width: 1280
    height: 900
    minimumWidth: 1024
    minimumHeight: 720
    visible: true
    title: qsTr("Noah Planner")
    color: Styles.ThemeStore && Styles.ThemeStore.colors ? Styles.ThemeStore.colors.bg : "#0B0B0D"

    Component.onCompleted: {
        toasts.show("Hello, Noah!", 1200)
    }

    Connections {
        target: PlannerBackend
        function onDarkThemeChanged() {
            if (Styles.ThemeStore && Styles.ThemeStore.colors) {
                app.color = Styles.ThemeStore.colors.bg
            }
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
