import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

ApplicationWindow {
    id: app
    width: 1280
    height: 900
    minimumWidth: 1024
    minimumHeight: 720
    visible: true
    title: qsTr("Noah Planner")
    color: Styles.ThemeStore.colors.appBg

    Shortcut {
        id: shortcutCommandPalette
        sequences: ["Ctrl+K", "Meta+K"]
        enabled: app.visible
        onActivated: app.openCommandPalette("")
    }

    Shortcut {
        sequence: StandardKey.New
        enabled: app.visible
        onActivated: app.quickAddOpen()
    }

    Shortcut {
        sequences: ["Ctrl+T", "Meta+T"]
        enabled: app.visible
        onActivated: app.goToday()
    }

    Shortcut {
        sequences: ["Ctrl+1", "Meta+1"]
        enabled: app.visible
        onActivated: planner.viewModeString = "month"
    }

    Shortcut {
        sequences: ["Ctrl+2", "Meta+2"]
        enabled: app.visible
        onActivated: planner.viewModeString = "week"
    }

    Shortcut {
        sequences: ["Ctrl+3", "Meta+3"]
        enabled: app.visible
        onActivated: planner.viewModeString = "list"
    }

    FocusScope {
        id: keyScope
        anchors.fill: parent
        focus: true
        z: -1

        Keys.onPressed: function(event) {
            if (!visible || event.isAutoRepeat)
                return
            if (event.modifiers !== Qt.NoModifier)
                return
            switch (event.key) {
            case Qt.Key_N:
                app.quickAddOpen()
                event.accepted = true
                break
            case Qt.Key_T:
                app.goToday()
                event.accepted = true
                break
            case Qt.Key_M:
                planner.viewModeString = "month"
                event.accepted = true
                break
            case Qt.Key_W:
                planner.viewModeString = "week"
                event.accepted = true
                break
            case Qt.Key_L:
                planner.viewModeString = "list"
                event.accepted = true
                break
            default:
                break
            }
        }
    }

    function goToday() {
        planner.refreshToday()
    }

    function quickAddOpen(initialText) {
        quickAddDialog.open(initialText || "")
    }

    function openQuickAddFor(kind, iso) {
        var date = iso && iso.length ? new Date(iso) : new Date()
        if (isNaN(date.getTime())) {
            quickAddOpen()
            return
        }
        var formatted = Qt.formatDate(date, "dd.MM.yyyy")
        var prefix = kind === "event"
                ? qsTr("Termin am %1 ").arg(formatted)
                : qsTr("Aufgabe am %1 ").arg(formatted)
        quickAddOpen(prefix)
    }

    function openCommandPalette(query) {
        commandPalette.open(query || "")
    }

    function toggleOnlyOpen(next) {
        if (planner.onlyOpen === next)
            return
        planner.onlyOpen = next
    }

    function createQuickItem(value) {
        planner.quickAdd(value)
    }

    function openSettings() {
        settingsDialog.open()
    }

    function handleCommand(command) {
        switch (command) {
        case "go-today":
            goToday()
            break
        case "new-item":
            quickAddOpen()
            break
        case "view-month":
            planner.viewModeString = "month"
            break
        case "view-week":
            planner.viewModeString = "week"
            break
        case "view-list":
            planner.viewModeString = "list"
            break
        case "toggle-open":
            planner.onlyOpen = !planner.onlyOpen
            break
        case "open-settings":
            settingsDialog.open()
            break
        default:
            break
        }
    }

    function setViewMode(mode) {
        if (planner.viewModeString === mode)
            return
        planner.viewModeString = mode
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.ThemeStore.gap.g24
        spacing: Styles.ThemeStore.gap.g16

        RowLayout {
            id: topBar
            Layout.fillWidth: true
            spacing: Styles.ThemeStore.gap.g12

            SegmentedControl {
                id: viewSwitch
                Layout.preferredWidth: 320
                Layout.preferredHeight: Styles.ThemeStore.layout.pillH
                Layout.alignment: Qt.AlignVCenter
                options: [
                    { "label": qsTr("Monat"), "value": "month" },
                    { "label": qsTr("Woche"), "value": "week" },
                    { "label": qsTr("Liste"), "value": "list" }
                ]
                currentIndex: planner.viewMode === PlannerBackend.Week ? 1
                               : planner.viewMode === PlannerBackend.List ? 2 : 0
                onActivated: (mode, index) => app.setViewMode(mode)
            }

            PillButton {
                text: qsTr("Heute")
                kind: "ghost"
                Layout.alignment: Qt.AlignVCenter
                onClicked: app.goToday()
            }

            PillButton {
                text: qsTr("+ Neu")
                kind: "primary"
                Layout.alignment: Qt.AlignVCenter
                onClicked: app.quickAddOpen()
            }

            FilterPill {
                label: qsTr("Nur offene")
                active: planner.onlyOpen
                Layout.alignment: Qt.AlignVCenter
                onToggled: app.toggleOnlyOpen(!planner.onlyOpen)
            }

            Item { Layout.fillWidth: true }

            SearchField {
                id: globalSearch
                Layout.preferredWidth: 280
                Layout.maximumWidth: 320
                Layout.alignment: Qt.AlignVCenter
                placeholderText: qsTr("Suchen (Ctrl/Cmd+K)…")
                onAccepted: {
                    app.openCommandPalette(text)
                    clear()
                }
                onTextChanged: {
                    if (planner.searchQuery !== text) {
                        planner.searchQuery = text
                    }
                }
            }
        }

        Main {
            id: mainView
            Layout.fillWidth: true
            Layout.fillHeight: true
            viewMode: planner.viewModeString
            onlyOpen: planner.onlyOpen
            onQuickAddRequested: (iso, kind) => app.openQuickAddFor(kind, iso)
            onJumpToTodayRequested: app.goToday()
        }
    }

    QuickAddDialog {
        id: quickAddDialog
        anchors.fill: parent
        onAccepted: function(value) { app.createQuickItem(value) }
    }

    CommandPalette {
        id: commandPalette
        anchors.fill: parent
    }

    SettingsDialog {
        id: settingsDialog
        anchors.centerIn: parent
    }

    ToastHost {
        id: toasts
        anchors.fill: parent
    }

    Connections {
        target: planner
        function onDarkThemeChanged() {
            app.color = Styles.ThemeStore.colors.appBg
        }
        function onFiltersChanged() {
            if (globalSearch) {
                globalSearch.text = planner.searchQuery
            }
        }
    }

    Component.onCompleted: {
        if (globalSearch) {
            globalSearch.text = planner.searchQuery
        }
        Qt.callLater(() => keyScope.forceActiveFocus())
    }

    Connections {
        target: commandPalette
        function onVisibleChanged() {
            if (!commandPalette.visible)
                Qt.callLater(() => keyScope.forceActiveFocus())
        }
    }

    Connections {
        target: quickAddDialog
        function onVisibleChanged() {
            if (!quickAddDialog.visible)
                Qt.callLater(() => keyScope.forceActiveFocus())
        }
    }

    Connections {
        target: settingsDialog
        function onVisibleChanged() {
            if (!settingsDialog.visible)
                Qt.callLater(() => keyScope.forceActiveFocus())
        }
    }
}
