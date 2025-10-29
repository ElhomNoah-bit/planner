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
    property var commands: []
    property var filteredActions: []
    readonly property var commandMetadata: ({
        "go-today": { keywords: ["today", "heute", "jump"], run: function() { app.goToday() } },
        "new-item": { keywords: ["neu", "add", "task"], run: function() { app.quickAddOpen() } },
        "view-month": { keywords: ["month", "monats", "kalender"], run: function() { planner.setViewMode("month") } },
        "view-week": { keywords: ["week", "woche"], run: function() { planner.setViewMode("week") } },
        "view-list": { keywords: ["list", "liste"], run: function() { planner.setViewMode("list") } },
        "toggle-open": { keywords: ["open", "offen", "filter"], run: function() { planner.setOnlyOpenQml(!planner.onlyOpen) } },
        "toggle-zen": { keywords: ["zen", "focus", "fokus"], run: function() { app.toggleZenMode() } },
        "export-week": { keywords: ["export", "pdf", "woche", "week"], run: function() { app.openExportDialog("week") } },
        "export-month": { keywords: ["export", "pdf", "monat", "month"], run: function() { app.openExportDialog("month") } },
        "open-settings": { keywords: ["settings", "einstellungen", "preferences"], run: function() { app.openSettings() } }
    })

    function open(initialQuery) {
        palette.visible = true
        palette.queryText = initialQuery || ""
        palette.commands = planner && planner.commands ? planner.commands : []
        queryField.text = palette.queryText
        recompute()
        Qt.callLater(() => {
            queryField.selectAll()
            queryField.forceActiveFocus()
        })
    }

    Connections {
        target: planner
        function onCommandsChanged() {
            palette.commands = planner && planner.commands ? planner.commands : []
            if (palette.visible)
                palette.recompute()
        }
    }

    function close() {
        palette.visible = false
        queryField.text = ""
        palette.queryText = ""
        palette.recompute()
    }

    function recompute() {
        var term = (palette.queryText || "").toLowerCase()
        var source = palette.commands || []
        var normalized = []
        for (var i = 0; i < source.length; ++i) {
            var cmd = source[i] || {}
            var meta = palette.commandMetadata[cmd.id] || {}
            normalized.push({
                id: cmd.id,
                title: cmd.title || meta.title || cmd.id,
                hint: cmd.hint || meta.hint || "",
                keywords: meta.keywords || []
            })
        }
        if (!term.length) {
            filteredActions = normalized
        } else {
            var matches = []
            for (var j = 0; j < normalized.length; ++j) {
                var entry = normalized[j]
                if (!entry)
                    continue
                var label = (entry.title || "").toLowerCase()
                if (label.indexOf(term) !== -1) {
                    matches.push(entry)
                    continue
                }
                var keys = entry.keywords || []
                var hit = false
                for (var k = 0; k < keys.length; ++k) {
                    if ((keys[k] || "").toLowerCase().indexOf(term) !== -1) {
                        hit = true
                        break
                    }
                }
                if (hit)
                    matches.push(entry)
            }
            filteredActions = matches
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
        var meta = palette.commandMetadata[action.id] || {}
        if (meta.run)
            meta.run()
        if (action.id)
            commandTriggered(action.id)
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
                            text: modelData && modelData.title ? modelData.title : ""
                            font.pixelSize: Styles.ThemeStore.type.sm
                            font.weight: Styles.ThemeStore.type.weightMedium
                            font.family: Styles.ThemeStore.fonts.heading
                            color: Styles.ThemeStore.colors.text
                            renderType: Text.NativeRendering
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: modelData && modelData.hint ? modelData.hint : modelData.id
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
