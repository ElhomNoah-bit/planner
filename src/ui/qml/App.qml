import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import Styles 1.0

ApplicationWindow {
    id: app
    width: 1280
    height: 900
    minimumWidth: 1024
    minimumHeight: 720
    visible: true
    title: qsTr("Noah Planner")
    color: ThemeStore.surface

    Shortcut {
        id: shortcutCommandPalette
        sequences: [ StandardKey.Find, "Ctrl+K", "Meta+K" ]
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: app.openCommandPalette("")
    }

    Shortcut {
        sequences: [ StandardKey.New, "Ctrl+N" ]
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: app.quickAddOpen()
    }

    Shortcut {
        sequences: [ "Ctrl+T", "Meta+T" ]
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: app.goToday()
    }

    Shortcut {
        sequences: [ "Ctrl+1", "Meta+1" ]
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: planner.setViewMode(0)
    }

    Shortcut {
        sequences: [ "Ctrl+2", "Meta+2" ]
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: planner.setViewMode(1)
    }

    Shortcut {
        sequences: [ "Ctrl+3", "Meta+3" ]
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: planner.setViewMode(2)
    }

    Shortcut {
        sequences: [ "Ctrl+.", "Meta+." ]
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: app.toggleZenMode()
    }

    Shortcut {
        sequences: [ "Ctrl+P", "Meta+P" ]
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: app.togglePomodoroOverlay()
    }

    Shortcut {
        sequences: [ "Ctrl+R", "Meta+R" ]
        context: Qt.ApplicationShortcut
        enabled: app.visible
        onActivated: app.openReviewDialog()
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

    function createQuickItem(payload) {
        if (typeof payload === "string") {
            planner.addQuickEntry(payload)
            return
        }

        if (!payload || !payload.text || !payload.text.length) {
            return
        }

        var created = planner.addQuickEntry(payload.text)
        if (created && created.id && payload.categoryId && payload.categoryId.length) {
            planner.setEntryCategory(created.id, payload.categoryId)
        }
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
            planner.setViewMode(0)
            break
        case "view-week":
            planner.setViewMode(1)
            break
        case "view-list":
            planner.setViewMode(2)
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
        case "start-focus":
            app.startDefaultFocusSession()
            break
        case "open-pomodoro":
            app.togglePomodoroOverlay(true)
            break
        case "export-week":
            app.openExportDialog("week")
            break
        case "export-month":
            app.openExportDialog("month")
            break
        case "open-reviews":
            app.openReviewDialog()
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

    function startDefaultFocusSession() {
        planner.startFocusMinutes(25)
    }

    function togglePomodoroOverlay(forceOpen) {
        if (forceOpen === true) {
            pomodoroOverlay.open = true
            return
        }
        if (forceOpen === false) {
            pomodoroOverlay.open = false
            return
        }
        pomodoroOverlay.open = !pomodoroOverlay.open
    }

    function openExportDialog(mode) {
        exportDialog.open(mode || "week")
    }

    function openReviewDialog() {
        reviewDialog.open()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: ThemeStore.gapXl
        spacing: ThemeStore.gapLg

        RowLayout {
            id: topBar
            Layout.fillWidth: true
            spacing: ThemeStore.gapMd

            SegmentedControl {
                id: viewSwitch
                Layout.preferredWidth: 320
                Layout.preferredHeight: ThemeStore.layout.pillH
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
        onAccepted: function(payload) { app.createQuickItem(payload) }
    }

    CommandPalette {
        id: commandPalette
        anchors.fill: parent
    }

    SettingsDialog {
        id: settingsDialog
        anchors.centerIn: parent
    }

    ExportDialog {
        id: exportDialog
        planner: planner
        onFinished: function(success) {
            if (success)
                planner.showToast(qsTr("Export erstellt"))
            else
                planner.showToast(qsTr("Export fehlgeschlagen"))
        }
    }

    ReviewDialog {
        id: reviewDialog
        backend: planner
        anchors.centerIn: parent
    }

    PomodoroOverlay {
        id: pomodoroOverlay
        planner: planner
        open: false
        anchors.fill: parent
    }

    ToastHost {
        id: toasts
        anchors.fill: parent
    }

    Connections {
        target: planner
        function onDarkThemeChanged() {
            app.color = ThemeStore.surface
        }
        function onSearchQueryChanged() {
            if (globalSearch && globalSearch.text !== planner.searchQuery) {
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
