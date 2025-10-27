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

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject metrics: Styles.ThemeStore.layout

    readonly property var selectedDateObj: selectedIso.length > 0 ? new Date(selectedIso) : new Date()
    readonly property var summaryToday: PlannerBackend.daySummary(selectedIso)
    readonly property string headerSubtitle: summaryToday.total > 0
        ? qsTr("%1 von %2 Aufgaben erledigt").arg(summaryToday.done).arg(summaryToday.total)
        : qsTr("Keine Aufgaben für diesen Tag")

    Rectangle {
        anchors.fill: parent
        color: colors.appBg
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: metrics.margin
        spacing: gaps.g16

        Item {
            Layout.fillWidth: true
            height: metrics.headerH

            GlassPanel {
                anchors.fill: parent
                padding: gaps.g16

                RowLayout {
                    anchors.fill: parent
                    spacing: gaps.g16

                    ColumnLayout {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: gaps.g8

                        RowLayout {
                            spacing: gaps.g12
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: Qt.formatDate(selectedDateObj, "MMMM yyyy")
                                font.pixelSize: typeScale.monthTitle
                                font.weight: typeScale.weightMedium
                                font.family: Styles.ThemeStore.fonts.uiFallback
                                color: colors.text
                                renderType: Text.NativeRendering
                            }

                            RowLayout {
                                spacing: gaps.g8

                                PillButton {
                                    kind: "ghost"
                                    icon.name: "chevron.backward"
                                    onClicked: root.shiftMonth(-1)
                                    Accessible.name: qsTr("Voriger Monat")
                                }

                                PillButton {
                                    kind: "ghost"
                                    icon.name: "chevron.forward"
                                    onClicked: root.shiftMonth(1)
                                    Accessible.name: qsTr("Nächster Monat")
                                }

                                PillButton {
                                    kind: "ghost"
                                    text: qsTr("Heute")
                                    onClicked: PlannerBackend.refreshToday()
                                }
                            }
                        }

                        Text {
                            text: headerSubtitle
                            font.pixelSize: typeScale.xs
                            font.weight: typeScale.weightRegular
                            font.family: Styles.ThemeStore.fonts.uiFallback
                            color: colors.text2
                            renderType: Text.NativeRendering
                        }
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: gaps.g12
                        Layout.alignment: Qt.AlignVCenter

                        SegmentedControl {
                            id: segmented
                            value: currentView
                            onValueChanged: PlannerBackend.viewMode = value
                        }

                        GlassPanel {
                            padding: 0
                            implicitHeight: metrics.pillH
                            Layout.preferredWidth: 220
                            Layout.alignment: Qt.AlignVCenter

                            TextField {
                                anchors.fill: parent
                                anchors.margins: gaps.g12
                                placeholderText: qsTr("Suche…")
                                text: PlannerBackend.searchQuery
                                onTextChanged: PlannerBackend.searchQuery = text
                                font.pixelSize: typeScale.md
                                font.family: Styles.ThemeStore.fonts.uiFallback
                                color: colors.text
                                background: Rectangle { color: "transparent" }
                                leftPadding: 0
                                rightPadding: 0
                                cursorDelegate: Rectangle { width: 2; color: colors.accent }
                            }
                        }

                        PillButton {
                            kind: "ghost"
                            icon.name: darkTheme ? "sun.max" : "moon"
                            onClicked: PlannerBackend.darkTheme = !PlannerBackend.darkTheme
                        }

                        PillButton {
                            kind: "primary"
                            icon.name: "plus"
                            text: qsTr("Neu")
                            onClicked: quickAdd.focusInput()
                        }
                    }
                }
            }
        }

        QuickAddPill {
            id: quickAdd
            Layout.fillWidth: true
            onSubmitted: PlannerBackend.quickAdd(text)
        }

        Flow {
            Layout.fillWidth: true
            spacing: gaps.g8
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
            kind: "neutral"
            checked: PlannerBackend.onlyOpen
            onClicked: PlannerBackend.onlyOpen = !PlannerBackend.onlyOpen
            Layout.alignment: Qt.AlignLeft
        }

        RowLayout {
            spacing: gaps.g24
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item {
                id: gridContainer
                Layout.fillWidth: true
                Layout.fillHeight: true

                StackLayout {
                    id: viewStack
                    anchors.fill: parent
                    currentIndex: root.currentView === "week" ? 1 : (root.currentView === "list" ? 2 : 0)

                    MonthView {
                        anchors.fill: parent
                        selectedIso: root.selectedIso
                        onDaySelected: iso => PlannerBackend.selectDateIso(iso)
                    }

                    WeekView {
                        anchors.fill: parent
                        anchorIso: root.selectedIso
                        onDaySelected: iso => PlannerBackend.selectDateIso(iso)
                    }

                    AgendaView {
                        anchors.fill: parent
                    }
                }
            }

            SidebarToday {
                Layout.preferredWidth: metrics.sidebarW
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
