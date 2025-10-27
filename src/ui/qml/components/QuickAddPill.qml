import QtQuick
import QtQuick.Controls
import NoahPlanner 1.0
import "../styles" as Styles

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
    readonly property var space: theme ? theme.space : null
    readonly property var typeScale: theme ? theme.type : null
    readonly property var layout: theme ? theme.layout : null

    radius: radii ? radii.xl : 28
    padding: 0

    Row {
        anchors.fill: parent
        anchors.leftMargin: space ? space.gap16 : 16
        anchors.rightMargin: space ? space.gap8 : 8
        anchors.topMargin: space ? space.gap8 : 8
        anchors.bottomMargin: space ? space.gap8 : 8
        spacing: space ? space.gap12 : 12

        TextField {
            id: input
            placeholderText: root.placeholder
            font.pixelSize: typeScale ? typeScale.md : 15
            font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
            color: colors ? colors.text : "#FFFFFF"
            height: layout ? layout.pillH : 30
            background: Rectangle { color: "transparent" }
            selectionColor: theme ? theme.accent.base : "#0A84FF"
            cursorDelegate: Rectangle { width: 2; color: theme ? theme.accent.base : "#0A84FF" }
            anchors.verticalCenter: parent.verticalCenter
            onAccepted: {
                root.submitted(text)
                text = ""
            }
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
