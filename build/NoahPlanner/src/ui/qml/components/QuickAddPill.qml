import QtQuick
import QtQuick.Controls
import NoahPlanner 1.0
import NoahPlanner 1.0 as NP

GlassPanel {
    id: root
    property alias text: input.text
    property string placeholder: qsTr("Mathe 20m Mi 17:00 - Prozent")
    signal submitted(string text)
    function focusInput() {
        input.forceActiveFocus()
    }

    radius: NP.ThemeStore.radii.xl
    padding: 0

    Row {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 6
        anchors.topMargin: 6
        anchors.bottomMargin: 6
        spacing: NP.ThemeStore.spacing.gap12

        TextField {
            id: input
            placeholderText: root.placeholder
            font.pixelSize: 14
            font.preferredFamilies: NP.ThemeStore.fonts.stack
            color: NP.ThemeStore.text
            background: Rectangle { color: "transparent" }
            selectionColor: NP.ThemeStore.accent
            cursorDelegate: Rectangle { width: 2; color: NP.ThemeStore.accent }
            anchors.verticalCenter: parent.verticalCenter
            onAccepted: {
                root.submitted(text)
                text = ""
            }
        }

        PillButton {
            id: addBtn
            accent: true
            icon: "plus"
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
