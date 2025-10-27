import QtQuick
import "../styles" as Styles

Item {
    id: root
    property string isoDate: ""
    property bool inMonth: true
    property bool selected: false
    property bool isToday: false
    property var events: []
    property int maxVisible: 2
    signal activated(string isoDate)

    implicitWidth: 152
    implicitHeight: 120

    property var dateObject: isoDate.length > 0 ? new Date(isoDate) : new Date()
    readonly property int dayNumber: dateObject.getDate()

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var typeScale: theme ? theme.type : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var space: theme ? theme.space : null
    readonly property var accent: theme ? theme.accent : null
    readonly property var state: theme ? theme.state : null

    readonly property real baseRadiusMd: radii ? radii.md : 14
    readonly property color baseAccent: colors ? colors.tint : "#0A84FF"
    readonly property string baseFont: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
    readonly property int baseDateSize: typeScale ? typeScale.dateSize : 14
    readonly property int baseDateWeight: typeScale ? typeScale.dateWeight : Font.DemiBold
    readonly property color baseText: colors ? colors.text : "#FFFFFF"
    readonly property color baseMuted: colors ? colors.textMuted : "#808080"

    Rectangle {
        id: backdrop
        anchors.fill: parent
        radius: baseRadiusMd
        color: root.selected
            ? (state ? state.select : Qt.rgba(0.04, 0.35, 0.84, 0.3))
            : (hoverArea.containsMouse ? (state ? state.hover : Qt.rgba(1, 1, 1, 0.12)) : Qt.rgba(1, 1, 1, 0.04))
        border.color: root.selected ? (accent ? accent.base : baseAccent) : (colors ? colors.divider : Qt.rgba(1, 1, 1, 0.08))
        border.width: root.selected ? 1 : 0
        opacity: root.inMonth ? 1 : 0.35
        Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
        Behavior on border.color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
        Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
    }

    Item {
        id: dayHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: space ? space.gap8 : 8
        height: 28

        Rectangle {
            id: dayHalo
            width: 24
            height: 24
            radius: 12
            anchors.top: parent.top
            anchors.right: parent.right
            color: root.isToday ? (state ? state.today : Qt.rgba(0.04, 0.35, 0.84, 0.3)) : "transparent"
            border.color: root.selected ? (accent ? accent.base : baseAccent) : "transparent"
            border.width: root.selected ? 1 : 0
        }

        Text {
            anchors.right: dayHalo.right
            anchors.verticalCenter: dayHalo.verticalCenter
            text: root.dayNumber
            font.pixelSize: baseDateSize
            font.weight: baseDateWeight
            font.family: baseFont
            color: root.isToday ? (accent ? accent.base : baseAccent) : (root.inMonth ? baseText : baseMuted)
            renderType: Text.NativeRendering
        }
    }

    Column {
        id: list
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
    anchors.margins: space ? space.gap8 : 8
    anchors.topMargin: space ? space.gap24 : 24
        spacing: space ? space.gap8 : 6
        Repeater {
            model: visibleEvents
            delegate: EventChip {
                label: modelData.title
                subjectColor: modelData.color
                width: list.width
            }
        }
        EventChip {
            visible: extraCount > 0
            label: "+" + extraCount
            muted: true
            subjectColor: baseAccent
            width: list.width
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated(root.isoDate)
    }

    property var visibleEvents: (events || []).slice(0, maxVisible)
    property int extraCount: Math.max(0, (events || []).length - maxVisible)
}
