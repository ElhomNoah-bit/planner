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
    property var urgentEvents: planner && planner.urgentEvents ? planner.urgentEvents : []
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
                Layout.fillWidth: true
                padding: gaps.g16
                visible: planner.stressIndicatorEnabled && urgentEvents.length > 0
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: gaps.g12

                    RowLayout {
                        spacing: gaps.g8
                        
                        Text {
                            text: "⚠️"
                            font.pixelSize: typeScale.md
                            renderType: Text.NativeRendering
                        }
                        
                        Label {
                            text: qsTr("Dringend")
                            font.pixelSize: typeScale.lg
                            font.weight: typeScale.weightBold
                            font.family: fonts.heading
                            color: colors.overdue
                            renderType: Text.NativeRendering
                        }
                    }

                    Label {
                        text: qsTr("%1 Aufgabe(n) mit nahender oder überfälliger Deadline").arg(urgentEvents.length)
                        font.pixelSize: typeScale.sm
                        font.weight: typeScale.weightRegular
                        font.family: fonts.body
                        color: colors.text2
                        renderType: Text.NativeRendering
                    }

                    Repeater {
                        model: urgentEvents
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            spacing: gaps.g8

                            Rectangle {
                                width: 6
                                Layout.preferredHeight: 32
                                radius: 3
                                color: {
                                    if (modelData.deadlineSeverityString === "overdue") return colors.overdue
                                    if (modelData.deadlineSeverityString === "danger") return colors.danger
                                    if (modelData.deadlineSeverityString === "warn") return colors.warn
                                    return colors.accent
                                }
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
                                    color: {
                                        if (modelData.deadlineSeverityString === "overdue") return colors.overdue
                                        if (modelData.deadlineSeverityString === "danger") return colors.danger
                                        return colors.text2
                                    }
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
        function onUrgentEventsChanged() {
            root.urgentEvents = planner.urgentEvents || []
        }
    }
}
