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
    focus: true

    property string viewMode: "month"
    property bool onlyOpen: false
    property string searchQuery: ""

    function syncState() {
        viewMode = PlannerBackend.viewMode
        onlyOpen = PlannerBackend.onlyOpen
        searchQuery = PlannerBackend.searchQuery
        if (globalSearch)
            globalSearch.text = searchQuery
    }

    function goToday() {
        PlannerBackend.refreshToday()
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
        if (onlyOpen === next)
            return
        onlyOpen = next
        PlannerBackend.setOnlyOpen(next)
    }

    function createQuickItem(value) {
        PlannerBackend.quickAdd(value)
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
            setViewMode("month")
            break
        case "view-week":
            setViewMode("week")
            break
        case "view-list":
            setViewMode("list")
            break
        case "toggle-open":
            toggleOnlyOpen(!onlyOpen)
            break
        case "open-settings":
            settingsDialog.open()
            break
        default:
            break
        }
    }

    function setViewMode(mode) {
        if (viewMode === mode)
            return
        viewMode = mode
        PlannerBackend.setViewMode(mode)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Styles.ThemeStore.gap.g24
        spacing: Styles.ThemeStore.gap.g16

        RowLayout {
            id: topBar
            Layout.fillWidth: true
            spacing: Styles.ThemeStore.gap.g16

            SegmentedControl {
                id: viewSwitch
                Layout.preferredWidth: 320
                options: [
                    { "label": qsTr("Monat"), "value": "month" },
                    { "label": qsTr("Woche"), "value": "week" },
                    { "label": qsTr("Liste"), "value": "list" }
                ]
                value: app.viewMode
                onValueChanged: app.setViewMode(value)
            }

            PillButton {
                text: qsTr("Heute")
                kind: "ghost"
                onClicked: app.goToday()
            }

            PillButton {
                text: qsTr("+ Neu")
                kind: "primary"
                onClicked: app.quickAddOpen()
            }

            FilterPill {
                label: qsTr("Nur offene")
                active: app.onlyOpen
                onToggled: app.toggleOnlyOpen(!app.onlyOpen)
            }

            Item { Layout.fillWidth: true }

            SearchField {
                id: globalSearch
                Layout.preferredWidth: 280
                Layout.maximumWidth: 320
                placeholderText: qsTr("Suchen (Ctrl/Cmd+K)…")
                onAccepted: {
                    app.openCommandPalette(text)
                    clear()
                }
                onTextChanged: {
                    app.searchQuery = text
                    PlannerBackend.setSearchQuery(text)
                }
            }
        }

        Main {
            id: mainView
            Layout.fillWidth: true
            Layout.fillHeight: true
            viewMode: app.viewMode
            onlyOpen: app.onlyOpen
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
        onCommandTriggered: command => app.handleCommand(command)
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
        target: PlannerBackend
        function onDarkThemeChanged() {
            app.color = Styles.ThemeStore.colors.appBg
        }
        function onViewModeChanged() {
            viewMode = PlannerBackend.viewMode
        }
        function onFiltersChanged() {
            onlyOpen = PlannerBackend.onlyOpen
            searchQuery = PlannerBackend.searchQuery
            if (globalSearch)
                globalSearch.text = searchQuery
        }
    }

    Component.onCompleted: syncState()

    Keys.onPressed: function(event) {
        if (event.modifiers & (Qt.ControlModifier | Qt.MetaModifier)) {
            if (event.key === Qt.Key_K) {
                event.accepted = true
                openCommandPalette("")
                return
            }
        }
        switch (event.key) {
        case Qt.Key_N:
            event.accepted = true
            quickAddOpen()
            break
        case Qt.Key_T:
            event.accepted = true
            goToday()
            break
        case Qt.Key_M:
            event.accepted = true
            setViewMode("month")
            break
        case Qt.Key_W:
            event.accepted = true
            setViewMode("week")
            break
        case Qt.Key_L:
            event.accepted = true
            setViewMode("list")
            break
        default:
            break
        }
    }
}
