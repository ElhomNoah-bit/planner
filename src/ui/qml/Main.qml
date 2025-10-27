import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import "styles" as Styles

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

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var space: theme ? theme.space : null
    readonly property var typeScale: theme ? theme.type : null
    readonly property var radii: theme ? theme.radii : null

    Rectangle {
        anchors.fill: parent
        color: colors ? colors.bg : "#0B0B0D"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: space ? space.gap24 : 24
        spacing: space ? space.gap16 : 16

        GlassPanel {
            id: navBar
            Layout.fillWidth: true
            padding: space ? space.gap12 : 12
            RowLayout {
                anchors.fill: parent
                spacing: space ? space.gap16 : 16

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
                    radius: radii ? radii.xl : 22
                    padding: 0
                    width: 220
                    TextField {
                        anchors.fill: parent
                        anchors.margins: 14
                        placeholderText: qsTr("Suche…")
                        text: PlannerBackend.searchQuery
                        onTextChanged: PlannerBackend.searchQuery = text
                        font.pixelSize: typeScale ? typeScale.md : 15
                        font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                        color: colors ? colors.text : "#FFFFFF"
                        background: Rectangle { color: "transparent" }
                        leftPadding: 0
                        rightPadding: 0
                        cursorDelegate: Rectangle { width: 2; color: colors ? colors.tint : "#0A84FF" }
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
            Layout.fillWidth: true
            font.pixelSize: typeScale ? typeScale.monthTitleSize : 28
            font.weight: typeScale ? typeScale.monthTitleWeight : Font.DemiBold
            font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
            color: colors ? colors.text : "#FFFFFF"
            opacity: 0.98
        }

        QuickAddPill {
            id: quickAdd
            Layout.fillWidth: true
            onSubmitted: PlannerBackend.quickAdd(text)
        }

        Flow {
            Layout.fillWidth: true
            spacing: space ? space.gap8 : 8
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
            Layout.alignment: Qt.AlignLeft
        }

        RowLayout {
            spacing: space ? space.gap24 : 24
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
                Layout.fillHeight: true
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
