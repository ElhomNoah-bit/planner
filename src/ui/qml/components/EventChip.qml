import QtQuick
import QtQuick.Layouts
import Styles 1.0 as Styles

Rectangle {
    id: chip
    property string label: ""
    property color subjectColor: Styles.ThemeStore.colors.accent
    property bool muted: false
    property bool overdue: false
    property string timeText: ""
    property bool timed: timeText.length > 0
    property string categoryColor: ""
    property string deadlineSeverity: ""
    property int deadlineLevel: 0

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject radii: Styles.ThemeStore.radii
    readonly property QtObject gaps: Styles.ThemeStore.gap

    property string resolvedCategoryColor: (typeof categoryColor === "string" && categoryColor.length) ? categoryColor : ""
    property color resolvedSubjectColor: (subjectColor && subjectColor !== "") ? subjectColor : (colors ? colors.accent : "#3B82F6")
    property color chipBg: resolvedCategoryColor.length > 0
                              ? Qt.lighter(resolvedCategoryColor, 1.3)
                              : (muted ? (colors ? colors.cardAlt : "#1C222B") : (colors ? colors.cardBg : "#171B22"))
    property color chipFg: muted ? (colors ? colors.text2 : "#AFB8C5") : (colors ? colors.textPrimary : "#FFFFFF")
    property real chipAlpha: enabled === false ? 0.5 : 1.0
    property real chipRadius: radii ? radii.md : 10

    readonly property color urgencyColor: deadlineSeverity === "overdue" ? Styles.ThemeStore.colors.overdue
                                         : deadlineSeverity === "danger" ? Styles.ThemeStore.colors.danger
                                         : deadlineSeverity === "warn" ? Styles.ThemeStore.colors.warn
                                         : Styles.ThemeStore.colors.accent

    readonly property bool urgent: deadlineLevel > 0

    // Drag & Drop properties
    property string entryId: ""
    property string startIso: ""
    property string endIso: ""
    property bool allDay: false
    property bool draggable: entryId.length > 0
    
    signal dragStarted(string entryId, string startIso, string endIso, bool allDay)
    signal dragFinished()

    implicitHeight: 26
    implicitWidth: Math.max(92, contentRow.implicitWidth + (gaps ? gaps.g16 : 16))
    radius: chipRadius
    color: chipBg
    border.width: resolvedCategoryColor.length > 0 ? 2 : (urgent ? 2 : (overdue ? 1 : 0))
    border.color: resolvedCategoryColor.length > 0 ? resolvedCategoryColor : (urgent ? urgencyColor : (overdue ? (colors ? colors.danger : "#F97066") : "transparent"))

    opacity: dragHandler.active ? 0.5 : chipAlpha

    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
    }

    Rectangle {
        anchors.fill: parent
        radius: chipRadius
        color: urgencyColor
        opacity: urgent ? 0.12 : 0
        visible: urgent
    }

    RowLayout {
        id: contentRow
        anchors.fill: parent
    anchors.margins: gaps ? gaps.g12 : 12
    spacing: gaps ? gaps.g8 : 8

        Rectangle {
            width: timed ? 6 : 0
            height: timed ? 6 : 0
            radius: 3
            color: muted ? (colors ? colors.divider : "#2A3340") : resolvedSubjectColor
            visible: timed
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                visible: timed
                text: chip.timeText
                font.pixelSize: Styles.ThemeStore.type.xs
                font.weight: Styles.ThemeStore.type.weightMedium
                font.family: Styles.ThemeStore.fonts.uiFallback
                color: chipFg
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }

            Text {
                id: labelText
                text: chip.label
                color: chipFg
                font.pixelSize: Styles.ThemeStore.type.sm
                font.weight: Styles.ThemeStore.type.weightMedium
                font.family: Styles.ThemeStore.fonts.heading
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                renderType: Text.NativeRendering
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: chipRadius
    color: colors ? colors.hover : Qt.rgba(1, 1, 1, 0.05)
        visible: hoverHandler.hovered && !dragHandler.active
        opacity: 0.2
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: chip.draggable ? Qt.OpenHandCursor : Qt.ArrowCursor
        enabled: !dragHandler.active
    }
    
    DragHandler {
        id: dragHandler
        enabled: chip.draggable
        cursorShape: Qt.ClosedHandCursor
        
        onActiveChanged: {
            if (active) {
                chip.dragStarted(chip.entryId, chip.startIso, chip.endIso, chip.allDay)
            } else {
                chip.dragFinished()
            }
        }
        
        onGrabChanged: function(transition, point) {
            if (transition === PointerDevice.CancelGrabExclusive) {
                console.log("Drag cancelled")
            }
        }
    }
    
    Drag.active: dragHandler.active
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2
    Drag.mimeData: { 
        "text/plain": chip.entryId,
        "application/x-planner-entry": JSON.stringify({
            id: chip.entryId,
            startIso: chip.startIso,
            endIso: chip.endIso,
            allDay: chip.allDay,
            label: chip.label
        })
    }
}
