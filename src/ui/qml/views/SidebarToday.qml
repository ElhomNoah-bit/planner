import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Item {
    id: root
    implicitWidth: Styles.ThemeStore.layout.sidebarW
    Layout.preferredWidth: Styles.ThemeStore.layout.sidebarW
    property var todayEvents: planner && planner.today ? planner.today : []
    property var upcomingEvents: planner && planner.upcoming ? planner.upcoming : []
    property var examEvents: planner && planner.exams ? planner.exams : []
    property var urgentEvents: planner && planner.urgent ? planner.urgent : []
    property var focusHistory: planner && planner.focusHistory ? planner.focusHistory : []
    property var focusSession: planner && planner.focusSession ? planner.focusSession : ({})
    property bool focusActive: planner && planner.focusSessionActive
    property int focusStreak: planner && planner.focusStreak ? planner.focusStreak : 0
    property var pomodoroState: planner && planner.pomodoro ? planner.pomodoro : ({})
    property bool zenMode: false

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject radii: Styles.ThemeStore.radii
    readonly property QtObject fonts: Styles.ThemeStore.fonts

    function doneCount(events) {
        var count = 0
        if (!events)
            return 0
        for (var i = 0; i < events.length; ++i) {
            if (events[i] && events[i].isDone)
                count += 1
        }
        return count
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.implicitHeight
        clip: true

        ColumnLayout {
            id: contentColumn
            width: flick.width
            spacing: gaps.g16

            GlassPanel {
                visible: urgentEvents.length > 0
                Layout.fillWidth: true
                padding: gaps.g16

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: gaps.g12

                    Label {
                        text: qsTr("Dringend")
                        font.pixelSize: typeScale.sm
                        font.weight: typeScale.weightBold
                        font.family: fonts.heading
                        color: colors.text
                        renderType: Text.NativeRendering
                    }

                    Repeater {
                        model: urgentEvents
                        delegate: EventChip {
                            Layout.fillWidth: true
                            label: modelData.title || ""
                            subjectColor: modelData.colorHint || colors.accent
                            timeText: modelData.startTimeLabel || ""
                            deadlineSeverity: modelData.deadlineSeverity || ""
                            deadlineLevel: modelData.deadlineLevel || 0
                            overdue: modelData.overdue || false
                            muted: false
                            categoryColor: modelData.categoryColor || ""
                            draggable: false
                        }
                    }
                }
            }

            GlassPanel {
                visible: planner && planner.dueReviewCount > 0
                Layout.fillWidth: true
                padding: gaps.g16

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: gaps.g12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: gaps.g8

                        Label {
                            text: qsTr("Wiederholungen")
                            font.pixelSize: typeScale.sm
                            font.weight: typeScale.weightBold
                            font.family: fonts.heading
                            color: colors.text
                            renderType: Text.NativeRendering
                        }

                        Item { Layout.fillWidth: true }

                        ReviewIndicator {
                            dueCount: planner ? planner.dueReviewCount : 0
                            onClicked: app.openReviewDialog()
                        }
                    }

                    Text {
                        text: planner && planner.dueReviewCount > 0
                              ? qsTr("%1 %2 fällig heute").arg(planner.dueReviewCount).arg(planner.dueReviewCount === 1 ? "Review" : "Reviews")
                              : qsTr("Keine Reviews fällig")
                        font.pixelSize: typeScale.sm
                        font.weight: typeScale.weightRegular
                        font.family: fonts.body
                        color: colors.text2
                        renderType: Text.NativeRendering
                    }

                    PillButton {
                        text: qsTr("🔄 Reviews öffnen")
                        kind: "ghost"
                        Layout.alignment: Qt.AlignLeft
                        onClicked: app.openReviewDialog()
                    }
                }
            }

            GlassPanel {
                Layout.fillWidth: true
                padding: gaps.g16

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: gaps.g12

                    Label {
                        text: qsTr("Fokus & Streak")
                        font.pixelSize: typeScale.sm
                        font.weight: typeScale.weightBold
                        font.family: fonts.heading
                        color: colors.text
                        renderType: Text.NativeRendering
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: gaps.g16

                        StreakBadge {
                            streak: focusStreak
                            Layout.alignment: Qt.AlignLeft
                        }

                        PomodoroStats {
                            state: pomodoroState || {}
                            Layout.alignment: Qt.AlignLeft
                        }

                        Item { Layout.fillWidth: true }
                    }

                    WeeklyHeatmap {
                        entries: focusHistory
                        Layout.fillWidth: true
                        visible: focusHistory && focusHistory.length > 0
                    }

                    FocusControls {
                        planner: planner
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: gaps.g8

                        Text {
                            text: focusSession && focusSession.lastMinutes
                                  ? qsTr("Letzte Sitzung: %1 Minuten").arg(focusSession.lastMinutes)
                                  : ""
                            font.pixelSize: typeScale.xs
                            font.family: fonts.body
                            color: colors.text2
                            Layout.alignment: Qt.AlignVCenter
                            visible: text.length > 0
                        }

                        Item { Layout.fillWidth: true }

                        PillButton {
                            text: qsTr("🍅 Pomodoro")
                            kind: "ghost"
                            onClicked: app.togglePomodoroOverlay(true)
                        }
                    }
                }
            }

            GlassPanel {
                Layout.fillWidth: true
                padding: gaps.g16
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: gaps.g12

                    Label {
                        text: qsTr("Heute")
                        font.pixelSize: typeScale.lg
                        font.weight: typeScale.weightBold
                        font.family: fonts.heading
                        color: colors.text
                        renderType: Text.NativeRendering
                    }

                    Label {
                        text: todayEvents.length > 0
                              ? qsTr("%1 von %2 erledigt").arg(doneCount(todayEvents)).arg(todayEvents.length)
                              : qsTr("Keine Aufgaben")
                        font.pixelSize: typeScale.sm
                        font.weight: typeScale.weightRegular
                        font.family: fonts.body
                        color: colors.text2
                        renderType: Text.NativeRendering
                    }

                    Repeater {
                        model: todayEvents
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            spacing: gaps.g8

                            Rectangle {
                                width: 6
                                Layout.preferredHeight: 32
                                radius: 3
                                color: modelData && modelData.colorHint && modelData.colorHint.length
                                       ? modelData.colorHint
                                       : colors.accent
                            }

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: {
                                    if (!modelData) return colors.prioLow
                                    const priority = modelData.priority || 0
                                    if (priority === 2) return colors.prioHigh
                                    if (priority === 1) return colors.prioMedium
                                    return colors.prioLow
                                }
                                visible: modelData && !modelData.isDone
                                Layout.alignment: Qt.AlignVCenter
                            }

                            CheckBox {
                                visible: true
                                checked: modelData && modelData.isDone
                                focusPolicy: Qt.NoFocus
                                onToggled: planner.setEventDone(modelData.id, checked)
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: gaps.g4

                                Text {
                                    text: modelData && modelData.title ? modelData.title : ""
                                    font.pixelSize: typeScale.sm
                                    font.weight: typeScale.weightMedium
                                    font.family: fonts.heading
                                    color: colors.text
                                    elide: Text.ElideRight
                                    renderType: Text.NativeRendering
                                }

                                Text {
                                    text: {
                                        var time = modelData.startTimeLabel || ""
                                        var date = modelData.dateLabel || ""
                                        if (time.length && date.length)
                                            return time + " • " + date
                                        if (time.length)
                                            return time
                                        return date
                                    }
                                    visible: text.length > 0
                                    font.pixelSize: typeScale.xs
                                    font.weight: typeScale.weightRegular
                                    font.family: fonts.body
                                    color: colors.text2
                                    renderType: Text.NativeRendering
                                }

                                Text {
                                    text: {
                                        var parts = []
                                        if (modelData.location && modelData.location.length)
                                            parts.push(modelData.location)
                                        if (modelData.tags && modelData.tags.length)
                                            parts.push(modelData.tags.join(', '))
                                        return parts.join(" • ")
                                    }
                                    visible: text.length > 0
                                    font.pixelSize: typeScale.xs
                                    font.weight: typeScale.weightRegular
                                    font.family: fonts.body
                                    color: colors.text2
                                    opacity: 0.8
                                    elide: Text.ElideRight
                                    renderType: Text.NativeRendering
                                }
                            }
                        }
                    }
                }
            }

            GlassPanel {
                Layout.fillWidth: true
                padding: gaps.g16
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: gaps.g12

                    Label {
                        text: qsTr("Nächste Aufgaben")
                        font.pixelSize: typeScale.sm
                        font.weight: typeScale.weightBold
                        font.family: fonts.heading
                        color: colors.text
                        renderType: Text.NativeRendering
                    }

                    Loader {
                        active: upcomingEvents && upcomingEvents.length > 0
                        sourceComponent: Component {
                            ColumnLayout {
                                spacing: gaps.g12
                                Repeater {
                                    model: upcomingEvents
                                    delegate: RowLayout {
                                        Layout.fillWidth: true
                                        spacing: gaps.g8

                                        Rectangle {
                                            width: 6
                                            Layout.preferredHeight: 32
                                            radius: 3
                                            color: modelData && modelData.colorHint && modelData.colorHint.length
                                                   ? modelData.colorHint
                                                   : colors.accent
                                        }

                                        Rectangle {
                                            width: 8
                                            height: 8
                                            radius: 4
                                            color: {
                                                if (!modelData) return colors.prioLow
                                                const priority = modelData.priority || 0
                                                if (priority === 2) return colors.prioHigh
                                                if (priority === 1) return colors.prioMedium
                                                return colors.prioLow
                                            }
                                            visible: modelData && !modelData.isDone
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        CheckBox {
                                            visible: true
                                            checked: modelData && modelData.isDone
                                            focusPolicy: Qt.NoFocus
                                            onToggled: planner.setEventDone(modelData.id, checked)
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: gaps.g4

                                            Text {
                                                text: modelData && modelData.title ? modelData.title : ""
                                                font.pixelSize: typeScale.sm
                                                font.weight: typeScale.weightMedium
                                                font.family: fonts.heading
                                                color: colors.text
                                                elide: Text.ElideRight
                                                renderType: Text.NativeRendering
                                            }

                                            Text {
                                                text: {
                                                    var time = modelData.startTimeLabel || ""
                                                    var date = modelData.dateLabel || ""
                                                    if (time.length && date.length)
                                                        return time + " • " + date
                                                    if (date.length)
                                                        return date
                                                    return time
                                                }
                                                visible: text.length > 0
                                                font.pixelSize: typeScale.xs
                                                font.weight: typeScale.weightRegular
                                                font.family: fonts.body
                                                color: colors.text2
                                                renderType: Text.NativeRendering
                                            }

                                            Text {
                                                text: {
                                                    var parts = []
                                                    if (modelData.location && modelData.location.length)
                                                        parts.push(modelData.location)
                                                    if (modelData.tags && modelData.tags.length)
                                                        parts.push(modelData.tags.join(', '))
                                                    return parts.join(" • ")
                                                }
                                                visible: text.length > 0
                                                font.pixelSize: typeScale.xs
                                                font.weight: typeScale.weightRegular
                                                font.family: fonts.body
                                                color: colors.text2
                                                opacity: 0.8
                                                elide: Text.ElideRight
                                                renderType: Text.NativeRendering
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Label {
                        visible: !upcomingEvents || upcomingEvents.length === 0
                        text: qsTr("Keine Einträge")
                        font.pixelSize: typeScale.xs
                        font.weight: typeScale.weightRegular
                        font.family: fonts.body
                        color: colors.text2
                        renderType: Text.NativeRendering
                    }
                }
            }

            GlassPanel {
                Layout.fillWidth: true
                padding: gaps.g16
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: gaps.g12

                    Label {
                        text: qsTr("Klassenarbeiten")
                        font.pixelSize: typeScale.sm
                        font.weight: typeScale.weightBold
                        font.family: fonts.heading
                        color: colors.text
                        renderType: Text.NativeRendering
                    }

                    Loader {
                        active: examEvents && examEvents.length > 0
                        sourceComponent: Component {
                            ColumnLayout {
                                spacing: gaps.g12
                                Repeater {
                                    model: examEvents
                                    delegate: RowLayout {
                                        Layout.fillWidth: true
                                        spacing: gaps.g8

                                        Rectangle {
                                            width: 6
                                            Layout.preferredHeight: 32
                                            radius: 3
                                            color: colors.accent
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: gaps.g4

                                            Text {
                                                text: modelData && modelData.title ? modelData.title : ""
                                                font.pixelSize: typeScale.sm
                                                font.weight: typeScale.weightMedium
                                                font.family: fonts.heading
                                                color: colors.text
                                                elide: Text.ElideRight
                                                renderType: Text.NativeRendering
                                            }

                                            Text {
                                                text: modelData && modelData.dateLabel ? modelData.dateLabel : ""
                                                font.pixelSize: typeScale.xs
                                                font.weight: typeScale.weightRegular
                                                font.family: fonts.body
                                                color: colors.text2
                                                renderType: Text.NativeRendering
                                            }

                                            Text {
                                                text: {
                                                    var parts = []
                                                    if (modelData.location && modelData.location.length)
                                                        parts.push(modelData.location)
                                                    if (modelData.tags && modelData.tags.length)
                                                        parts.push(modelData.tags.join(', '))
                                                    return parts.join(" • ")
                                                }
                                                visible: text.length > 0
                                                font.pixelSize: typeScale.xs
                                                font.weight: typeScale.weightRegular
                                                font.family: fonts.body
                                                color: colors.text2
                                                opacity: 0.8
                                                elide: Text.ElideRight
                                                renderType: Text.NativeRendering
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Label {
                        visible: !examEvents || examEvents.length === 0
                        text: qsTr("Keine Einträge")
                        font.pixelSize: typeScale.xs
                        font.weight: typeScale.weightRegular
                        font.family: fonts.body
                        color: colors.text2
                        renderType: Text.NativeRendering
                    }
                }
            }
        }

        ScrollIndicator.vertical: ScrollIndicator { }
    }

    Connections {
        target: planner
        function onTodayEventsChanged() {
            root.todayEvents = planner.today || []
        }
        function onUpcomingEventsChanged() {
            root.upcomingEvents = planner.upcoming || []
        }
        function onExamEventsChanged() {
            root.examEvents = planner.exams || []
        }
    }
}
