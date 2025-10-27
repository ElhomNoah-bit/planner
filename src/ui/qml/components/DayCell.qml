import QtQuick
import NoahPlanner 1.0

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

    readonly property real baseRadiusMd: theme(["radii", "md"], 14)
    readonly property color baseAccent: theme(["accent"], "#0A84FF")
    readonly property string baseFont: theme(["defaultFontFamily"], "Sans")
    readonly property int baseDateSize: theme(["typography", "dateSize"], 14)
    readonly property int baseDateWeight: theme(["typography", "dateWeight"], Font.DemiBold)
    readonly property color baseText: theme(["text"], "#1A1A1A")
    readonly property color baseMuted: theme(["muted"], "#808080")

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
        anchors.margins: 8
        anchors.topMargin: 38
        spacing: 6
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

    function theme(path, fallback) {
        if (typeof ThemeStore === "undefined" || !ThemeStore) {
            return fallback
        }
        var value = ThemeStore
        for (var i = 0; i < path.length; ++i) {
            if (value === undefined || value === null) {
                return fallback
            }
            value = value[path[i]]
        }
        return value === undefined ? fallback : value
    }
}
