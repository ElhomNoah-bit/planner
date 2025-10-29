import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Item {
    id: controls
    property bool active: false
    property bool paused: false
    property int elapsedSeconds: 0
    property string taskId: ""
    
    signal startRequested(string taskId)
    signal stopRequested()
    signal pauseRequested()
    signal resumeRequested()
    
    implicitHeight: active ? 120 : 60
    
    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject radii: Styles.ThemeStore.radii
    
    Behavior on implicitHeight {
        NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
    }
    
    Rectangle {
        anchors.fill: parent
        color: active ? Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.05) : "transparent"
        border.color: active ? colors.accent : colors.border
        border.width: active ? 2 : 1
        radius: radii.md
        
        Column {
            anchors.fill: parent
            anchors.margins: gaps.g12
            spacing: gaps.g8
            
            // Timer display when active
            Row {
                spacing: gaps.g12
                anchors.horizontalCenter: parent.horizontalCenter
                visible: active
                
                Text {
                    text: "⏱️"
                    font.pixelSize: typeScale.xl
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    id: timerText
                    text: {
                        var mins = Math.floor(elapsedSeconds / 60);
                        var secs = elapsedSeconds % 60;
                        return mins + ":" + (secs < 10 ? "0" : "") + secs;
                    }
                    font.pixelSize: typeScale.xl
                    font.weight: typeScale.weightBold
                    font.family: Styles.ThemeStore.fonts.uiFallback
                    color: colors.text
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                }
                
                Text {
                    text: paused ? qsTr("(Pausiert)") : qsTr("(Läuft)")
                    font.pixelSize: typeScale.sm
                    font.family: Styles.ThemeStore.fonts.uiFallback
                    color: colors.textSecondary
                    anchors.verticalCenter: parent.verticalCenter
                    renderType: Text.NativeRendering
                }
            }
            
            // Control buttons
            Row {
                spacing: gaps.g8
                anchors.horizontalCenter: parent.horizontalCenter
                
                PillButton {
                    text: active ? (paused ? qsTr("Fortsetzen") : qsTr("Pause")) : qsTr("Fokus starten")
                    kind: active ? "secondary" : "primary"
                    onClicked: {
                        if (active) {
                            if (paused) {
                                controls.resumeRequested();
                            } else {
                                controls.pauseRequested();
                            }
                        } else {
                            controls.startRequested(taskId);
                        }
                    }
                }
                
                PillButton {
                    text: qsTr("Beenden")
                    kind: "ghost"
                    visible: active
                    onClicked: controls.stopRequested()
                }
            }
        }
    }
}
