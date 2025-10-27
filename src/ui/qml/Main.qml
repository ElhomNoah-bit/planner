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
    readonly property var layout: theme ? theme.layout : null

    readonly property var summaryToday: PlannerBackend.daySummary(selectedIso)
    readonly property string headerSubtitle: summaryToday.total > 0
        ? qsTr("%1 von %2 Aufgaben erledigt").arg(summaryToday.done).arg(summaryToday.total)
        : qsTr("Keine Aufgaben für diesen Tag")
    readonly property var radii: theme ? theme.radii : null

    Rectangle {
        anchors.fill: parent
        color: colors ? colors.bg : "#0B0C0F"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: layout ? layout.margin : (space ? space.gap24 : 24)
        spacing: space ? space.gap16 : 16

        GlassPanel {
            id: navBar
            Layout.fillWidth: true
            padding: space ? space.gap20 : 20

            RowLayout {
                anchors.fill: parent
                spacing: space ? space.gap16 : 16

                Column {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: space ? space.gap4 : 4

                    Row {
                        spacing: space ? space.gap8 : 8

                        Text {
                            text: Qt.formatDate(selectedDateObj, "MMMM yyyy")
                            font.pixelSize: typeScale ? typeScale.monthTitleSize : 28
                            font.weight: typeScale ? typeScale.weightMedium : Font.DemiBold
                            font.letterSpacing: 0.2
                            font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                            color: colors ? colors.text : "#FFFFFF"
                            renderType: Text.NativeRendering
                        }

                        Row {
                            spacing: space ? space.gap4 : 4

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
                        font.pixelSize: typeScale ? typeScale.metaSize : 12
                        font.weight: typeScale ? typeScale.metaWeight : Font.Normal
                        font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                        color: theme && theme.text ? theme.text.secondary : "#A3ACB8"
                        opacity: 0.9
                        renderType: Text.NativeRendering
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    implicitHeight: 0

                    SegmentedControl {
                        id: segmented
                        anchors.horizontalCenter: parent.horizontalCenter
                        value: currentView
                        onValueChanged: PlannerBackend.viewMode = value
                        width: 260
                        implicitHeight: layout ? layout.pillH : 30
                    }
                }

                RowLayout {
                    spacing: space ? space.gap12 : 12
                    Layout.alignment: Qt.AlignVCenter

                    GlassPanel {
                        id: searchPill
                        padding: 0
                        implicitHeight: layout ? layout.pillH : 30
                        Layout.preferredWidth: 220
                        Layout.alignment: Qt.AlignVCenter

                        TextField {
                            anchors.fill: parent
                            anchors.margins: 12
                            placeholderText: qsTr("Suche…")
                            text: PlannerBackend.searchQuery
                            onTextChanged: PlannerBackend.searchQuery = text
                            font.pixelSize: typeScale ? typeScale.md : 15
                            font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                            color: colors ? colors.text : "#FFFFFF"
                            renderType: Text.NativeRendering
                            background: Rectangle { color: "transparent" }
                            leftPadding: 0
                            rightPadding: 0
                            cursorDelegate: Rectangle { width: 2; color: theme ? theme.accent.base : "#0A84FF" }
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
            kind: "neutral"
            checked: PlannerBackend.onlyOpen
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
                    onLoaded: {
                        if (item) {
                            item.opacity = 0
                            item.anchors.fill = parent
                            fadeIn.target = item
                            fadeIn.start()
                        }
                    }
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
                Layout.preferredWidth: layout ? layout.sidebarW : 340
                Layout.minimumWidth: layout ? layout.sidebarW : 320
                Layout.fillHeight: true
                onStartTimerRequested: minutes => timerOverlay.openTimer(minutes)
            }
        }
    }

    NumberAnimation {
        id: fadeIn
        property: "opacity"
        duration: 150
        easing.type: Easing.InOutQuad
        from: 0
        to: 1
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
