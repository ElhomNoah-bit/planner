import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner 1.0 as NP

Item {
    id: root
    anchors.fill: parent

    property string selectedIso: PlannerBackend.selectedDate
    property string currentView: PlannerBackend.viewMode
    property bool darkTheme: PlannerBackend.darkTheme

    property var subjectsModel: PlannerBackend.subjects

    readonly property var selectedDateObj: selectedIso.length > 0 ? new Date(selectedIso) : new Date()
    readonly property string headlineMonth: Qt.formatDate(selectedDateObj, "MMMM")
    readonly property string headlineYear: Qt.formatDate(selectedDateObj, "yyyy")

    Rectangle {
        anchors.fill: parent
        color: NP.ThemeStore.bg
    }

    Column {
        anchors.fill: parent
        anchors.margins: 32
        spacing: NP.ThemeStore.spacing.gap24

        GlassPanel {
            id: navBar
            radius: NP.ThemeStore.radii.xl
            padding: 12
            RowLayout {
                anchors.fill: parent
                spacing: NP.ThemeStore.spacing.gap16

                PillButton {
                    icon.name: "chevron.backward"
                    text: headlineYear
                    accent: false
                    active: false
                    onClicked: root.shiftMonth(-1)
                }

                PillButton {
                    icon.name: "chevron.forward"
                    text: qsTr("Heute")
                    subtle: true
                    onClicked: PlannerBackend.refreshToday()
                }

                Item { Layout.fillWidth: true }

                PillButton {
                    icon.name: darkTheme ? "sun.max" : "moon"
                    subtle: true
                    onClicked: PlannerBackend.darkTheme = !PlannerBackend.darkTheme
                }

                SegmentedControl {
                    id: segmented
                    value: currentView
                    onValueChanged: PlannerBackend.viewMode = value
                }

                GlassPanel {
                    id: searchPill
                    radius: NP.ThemeStore.radii.xl
                    padding: 0
                    width: 220
                    TextField {
                        anchors.fill: parent
                        anchors.margins: 14
                        placeholderText: qsTr("Suche…")
                        text: PlannerBackend.searchQuery
                        onTextChanged: PlannerBackend.searchQuery = text
                        font.pixelSize: 14
                        font.preferredFamilies: NP.ThemeStore.fonts.stack
                        color: NP.ThemeStore.text
                        background: Rectangle { color: "transparent" }
                        leftPadding: 0
                        rightPadding: 0
                        cursorDelegate: Rectangle { width: 2; color: NP.ThemeStore.accent }
                    }
                }

                PillButton {
                    icon.name: "plus"
                    text: qsTr("Neu")
                    accent: true
                    onClicked: quickAdd.focusInput()
                }
            }
        }

        Text {
            text: headlineMonth
            font.pixelSize: NP.ThemeStore.typography.monthTitleSize
            font.weight: NP.ThemeStore.typography.monthTitleWeight
            font.preferredFamilies: NP.ThemeStore.fonts.stack
            color: NP.ThemeStore.text
            opacity: 0.98
        }

        QuickAddPill {
            id: quickAdd
            onSubmitted: PlannerBackend.quickAdd(text)
        }

        Flow {
            width: parent.width
            spacing: NP.ThemeStore.spacing.gap8
            Repeater {
                model: subjectsModel
                delegate: FilterPill {
                    label: modelData.name
                    subjectId: modelData.id
                    chipColor: modelData.color
                    active: modelData.active
                    onToggled: PlannerBackend.toggleSubject(modelData.id)
                }
            }
        }

        PillButton {
            text: qsTr("Nur offene")
            subtle: true
            active: PlannerBackend.onlyOpen
            onClicked: PlannerBackend.onlyOpen = !PlannerBackend.onlyOpen
        }

        RowLayout {
            spacing: NP.ThemeStore.spacing.gap24
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item {
                id: mainPane
                Layout.fillWidth: true
                Layout.fillHeight: true

                Loader {
                    id: viewLoader
                    anchors.fill: parent
                    sourceComponent: currentView === "week" ? weekComponent : (currentView === "list" ? listComponent : monthComponent)
                }

                Component {
                    id: monthComponent
                    MonthView {
                        selectedIso: root.selectedIso
                        onDaySelected: iso => PlannerBackend.selectDateIso(iso)
                    }
                }

                Component {
                    id: weekComponent
                    WeekView {
                        anchorIso: root.selectedIso
                        onDaySelected: iso => PlannerBackend.selectDateIso(iso)
                    }
                }

                Component {
                    id: listComponent
                    AgendaView {}
                }
            }

            SidebarToday {
                id: sidebar
                Layout.preferredWidth: 340
                Layout.minimumWidth: 320
                onStartTimerRequested: minutes => timerOverlay.openTimer(minutes)
            }
        }
    }

    TimerOverlay {
        id: timerOverlay
        function openTimer(minutes) {
            timerOverlay.minutes = minutes
            timerOverlay.open = true
        }
        onFinished: PlannerBackend.showToast(qsTr("Timer abgeschlossen"))
    }

    Connections {
        target: PlannerBackend
        function onSelectedDateChanged() {
            root.selectedIso = PlannerBackend.selectedDate
        }
        function onViewModeChanged() {
            root.currentView = PlannerBackend.viewMode
        }
        function onSubjectsChanged() {
            root.subjectsModel = PlannerBackend.subjects
        }
        function onFiltersChanged() {
            root.subjectsModel = PlannerBackend.subjects
        }
        function onDarkThemeChanged() {
            root.darkTheme = PlannerBackend.darkTheme
        }
    }

    Component.onCompleted: {
        root.subjectsModel = PlannerBackend.subjects
    }

    function shiftMonth(offset) {
        var d = new Date(selectedIso)
        d.setMonth(d.getMonth() + offset)
        var iso = Qt.formatDate(d, "yyyy-MM-dd")
        PlannerBackend.selectDateIso(iso)
    }
}
