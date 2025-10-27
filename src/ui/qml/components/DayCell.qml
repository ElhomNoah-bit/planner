import QtQuick
import NoahPlanner 1.0
import "../styles" as Styles

Item {
    id: root
    property string isoDate: ""
    property bool inMonth: true
    property bool selected: false
    property bool isToday: false
    property var events: []
    property int maxVisible: 3
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

    readonly property real baseRadiusMd: radii ? radii.md : 14
    readonly property color baseAccent: colors ? colors.tint : "#0A84FF"
    readonly property string baseFont: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
    readonly property int baseDateSize: typeScale ? typeScale.dateSize : 14
    readonly property int baseDateWeight: typeScale ? typeScale.dateWeight : Font.DemiBold
    readonly property color baseText: colors ? colors.text : "#FFFFFF"
    readonly property color baseMuted: colors ? colors.textMuted : "#808080"

    Rectangle {
        anchors.fill: parent
        radius: baseRadiusMd
        color: Qt.rgba(1, 1, 1, selected ? 0.04 : 0)
        border.color: selected ? baseAccent : Qt.rgba(1, 1, 1, 0.02)
        border.width: selected ? 1 : 0
    }

    Rectangle {
        id: dayBadge
        visible: selected
        radius: baseRadiusMd
        height: 26
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8
        color: Qt.rgba(0.04, 0.35, 0.84, 0.18)
        border.color: baseAccent
        border.width: 1
        width: label.implicitWidth + 16
        Text {
            id: label
            anchors.centerIn: parent
            text: root.dayNumber
            font.pixelSize: baseDateSize
            font.weight: baseDateWeight
            font.family: baseFont
            color: baseAccent
        }
    }

    Text {
        id: dayText
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8
        visible: !selected
        text: root.dayNumber
        font.pixelSize: baseDateSize
        font.weight: baseDateWeight
        font.family: baseFont
        color: root.isToday ? baseAccent : (root.inMonth ? baseText : baseMuted)
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
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated(root.isoDate)
    }

    property var visibleEvents: (events || []).slice(0, maxVisible)
    property int extraCount: Math.max(0, (events || []).length - maxVisible)
}
