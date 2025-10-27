import QtQuick
import QtQuick.Controls
import "../styles" as Styles

Button {
    id: btn
    property string kind: "neutral" // "primary", "neutral", "ghost"
    property bool checked: false

    flat: true
    hoverEnabled: true
    padding: 0
    implicitHeight: (Styles.ThemeStore && Styles.ThemeStore.layout) ? Styles.ThemeStore.layout.pillH : 30
    implicitWidth: Math.max(implicitHeight, contentItem.implicitWidth + 24)

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var accent: theme ? theme.accent : null
    readonly property var state: theme ? theme.state : null
    readonly property var typeScale: theme ? theme.type : null
    readonly property var radii: theme ? theme.radii : null

    font.pixelSize: typeScale ? typeScale.sm : 14
    font.weight: kind === "primary" ? (typeScale ? typeScale.weightBold : Font.DemiBold) : (typeScale ? typeScale.weightMedium : Font.Medium)
    font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"

    background: Rectangle {
        radius: radii ? radii.xl : 22
        color: btn.backgroundColor()
        border.color: btn.borderColor()
        border.width: btn.borderWidth()
        Behavior on color { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
        Behavior on border.color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: (radii ? radii.xl : 22) + 2
            border.width: btn.activeFocus ? 1 : 0
            border.color: btn.activeFocus && accent ? accent.base : "transparent"
            color: "transparent"
        }
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
            color: btn.foregroundColor()
        }

        Text {
            id: label
            text: btn.text
            visible: text.length > 0
            font: btn.font
            color: btn.foregroundColor()
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            renderType: Text.NativeRendering
        }
    }

    function backgroundColor() {
        if (kind === "primary") {
            return down ? Qt.darker(accent ? accent.base : "#0A84FF", 1.2) : (accent ? accent.base : "#0A84FF")
        }
        if (kind === "ghost") {
            if (checked) return accent ? accent.bg : Qt.rgba(0.04, 0.35, 0.84, 0.18)
            if (down) return state ? state.press : Qt.rgba(1, 1, 1, 0.18)
            if (hovered) return state ? state.hover : Qt.rgba(1, 1, 1, 0.1)
            return "transparent"
        }
        const base = colors ? colors.pillBg : Qt.rgba(0.12, 0.13, 0.18, 0.9)
        if (checked) return accent ? accent.bg : Qt.rgba(0.04, 0.35, 0.84, 0.18)
        if (down) return Qt.darker(base, 1.3)
        if (hovered) return Qt.darker(base, 1.15)
        return base
    }

    function borderColor() {
        if (kind === "primary") {
            return "transparent"
        }
        if (kind === "ghost") {
            if (checked) return accent ? accent.base : "#0A84FF"
            return "transparent"
        }
        if (checked) return accent ? accent.base : "#0A84FF"
        return colors ? colors.pillBorder : Qt.rgba(0.28, 0.3, 0.36, 1)
    }

    function borderWidth() {
        return (kind === "primary" || kind === "ghost") ? 0 : 1
    }

    function foregroundColor() {
        if (kind === "primary") {
            return "#0B0C0F"
        }
        if (kind === "ghost") {
            if (checked) return accent ? accent.base : "#0A84FF"
            return colors ? colors.text : "#FFFFFF"
        }
        if (checked) return accent ? accent.base : "#0A84FF"
        return colors ? colors.text : "#FFFFFF"
    }

    }
}
