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
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: app.openCommandPalette("")
    }

    Shortcut {
        sequence: StandardKey.New
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: app.quickAddOpen()
    }

    Shortcut {
        sequences: ["Ctrl+T", "Meta+T"]
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: app.goToday()
    }

    Shortcut {
        sequences: ["Ctrl+1", "Meta+1"]
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: planner.setViewMode("month")
    }

    Shortcut {
        sequences: ["Ctrl+2", "Meta+2"]
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: planner.setViewMode("week")
    }

    Shortcut {
        sequences: ["Ctrl+3", "Meta+3"]
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: planner.setViewMode("list")
    }

    Shortcut {
        sequences: ["Ctrl+.", "Meta+."]
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: app.toggleZenMode()
    }

    function goToday() {
        planner.jumpToToday()
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
        planner.addQuickEntry(value)
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
            planner.setViewMode("month")
            break
        case "view-week":
            planner.setViewMode("week")
            break
        case "view-list":
            planner.setViewMode("list")
            break
        case "toggle-open":
            planner.onlyOpen = !planner.onlyOpen
            break
        case "toggle-zen":
            app.toggleZenMode()
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
        planner.setViewMode(mode)
    }

    function toggleZenMode() {
        planner.zenMode = !planner.zenMode
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
                currentIndex: planner.viewModeString === "week" ? 1
                               : planner.viewModeString === "list" ? 2 : 0
                onActivated: (mode, index) => planner.setViewMode(mode)
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

            ZenToggleButton {
                id: zenToggle
                Layout.alignment: Qt.AlignVCenter
                active: planner.zenMode
                onToggled: app.toggleZenMode()
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
            zenMode: planner.zenMode
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
    }

    Connections {
        target: commandPalette
        function onVisibleChanged() {}
    }

    Connections {
        target: quickAddDialog
        function onVisibleChanged() {}
    }

    Connections {
        target: settingsDialog
        function onVisibleChanged() {}
    }
}
