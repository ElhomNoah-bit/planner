import QtQuick
import QtQuick.Controls
import NoahPlanner.Styles as Styles

Button {
    id: btn
    property string kind: "neutral" // "primary", "neutral", "ghost"

    flat: true
    hoverEnabled: true
    padding: 0
    implicitHeight: Math.max(Styles.ThemeStore.layout.pillH, 36)
    implicitWidth: Math.max(implicitHeight, contentItem.implicitWidth + 24)

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject radii: Styles.ThemeStore.radii
    readonly property QtObject typeScale: Styles.ThemeStore.type

    font.pixelSize: typeScale.sm
    font.weight: kind === "primary" ? typeScale.weightBold : typeScale.weightMedium
    font.family: Styles.ThemeStore.fonts.uiFallback

    background: Rectangle {
        id: frame
        radius: radii.xl
        color: btn.backgroundColor()
        border.color: btn.borderColor()
        border.width: btn.borderWidth()
        implicitHeight: btn.implicitHeight

        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: radii.xl + 2
            border.width: btn.activeFocus ? 1 : 0
            border.color: btn.activeFocus ? colors.focus : "transparent"
            color: "transparent"
        }

        Behavior on color { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
        Behavior on border.color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }
    }

    contentItem: Row {
        spacing: gaps.g8
        anchors.centerIn: parent
        anchors.margins: 12

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
            return down ? Qt.darker(colors.accent, 1.05) : colors.accent
        }
        if (kind === "ghost") {
            if (down) return colors.press
            if (hovered) return colors.hover
            return "transparent"
        }
        // neutral
        if (down) return colors.press
        if (hovered) return colors.hover
        return colors.neutralBg
    }

    function borderColor() {
        if (kind === "primary") {
            return "transparent"
        }
        if (kind === "ghost") {
            return checked ? colors.accent : "transparent"
        }
        return checked ? colors.accent : colors.divider
    }

    function borderWidth() {
        if (kind === "neutral") {
            return 1
        }
        if (kind === "ghost" && checked) {
            return 1
        }
        return 0
    }

    function foregroundColor() {
        if (kind === "primary") {
            return colors.appBg
        }
        if (kind === "ghost") {
            return checked ? colors.accent : colors.text
        }
        return colors.text
    }
}
