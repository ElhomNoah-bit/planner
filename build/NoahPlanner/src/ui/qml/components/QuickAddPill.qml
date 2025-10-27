import QtQuick
import QtQuick.Controls
import styles 1.0 as Styles

GlassPanel {
    id: root
    property alias text: input.text
    property string placeholder: qsTr("Mathe 20m Mi 17:00 - Prozent")
    signal submitted(string text)
    function focusInput() {
        input.forceActiveFocus()
    }

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var gap: theme ? theme.gap : null
    readonly property var typeScale: theme ? theme.type : null
    readonly property var layout: theme ? theme.layout : null

    radius: radii ? radii.xl : 28
    padding: 0

    Row {
        anchors.fill: parent
        anchors.leftMargin: gap ? gap.g16 : 16
        anchors.rightMargin: gap ? gap.g8 : 8
        anchors.topMargin: gap ? gap.g8 : 8
        anchors.bottomMargin: gap ? gap.g8 : 8
        spacing: gap ? gap.g12 : 12

        TextField {
            id: input
            placeholderText: root.placeholder
            placeholderTextColor: colors ? colors.textMuted : "#8B93A2"
            font.pixelSize: typeScale ? typeScale.md : 14
            font.family: Styles.ThemeStore.fonts.uiFallback
            color: colors ? colors.text : "#F2F5F9"
            height: layout ? layout.pillH : 30
            background: Rectangle { color: "transparent" }
            selectionColor: colors ? colors.accent : "#0A84FF"
            cursorDelegate: Rectangle { width: 2; color: colors ? colors.accent : "#0A84FF" }
            anchors.verticalCenter: parent.verticalCenter
            onAccepted: {
                root.submitted(text)
                text = ""
            }
            renderType: Text.NativeRendering
        }

        PillButton {
            id: addBtn
            kind: "primary"
            icon.name: "plus"
            text: qsTr("Add")
            onClicked: {
                if (input.text.length === 0)
                    return
                root.submitted(input.text)
                input.text = ""
            }
        }
    }
}
