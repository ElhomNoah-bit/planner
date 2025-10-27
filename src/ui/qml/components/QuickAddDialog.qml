import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Item {
    id: dialog
    anchors.fill: parent
    visible: false
    z: 200

    property alias text: input.text
    signal accepted(string text)
    signal dismissed()

    function open(initialText) {
        text = initialText || ""
        visible = true
        dialog.forceActiveFocus()
        input.selectAll()
        input.forceActiveFocus()
    }

    function close() {
        visible = false
        dialog.dismissed()
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            event.accepted = true
            dialog.close()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
        visible: dialog.visible
    }

    GlassPanel {
        id: panel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(parent.width - Styles.ThemeStore.gap.g24 * 2, 520)
        padding: Styles.ThemeStore.gap.g24
        radius: Styles.ThemeStore.radii.lg
        visible: dialog.visible
        ColumnLayout {
            anchors.fill: parent
            spacing: Styles.ThemeStore.gap.g16

            Text {
                text: qsTr("+ Neue Aufgabe / Termin")
                font.pixelSize: Styles.ThemeStore.type.lg
                font.weight: Styles.ThemeStore.type.weightBold
                font.family: Styles.ThemeStore.fonts.heading
                color: Styles.ThemeStore.colors.text
                renderType: Text.NativeRendering
            }

            TextField {
                id: input
                Layout.fillWidth: true
                placeholderText: qsTr("z.B. Mathe lernen morgen 17:00 @Schule #Aufgabe")
                font.pixelSize: Styles.ThemeStore.type.md
                font.weight: Styles.ThemeStore.type.weightRegular
                font.family: Styles.ThemeStore.fonts.body
                color: Styles.ThemeStore.colors.text
                placeholderTextColor: Styles.ThemeStore.colors.text2
                selectionColor: Styles.ThemeStore.colors.accent
                selectedTextColor: Styles.ThemeStore.colors.appBg
                background: Rectangle {
                    radius: Styles.ThemeStore.radii.md
                    color: Styles.ThemeStore.colors.cardBg
                    border.color: input.activeFocus ? Styles.ThemeStore.colors.focus : Styles.ThemeStore.colors.divider
                    border.width: input.activeFocus ? 2 : 1
                }
                Keys.onReturnPressed: submit()
                Keys.onEnterPressed: submit()
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Styles.ThemeStore.gap.g12
                PillButton {
                    text: qsTr("Speichern")
                    kind: "primary"
                    Layout.preferredWidth: 140
                    onClicked: submit()
                }
                PillButton {
                    text: qsTr("Abbrechen")
                    kind: "ghost"
                    Layout.preferredWidth: 140
                    onClicked: dialog.close()
                }
                Item { Layout.fillWidth: true }
            }
        }
    }

    function submit() {
        var value = text.trim()
        if (!value.length) {
            dialog.close()
            return
        }
        accepted(value)
        dialog.close()
    }

    onVisibleChanged: {
        if (!visible) {
            text = ""
        }
    }
}
