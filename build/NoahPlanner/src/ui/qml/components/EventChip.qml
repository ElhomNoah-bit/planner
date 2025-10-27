import QtQuick
import NoahPlanner 1.0

Rectangle {
    id: chip
    property string label: ""
    property color subjectColor: accentColor
    property bool muted: false

    radius: 14
    height: 26
    readonly property color baseColor: muted ? Qt.rgba(1, 1, 1, 0.1) : chipBackground
    color: hover.hovered ? Qt.lighter(baseColor, 1.15) : baseColor
    border.color: Qt.rgba(1, 1, 1, 0.04)
    border.width: 1
    antialiasing: true

    readonly property color accentColor: theme(["accent"], "#0A84FF")
    readonly property color chipBackground: theme(["chipBg"], Qt.rgba(0, 0, 0, 0.1))
    readonly property color textColor: theme(["text"], "#1A1A1A")
    readonly property string fontFamily: theme(["defaultFontFamily"], "Sans")
    readonly property int fontSize: theme(["typography", "eventChipSize"], 12)
    readonly property int fontWeight: theme(["typography", "eventChipWeight"], Font.DemiBold)

    Row {
        id: row
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6
        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: chip.subjectColor
        }
        Text {
            text: chip.label
            color: textColor
            font.pixelSize: fontSize
            font.weight: fontWeight
            font.family: fontFamily
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
    }

    HoverHandler {
        id: hover
    }

    Behavior on color {
        NumberAnimation { duration: 180; easing.type: Easing.InOutCubic }
    }

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
