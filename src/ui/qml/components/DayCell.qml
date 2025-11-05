import QtQuick
import QtQuick.Controls
import Styles 1.0

FocusScope {
    id: root
    property string isoDate: ""
    property bool inMonth: true
    property bool selected: false
    property bool isToday: false
    property var events: []
    property int maxVisible: 3
    readonly property var dateObject: isoDate.length > 0 ? new Date(isoDate) : new Date()
    readonly property int dayNumber: dateObject.getDate()
    readonly property bool hovered: hoverHandler.hovered
    property var visibleEvents: (events || []).slice(0, maxVisible)
    property int extraCount: Math.max(0, (events || []).length - maxVisible)
    readonly property QtObject colors: ThemeStore.colors
    readonly property QtObject gaps: ThemeStore.gap
    readonly property QtObject radii: ThemeStore.radii
    readonly property QtObject typeScale: ThemeStore.type
    readonly property color hoverFill: Qt.lighter(colors.cardBg, 1.08)
    
    // Drop support
    property bool dropActive: dropArea.containsDrag

    signal activated(string isoDate)
    signal contextCreateEvent(string isoDate)
    signal contextCreateTask(string isoDate)
    signal contextJumpToToday()

    implicitWidth: 152
    implicitHeight: 120

    Accessible.role: Accessible.Button
    Accessible.name: Qt.formatDate(dateObject, "dddd, dd. MMMM")
    
    DropArea {
        id: dropArea
        anchors.fill: parent
        
        onDropped: function(drop) {
            if (drop.hasText) {
                var entryId = drop.text
                var data = drop.getDataAsString("application/x-planner-entry")
                if (data && data.length > 0) {
                    try {
                        var dragData = JSON.parse(data)
                        handleDrop(dragData)
                        drop.accept(Qt.MoveAction)
                    } catch (e) {
                        console.warn("Failed to parse drag data:", e)
                        drop.accept(Qt.IgnoreAction)
                    }
                } else {
                    drop.accept(Qt.IgnoreAction)
                }
            } else {
                drop.accept(Qt.IgnoreAction)
            }
        }
        
        onEntered: function(drag) {
            // Only accept if we have valid entry data
            var data = drag.getDataAsString("application/x-planner-entry")
            drag.accepted = data && data.length > 0
        }
        
        onExited: function() {
            // Cleanup if needed
        }
    }
    
    function handleDrop(dragData) {
        if (!dragData.id || !dragData.startIso || !dragData.endIso) {
            console.warn("Invalid drag data, cannot drop")
            return
        }
        
        // Validate dates
        var oldStart = new Date(dragData.startIso)
        var oldEnd = new Date(dragData.endIso)
        if (isNaN(oldStart.getTime()) || isNaN(oldEnd.getTime())) {
            console.warn("Invalid dates in drag data")
            return
        }
        
        var targetDate = root.dateObject
        
        // For month view: keep time, change date
        var newStart = new Date(targetDate)
        var newEnd = new Date(targetDate)
        
        if (dragData.allDay) {
            // All-day events: just change the date
            newStart.setHours(0, 0, 0, 0)
            newEnd.setHours(23, 59, 59, 999)
        } else {
            // Timed events: preserve time, change date
            newStart.setHours(oldStart.getHours(), oldStart.getMinutes(), oldStart.getSeconds(), oldStart.getMilliseconds())
            newEnd.setHours(oldEnd.getHours(), oldEnd.getMinutes(), oldEnd.getSeconds(), oldEnd.getMilliseconds())
        }
        
        var newStartIso = Qt.formatDateTime(newStart, Qt.ISODate)
        var newEndIso = Qt.formatDateTime(newEnd, Qt.ISODate)
        
        // Call backend to move entry
        if (planner.moveEntry(dragData.id, newStartIso, newEndIso)) {
            console.log("Entry moved successfully to", root.isoDate)
        }
    }

    Rectangle {
        id: backdrop
        anchors.fill: parent
        radius: radii.md
        border.width: root.isToday ? 2 : 1
        border.color: root.isToday
            ? colors.focus
            : (root.selected ? colors.accent : colors.divider)
        color: root.selected
            ? colors.accentBg
            : (root.hovered ? hoverFill : colors.cardBg)
        antialiasing: true

        Behavior on color {
            ColorAnimation { duration: 140; easing.type: Easing.InOutQuad }
        }
        Behavior on border.color {
            ColorAnimation { duration: 140; easing.type: Easing.InOutQuad }
        }
    }
    
    // Drop indicator overlay
    Rectangle {
        anchors.fill: parent
        radius: radii.md
        color: colors.accent
        opacity: root.dropActive ? 0.15 : 0
        visible: root.dropActive
        
        Behavior on opacity {
            NumberAnimation { duration: 100; easing.type: Easing.InOutQuad }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -1
        radius: radii.md + 2
        color: "transparent"
        border.width: 1
        border.color: ThemeStore.focus
        visible: root.activeFocus
        opacity: 0.9
    }

    Text {
        id: dayLabel
        text: root.dayNumber
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: gaps.g12
        font.pixelSize: typeScale.sm + 2
        font.family: ThemeStore.fonts.heading
        font.weight: root.isToday ? typeScale.weightBold : typeScale.weightMedium
        color: root.inMonth ? colors.text : colors.text2
        opacity: root.inMonth ? 1 : 0.6
        renderType: Text.NativeRendering
    }

    Column {
        id: list
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: dayLabel.bottom
        anchors.topMargin: gaps.g12
        anchors.leftMargin: gaps.g12
        anchors.rightMargin: gaps.g12
        anchors.bottomMargin: gaps.g12
        spacing: gaps.g8

        Repeater {
            model: root.visibleEvents
            delegate: EventChip {
                width: list.width
                label: modelData.title
                subjectColor: modelData.colorHint && modelData.colorHint.length ? modelData.colorHint : colors.accent
                timeText: modelData.startTimeLabel
                overdue: modelData.overdue
                categoryColor: modelData.categoryColor || ""
                entryId: modelData.id || ""
                startIso: modelData.start || ""
                endIso: modelData.end || ""
                allDay: modelData.allDay || false
            }
        }

        EventChip {
            width: list.width
            visible: root.extraCount > 0
            label: "+" + root.extraCount
            muted: true
            subjectColor: colors.accent
            timeText: ""
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.WithinBounds
        onTapped: root.activated(root.isoDate)
        onPressedChanged: if (pressed) root.forceActiveFocus()
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        gesturePolicy: TapHandler.WithinBounds
        onTapped: (eventPoint) => {
            if (!contextMenu.visible) {
                contextMenu.popup(eventPoint.scenePosition)
            }
        }
    }

    HoverHandler {
        id: hoverHandler
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            event.accepted = true
            root.activated(root.isoDate)
        }
    }

    Menu {
        id: contextMenu
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        MenuItem {
            text: qsTr("Neuer Termin an diesem Tag")
            onTriggered: root.contextCreateEvent(root.isoDate)
        }
        MenuItem {
            text: qsTr("Neue Aufgabe an diesem Tag")
            onTriggered: root.contextCreateTask(root.isoDate)
        }
        MenuSeparator {}
        MenuItem {
            text: qsTr("Zu heute springen")
            onTriggered: root.contextJumpToToday()
        }
    }
}
