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

    property string queryText: ""
    property var allActions: [
        {
            label: qsTr("Heute"),
            command: "go-today",
            keywords: ["today", "heute", "jump"],
            run: function() { app.goToday() }
        },
        {
            label: qsTr("Neuer Eintrag"),
            command: "new-item",
            keywords: ["neu", "add", "task"],
            run: function() { app.quickAddOpen() }
        },
        {
            label: qsTr("Ansicht: Monat"),
            command: "view-month",
            keywords: ["month", "monats", "kalender"],
            run: function() { planner.viewModeString = "month" }
        },
        {
            label: qsTr("Ansicht: Woche"),
            command: "view-week",
            keywords: ["week", "woche"],
            run: function() { planner.viewModeString = "week" }
        },
        {
            label: qsTr("Ansicht: Liste"),
            command: "view-list",
            keywords: ["list", "liste"],
            run: function() { planner.viewModeString = "list" }
        },
        {
            label: qsTr("Nur offene toggeln"),
            command: "toggle-open",
            keywords: ["open", "offen", "filter"],
            run: function() { planner.onlyOpen = !planner.onlyOpen }
        },
        {
            label: qsTr("Einstellungen"),
            command: "open-settings",
            keywords: ["settings", "einstellungen", "preferences"],
            run: function() { app.openSettings() }
        }
    ]

    property var filteredActions: []

    function open(initialQuery) {
        palette.visible = true
        palette.queryText = initialQuery || ""
        queryField.text = palette.queryText
        recompute()
        Qt.callLater(() => {
            queryField.selectAll()
            queryField.forceActiveFocus()
        })
    }

    function close() {
        palette.visible = false
        queryField.text = ""
        palette.queryText = ""
        palette.recompute()
    }

    function recompute() {
        var term = (palette.queryText || "").toLowerCase()
        if (!term.length) {
            filteredActions = allActions.slice(0)
        } else {
            filteredActions = allActions.filter(function(action) {
                if (!action)
                    return false
                var label = (action.label || "").toLowerCase()
                if (label.indexOf(term) !== -1)
                    return true
                var keys = action.keywords || []
                for (var i = 0; i < keys.length; ++i) {
                    if ((keys[i] || "").toLowerCase().indexOf(term) !== -1)
                        return true
                }
                return false
            })
        }
        if (listView)
            listView.currentIndex = filteredActions.length > 0 ? 0 : -1
    }

    function trigger(actionOrIndex) {
        var action = actionOrIndex
        if (typeof actionOrIndex === "number") {
            action = filteredActions.length > actionOrIndex && actionOrIndex >= 0
                    ? filteredActions[actionOrIndex]
                    : null
        }
        if (!action)
            return
        if (action.run)
            action.run()
        if (action.command)
            commandTriggered(action.command)
        close()
    }

    Keys.onEscapePressed: close()
    Keys.onPressed: function(event) {
        if (!visible)
            return
        if (event.key === Qt.Key_Down) {
            event.accepted = true
            if (listView.count === 0)
                return
            var maxIndex = listView.count - 1
            listView.currentIndex = Math.min(maxIndex, Math.max(0, listView.currentIndex + 1))
            return
        }
        if (event.key === Qt.Key_Up) {
            event.accepted = true
            if (listView.count === 0)
                return
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
                onTextChanged: {
                    palette.queryText = queryField.text
                    palette.recompute()
                }
            }

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(264, contentHeight)
                clip: true
                model: palette.filteredActions || []
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
                            text: modelData && modelData.label ? modelData.label : ""
                            font.pixelSize: Styles.ThemeStore.type.sm
                            font.weight: Styles.ThemeStore.type.weightMedium
                            font.family: Styles.ThemeStore.fonts.heading
                            color: Styles.ThemeStore.colors.text
                            renderType: Text.NativeRendering
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: modelData && modelData.command ? modelData.command : ""
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
                        onClicked: palette.trigger(modelData)
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: listView.count === 0
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
