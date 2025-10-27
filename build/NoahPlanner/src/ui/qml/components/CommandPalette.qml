import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Item {
    id: palette
    anchors.fill: parent
    visible: false
    z: 300
    focus: visible

    signal commandTriggered(string command)

    property alias query: queryField.text
    property int currentIndex: Math.max(0, listView.currentIndex)

    readonly property var actions: [
        { "label": qsTr("Heute"), "command": "go-today", "keywords": ["today", "heute", "jump"] },
        { "label": qsTr("Neuer Eintrag"), "command": "new-item", "keywords": ["neu", "add", "task"] },
        { "label": qsTr("Monatsansicht"), "command": "view-month", "keywords": ["month", "monats", "kalender"] },
        { "label": qsTr("Wochenansicht"), "command": "view-week", "keywords": ["week", "woche"] },
        { "label": qsTr("Listenansicht"), "command": "view-list", "keywords": ["list", "liste"] },
        { "label": qsTr("Nur offene toggeln"), "command": "toggle-open", "keywords": ["open", "offen", "filter"] },
        { "label": qsTr("Einstellungen"), "command": "open-settings", "keywords": ["settings", "einstellungen", "preferences"] }
    ]

    property var filteredActions: actions

    function open(initialQuery) {
        palette.visible = true
        query = initialQuery || ""
        updateFilter()
        Qt.callLater(() => {
            queryField.selectAll()
            queryField.forceActiveFocus()
        })
    }

    function close() {
        palette.visible = false
    }

    function updateFilter() {
        var term = queryField.text.trim().toLowerCase()
        if (!term.length) {
            filteredActions = actions
            listView.currentIndex = filteredActions.length > 0 ? 0 : -1
            return
        }
        filteredActions = actions.filter(function(action) {
            if (action.label.toLowerCase().indexOf(term) !== -1)
                return true
            for (var i = 0; i < action.keywords.length; ++i) {
                if (action.keywords[i].indexOf(term) !== -1)
                    return true
            }
            return false
        })
        listView.currentIndex = filteredActions.length > 0 ? 0 : -1
    }

    function trigger(index) {
        if (index < 0 || index >= filteredActions.length)
            return
        commandTriggered(filteredActions[index].command)
        close()
    }

    Keys.onEscapePressed: close()
    Keys.onPressed: function(event) {
        if (!visible)
            return
        if (event.key === Qt.Key_Down) {
            event.accepted = true
            listView.currentIndex = Math.min(listView.count - 1, listView.currentIndex + 1)
            return
        }
        if (event.key === Qt.Key_Up) {
            event.accepted = true
            listView.currentIndex = Math.max(0, listView.currentIndex - 1)
            return
        }
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            event.accepted = true
            trigger(listView.currentIndex)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
        visible: palette.visible

        TapHandler {
            acceptedButtons: Qt.LeftButton
            gesturePolicy: TapHandler.WithinBounds
            onTapped: palette.close()
        }
    }

    GlassPanel {
        id: panel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Styles.ThemeStore.gap.g24 * 2
        width: Math.min(parent.width - Styles.ThemeStore.gap.g24 * 2, 520)
        padding: Styles.ThemeStore.gap.g16
        visible: palette.visible

        ColumnLayout {
            anchors.fill: parent
            spacing: Styles.ThemeStore.gap.g12

            TextField {
                id: queryField
                Layout.fillWidth: true
                placeholderText: qsTr("Befehl suchen…")
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
                    border.color: queryField.activeFocus ? Styles.ThemeStore.colors.focus : Styles.ThemeStore.colors.divider
                    border.width: queryField.activeFocus ? 2 : 1
                }
                onTextChanged: updateFilter()
            }

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(264, contentHeight)
                clip: true
                model: palette.filteredActions
                delegate: Control {
                    id: control
                    width: ListView.view.width
                    height: 44
                    hoverEnabled: true
                    background: Rectangle {
                        radius: Styles.ThemeStore.radii.md
                        color: control.activeFocus || control.hovered || index === listView.currentIndex
                               ? Styles.ThemeStore.colors.hover
                               : "transparent"
                    }
                    contentItem: RowLayout {
                        anchors.fill: parent
                        anchors.margins: Styles.ThemeStore.gap.g12
                        spacing: Styles.ThemeStore.gap.g12
                        Text {
                            text: modelData.label
                            font.pixelSize: Styles.ThemeStore.type.sm
                            font.weight: Styles.ThemeStore.type.weightMedium
                            font.family: Styles.ThemeStore.fonts.heading
                            color: Styles.ThemeStore.colors.text
                            renderType: Text.NativeRendering
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: modelData.command
                            font.pixelSize: Styles.ThemeStore.type.xs
                            font.weight: Styles.ThemeStore.type.weightRegular
                            font.family: Styles.ThemeStore.fonts.body
                            color: Styles.ThemeStore.colors.text2
                            renderType: Text.NativeRendering
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: listView.currentIndex = index
                        onClicked: palette.trigger(index)
                    }
                }
                footer: Component {
                    Item {
                        width: ListView.view ? ListView.view.width : 0
                        height: palette.filteredActions.length === 0 ? 56 : 0
                        visible: palette.filteredActions.length === 0
                        Text {
                            anchors.centerIn: parent
                            text: qsTr("Keine Treffer")
                            font.pixelSize: Styles.ThemeStore.type.sm
                            font.weight: Styles.ThemeStore.type.weightRegular
                            font.family: Styles.ThemeStore.fonts.body
                            color: Styles.ThemeStore.colors.text2
                            renderType: Text.NativeRendering
                        }
                    }
                }
            }
        }
    }
}
