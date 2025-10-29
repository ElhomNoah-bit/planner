import QtQuick
import QtQuick.Controls
import NoahPlanner.Styles as Styles

Item {
    id: host
    anchors.fill: parent
    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject radii: Styles.ThemeStore.radii
    readonly property QtObject typeScale: Styles.ThemeStore.type

    property int margin: gaps.g16
    
    // Undo support
    property string undoEntryId: ""
    property string undoOldStartIso: ""
    property string undoOldEndIso: ""
    property bool hasUndo: false

    function show(msg, ms) {
        textItem.text = msg
        undoButton.visible = false
        hasUndo = false
        wrapper.visible = true
        timer.interval = ms || 2000
        timer.restart()
    }
    
    function showWithUndo(msg, entryId, oldStartIso, oldEndIso) {
        textItem.text = msg
        undoEntryId = entryId
        undoOldStartIso = oldStartIso
        undoOldEndIso = oldEndIso
        hasUndo = true
        undoButton.visible = true
        wrapper.visible = true
        timer.interval = 5000  // Longer timeout for undo messages
        timer.restart()
    }
    
    function handleUndo() {
        if (hasUndo && undoEntryId.length > 0) {
            planner.moveEntry(undoEntryId, undoOldStartIso, undoOldEndIso)
            wrapper.visible = false
            hasUndo = false
        }
    }

    Rectangle {
        id: wrapper
        visible: false
        opacity: 0
        radius: radii.lg
        color: colors.cardGlass
        border.color: colors.divider
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: host.margin
        width: contentRow.implicitWidth + gaps.g24
        height: contentRow.implicitHeight + gaps.g24

        Behavior on opacity {
            NumberAnimation {
                duration: 160
            }
        }

        states: [
            State {
                name: "hidden"
                when: !wrapper.visible
                PropertyChanges {
                    target: wrapper
                    opacity: 0
                }
            },
            State {
                name: "shown"
                when: wrapper.visible
                PropertyChanges {
                    target: wrapper
                    opacity: 1
                }
            }
        ]

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: gaps.g12

            Text {
                id: textItem
                anchors.verticalCenter: parent.verticalCenter
                color: colors.text
                font.pixelSize: typeScale.sm
                font.family: Styles.ThemeStore.fonts.uiFallback
                wrapMode: Text.Wrap
                renderType: Text.NativeRendering
            }
            
            Button {
                id: undoButton
                visible: false
                text: qsTr("Rückgängig")
                flat: true
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: typeScale.sm
                font.family: Styles.ThemeStore.fonts.uiFallback
                font.weight: typeScale.weightMedium
                
                contentItem: Text {
                    text: undoButton.text
                    font: undoButton.font
                    color: colors.accent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    renderType: Text.NativeRendering
                }
                
                background: Rectangle {
                    color: undoButton.hovered ? Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.1) : "transparent"
                    radius: radii.md
                    
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                }
                
                onClicked: host.handleUndo()
            }
        }
    }

    Timer {
        id: timer
        onTriggered: wrapper.visible = false
    }

    Connections {
        target: planner
        function onToastRequested(message) {
            host.show(message)
        }
        function onEntryMoved(entryId, oldStartIso, oldEndIso) {
            host.showWithUndo(qsTr("Eintrag verschoben"), entryId, oldStartIso, oldEndIso)
        }
    }
}
