import QtQuick
import QtQuick.Controls
import Styles 1.0 as Styles

GlassPanel {
    id: root
    property alias text: input.text
    property string placeholder: qsTr("Mathe 20m Mi 17:00 - Prozent")
    signal submitted(string text)
    function focusInput() {
        input.forceActiveFocus()
    }

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject radii: Styles.ThemeStore.radii
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject metrics: Styles.ThemeStore.layout

    radius: radii.xl
    padding: 0

    Row {
        anchors.fill: parent
        anchors.leftMargin: gaps.g16
        anchors.rightMargin: gaps.g8
        anchors.topMargin: gaps.g8
        anchors.bottomMargin: gaps.g8
        spacing: gaps.g12

        TextField {
            id: input
            placeholderText: root.placeholder
            placeholderTextColor: colors.text2
            font.pixelSize: typeScale.md
            font.family: Styles.ThemeStore.fonts.uiFallback
            color: colors.text
            height: Math.max(metrics.pillH, 36)
            background: Rectangle { color: "transparent" }
            selectionColor: colors.accent
            cursorDelegate: Rectangle { width: 2; color: colors.accent }
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
