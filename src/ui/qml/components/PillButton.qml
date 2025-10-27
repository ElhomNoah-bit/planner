import QtQuick
import QtQuick.Controls
import NoahPlanner 1.0

Button {
    id: btn
    property bool accent: false
    property bool active: false
    property bool subtle: false

    flat: true
    hoverEnabled: true
    padding: 0
    implicitHeight: 36
    implicitWidth: Math.max(36, contentItem.implicitWidth + 24)

    font.pixelSize: 14
    font.weight: active ? Font.DemiBold : Font.Medium
    font.family: baseFontFamily

    readonly property string baseFontFamily: theme(["defaultFontFamily"], "Sans")
    readonly property real baseRadiusXl: theme(["radii", "xl"], 28)
    readonly property color basePanel: theme(["panel"], Qt.rgba(0, 0, 0, 0.08))
    readonly property color baseBorder: theme(["border"], Qt.rgba(0, 0, 0, 0.12))
    readonly property color baseAccent: theme(["accent"], "#0A84FF")
    readonly property color baseMuted: theme(["muted"], "#A0A0A0")
    readonly property color baseText: theme(["text"], "#1A1A1A")
    readonly property bool baseDark: theme(["dark"], false)

    background: Rectangle {
        radius: baseRadiusXl
        color: btn.backgroundColor()
        border.color: btn.borderColor()
        border.width: 1
        Behavior on color { NumberAnimation { duration: 150 } }
    }

    contentItem: Row {
        spacing: 8
        anchors.centerIn: parent
        anchors.margins: 10

        IconGlyph {
            id: iconGlyph
            size: 16
            name: btn.icon && btn.icon.name ? btn.icon.name : ""
            visible: name.length > 0
            color: btn.active || btn.accent ? "#FFFFFF" : baseMuted
        }

        Text {
            id: label
            text: btn.text
            visible: text.length > 0
            font: btn.font
            color: btn.active || btn.accent ? "#FFFFFF" : baseText
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    function backgroundColor() {
        if (btn.accent) {
            if (btn.down || btn.active) {
                return baseAccent
            }
            if (btn.hovered) {
                return Qt.rgba(0.04, 0.35, 0.84, 0.28)
            }
            return Qt.rgba(0.04, 0.35, 0.84, 0.18)
        }
        const base = btn.subtle ? Qt.rgba(0, 0, 0, baseDark ? 0.2 : 0.06) : basePanel
        if (btn.down) {
            return Qt.rgba(base.r, base.g, base.b, Math.min(1.0, base.a + 0.1))
        }
        if (btn.hovered) {
            return Qt.rgba(base.r, base.g, base.b, Math.min(1.0, base.a + 0.05))
        }
        return base
    }

    function borderColor() {
        if (btn.accent && (btn.down || btn.active)) {
            return Qt.rgba(1, 1, 1, 0.0)
        }
        return baseBorder
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
