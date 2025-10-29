import QtQuick
import QtQuick.Layouts
import NoahPlanner.Styles as Styles

Rectangle {
    id: chip
    property string label: ""
    property color subjectColor: Styles.ThemeStore.accent
    property bool muted: false
    property bool overdue: false
    property string timeText: ""
    property bool timed: timeText.length > 0
    property string categoryColor: ""
    
    // Drag & Drop properties
    property string entryId: ""
    property string startIso: ""
    property string endIso: ""
    property bool allDay: false
    property bool draggable: entryId.length > 0
    
    signal dragStarted(string entryId, string startIso, string endIso, bool allDay)
    signal dragFinished()

    implicitHeight: 26
    implicitWidth: Math.max(92, contentRow.implicitWidth + Styles.ThemeStore.g16)
    radius: Styles.ThemeStore.r12
    color: muted ? Styles.ThemeStore.cardAlt : Styles.ThemeStore.cardBg
    border.width: categoryColor.length > 0 ? 2 : (overdue ? 1 : 0)
    border.color: categoryColor.length > 0 ? categoryColor : (overdue ? Styles.ThemeStore.danger : "transparent")
    
    opacity: dragHandler.active ? 0.5 : 1.0
    
    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
    }

    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.margins: Styles.ThemeStore.g12
        spacing: Styles.ThemeStore.g8

        Rectangle {
            width: timed ? 6 : 0
            height: timed ? 6 : 0
            radius: 3
            color: muted ? Styles.ThemeStore.divider : subjectColor
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
                color: Styles.ThemeStore.colors.text2
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }

            Text {
                id: labelText
                text: chip.label
                color: Styles.ThemeStore.colors.textPrimary
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
        radius: chip.radius
        color: Styles.ThemeStore.hover
        visible: hoverHandler.hovered
        opacity: 0.2
    }

    HoverHandler {
        id: hoverHandler
        cursorShape: chip.draggable ? Qt.OpenHandCursor : Qt.ArrowCursor
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
