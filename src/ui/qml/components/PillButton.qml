import QtQuick
import QtQuick.Controls
import styles 1.0 as Styles

Button {
    id: btn
    property string kind: "neutral" // "primary", "neutral", "ghost"

    flat: true
    hoverEnabled: true
    padding: 0
    implicitHeight: Styles.ThemeStore.layout.pillH
    implicitWidth: Math.max(implicitHeight, contentItem.implicitWidth + (Styles.ThemeStore.gap.g16 * 2))

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var gap: theme ? theme.gap : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var typeScale: theme ? theme.type : null

    font.pixelSize: typeScale ? typeScale.sm : 12
    font.weight: kind === "primary" ? (typeScale ? typeScale.weightBold : Font.Bold)
                                     : (typeScale ? typeScale.weightMedium : Font.Medium)
    font.family: Styles.ThemeStore.fonts.uiFallback

    background: Rectangle {
        id: frame
        radius: radii ? radii.xl : 20
        color: btn.backgroundColor()
        border.color: btn.borderColor()
        border.width: btn.borderWidth()
        implicitHeight: btn.implicitHeight

        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: (radii ? radii.xl : 20) + 2
            border.width: btn.activeFocus ? 1 : 0
            border.color: btn.activeFocus && colors ? colors.focus : "transparent"
            color: "transparent"
        }

        Behavior on color { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
        Behavior on border.color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
    }

    contentItem: Row {
        spacing: gap ? gap.g8 : 8
        anchors.centerIn: parent
        anchors.margins: gap ? gap.g12 : 12

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
        if (!colors) {
            return kind === "primary" ? "#0A84FF" : (kind === "ghost" ? "transparent" : "#1F232C")
        }
        if (kind === "primary") {
            return down ? Qt.darker(colors.accent, 1.1) : colors.accent
        }
        if (kind === "ghost") {
            if (checked) return colors.accentBg
            if (down) return colors.press
            if (hovered) return colors.hover
            return "transparent"
        }
        // neutral
        if (checked) return colors.accentBg
        if (down) return Qt.darker(colors.cardBg, 1.1)
        if (hovered) return colors.hover
        return colors.cardBg
    }

    function borderColor() {
        if (!colors) {
            return kind === "primary" ? "transparent" : "#2A2F3A"
        }
        if (kind === "primary") {
            return "transparent"
        }
        if (kind === "ghost") {
            return checked ? colors.accent : "transparent"
        }
        return checked ? colors.accent : colors.divider
    }

    function borderWidth() {
        return (kind === "ghost" || kind === "primary") ? 0 : 1
    }

    function foregroundColor() {
        if (!colors) {
            return kind === "primary" ? "#0F1115" : "#F2F5F9"
        }
        if (kind === "primary") {
            return colors.appBg
        }
        if (kind === "ghost") {
            return checked ? colors.accent : colors.text
        }
        return checked ? colors.accent : colors.text
    }
}
