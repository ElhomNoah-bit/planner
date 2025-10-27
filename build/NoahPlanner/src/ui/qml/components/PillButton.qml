import QtQuick
import QtQuick.Controls
import NoahPlanner 1.0 as NP

Button {
    id: control
    property bool accent: false
    property bool active: false
    property bool subtle: false
    property alias icon: iconGlyph.symbol

    implicitHeight: 36
    padding: NP.ThemeStore.spacing.gap12
    spacing: NP.ThemeStore.spacing.gap8
    hoverEnabled: true

    font.pixelSize: 14
    font.weight: active ? Font.DemiBold : Font.Medium
    font.preferredFamilies: NP.ThemeStore.fonts.stack

    background: Rectangle {
        radius: NP.ThemeStore.radii.xl
        color: backgroundColor()
        border.color: borderColor()
        border.width: 1
    }

    contentItem: Row {
        anchors.centerIn: parent
    spacing: control.spacing
        IconGlyph {
            id: iconGlyph
            visible: iconGlyph.symbol.length > 0
            size: 16
            tint: control.active || control.accent ? "#FFFFFF" : NP.ThemeStore.muted
            muted: !(control.active || control.accent)
        }
        Text {
            id: label
            text: control.text
            visible: text.length > 0
            font: control.font
            color: control.active || control.accent ? "#FFFFFF" : NP.ThemeStore.text
            verticalAlignment: Text.AlignVCenter
        }
    }

    function backgroundColor() {
        if (control.accent) {
            if (control.down || control.active) {
                return NP.ThemeStore.accent;
            }
            if (control.hovered) {
                return Qt.rgba(0.04, 0.35, 0.84, 0.28);
            }
            return Qt.rgba(0.04, 0.35, 0.84, 0.18);
        }
        const base = subtle ? Qt.rgba(0, 0, 0, NP.ThemeStore.dark ? 0.2 : 0.06) : NP.ThemeStore.panel;
        if (control.down) {
            return Qt.rgba(base.r, base.g, base.b, base.a + 0.1);
        }
        if (control.hovered) {
            return Qt.rgba(base.r, base.g, base.b, Math.min(1.0, base.a + 0.05));
        }
        return base;
    }

    function borderColor() {
        if (control.accent && (control.down || control.active)) {
            return Qt.rgba(1, 1, 1, 0.0);
        }
        return NP.ThemeStore.border;
    }
}
