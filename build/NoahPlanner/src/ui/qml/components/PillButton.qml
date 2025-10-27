import QtQuick
import QtQuick.Controls
import NoahPlanner 1.0 as NP

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
    font.family: Qt.application.font && Qt.application.font.family.length
                    ? Qt.application.font.family
                    : (NP.ThemeStore.fonts.stack.length > 0 ? NP.ThemeStore.fonts.stack[0] : "Sans")

    background: Rectangle {
        radius: NP.ThemeStore.radii.xl
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
            color: btn.active || btn.accent ? "#FFFFFF" : NP.ThemeStore.muted
        }

        Text {
            id: label
            text: btn.text
            visible: text.length > 0
            font: btn.font
            color: btn.active || btn.accent ? "#FFFFFF" : NP.ThemeStore.text
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    function backgroundColor() {
        if (btn.accent) {
            if (btn.down || btn.active) {
                return NP.ThemeStore.accent
            }
            if (btn.hovered) {
                return Qt.rgba(0.04, 0.35, 0.84, 0.28)
            }
            return Qt.rgba(0.04, 0.35, 0.84, 0.18)
        }
        const base = btn.subtle ? Qt.rgba(0, 0, 0, NP.ThemeStore.dark ? 0.2 : 0.06) : NP.ThemeStore.panel
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
        return NP.ThemeStore.border
    }
}
