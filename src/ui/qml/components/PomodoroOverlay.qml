import QtQuick
import QtQuick.Controls
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Item {
    id: overlay
    property bool open: false
    property QtObject pomodoroTimer: null
    
    signal closed()
    signal finished()

    anchors.fill: parent
    visible: open
    opacity: open ? 1 : 0
    z: 100

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject radii: Styles.ThemeStore.radii

    readonly property bool isActive: pomodoroTimer ? pomodoroTimer.isActive : false
    readonly property bool isPaused: pomodoroTimer ? pomodoroTimer.isPaused : false
    readonly property int remainingSeconds: pomodoroTimer ? pomodoroTimer.remainingSeconds : 0
    readonly property int totalSeconds: pomodoroTimer ? pomodoroTimer.totalSeconds : 1500
    readonly property string modeString: pomodoroTimer ? pomodoroTimer.modeString : "work"
    readonly property int currentRound: pomodoroTimer ? pomodoroTimer.currentRound : 1
    readonly property int totalRounds: pomodoroTimer ? pomodoroTimer.totalRounds : 4
    readonly property string presetString: pomodoroTimer ? pomodoroTimer.presetString : "25/5"

    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (!overlay.isActive) {
                    overlay.open = false
                    overlay.closed()
                }
            }
        }
    }

    GlassPanel {
        id: panel
        width: 420
        height: isActive ? 520 : 420
        anchors.centerIn: parent
        radius: radii.lg
        
        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        
        Column {
            anchors.fill: parent
            anchors.margins: gaps.g24
            spacing: gaps.g20
            
            // Header
            Row {
                width: parent.width
                spacing: gaps.g12
                
                Text {
                    text: qsTr("Pomodoro Focus Timer")
                    font.pixelSize: typeScale.lg
                    font.weight: typeScale.weightMedium
                    font.family: Styles.ThemeStore.fonts.uiFallback
                    color: colors.text
                    renderType: Text.NativeRendering
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Item { Layout.fillWidth: true; width: 1 }
                
                PillButton {
                    text: "×"
                    kind: "ghost"
                    visible: !overlay.isActive
                    onClicked: {
                        overlay.open = false
                        overlay.closed()
                    }
                }
            }
            
            // Preset Selection (only shown when not active)
            Column {
                width: parent.width
                spacing: gaps.g12
                visible: !overlay.isActive
                opacity: visible ? 1 : 0
                
                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
                
                Text {
                    text: qsTr("Wähle ein Preset:")
                    font.pixelSize: typeScale.sm
                    font.weight: typeScale.weightMedium
                    font.family: Styles.ThemeStore.fonts.uiFallback
                    color: colors.textMuted
                    renderType: Text.NativeRendering
                }
                
                Row {
                    spacing: gaps.g8
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    PillButton {
                        text: qsTr("25 / 5")
                        kind: overlay.presetString === "25/5" ? "primary" : "neutral"
                        onClicked: selectedPreset = "25/5"
                    }
                    
                    PillButton {
                        text: qsTr("50 / 10")
                        kind: overlay.presetString === "50/10" ? "primary" : "neutral"
                        onClicked: selectedPreset = "50/10"
                    }
                    
                    PillButton {
                        text: qsTr("Custom")
                        kind: overlay.presetString === "custom" ? "primary" : "neutral"
                        enabled: false
                        ToolTip.text: qsTr("Coming soon")
                        ToolTip.visible: hovered
                    }
                }
            }
            
            // Progress Ring
            Canvas {
                id: ring
                width: 240
                height: 240
                anchors.horizontalCenter: parent.horizontalCenter
                
                property color ringColor: {
                    if (overlay.modeString === "work") return colors.accent
                    if (overlay.modeString === "short_break") return colors.success || "#10B981"
                    if (overlay.modeString === "long_break") return colors.info || "#3B82F6"
                    return colors.accent
                }
                
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.translate(width / 2, height / 2)
                    ctx.rotate(-Math.PI / 2)
                    var radius = 105
                    ctx.lineWidth = 14
                    
                    // Background ring
                    ctx.strokeStyle = "rgba(255,255,255,0.08)"
                    ctx.beginPath()
                    ctx.arc(0, 0, radius, 0, Math.PI * 2)
                    ctx.stroke()
                    
                    // Progress ring
                    var total = Math.max(1, overlay.totalSeconds)
                    var progress = Math.max(0, overlay.remainingSeconds) / total
                    ctx.strokeStyle = ringColor
                    ctx.beginPath()
                    ctx.arc(0, 0, radius, 0, Math.PI * 2 * progress)
                    ctx.stroke()
                }
                
                Connections {
                    target: overlay
                    function onRemainingSecondsChanged() { ring.requestPaint() }
                    function onTotalSecondsChanged() { ring.requestPaint() }
                    function onModeStringChanged() { ring.requestPaint() }
                }
            }
            
            // Timer Display
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: gaps.g8
                
                Text {
                    text: {
                        var mins = Math.floor(overlay.remainingSeconds / 60)
                        var secs = overlay.remainingSeconds % 60
                        return mins + ":" + (secs < 10 ? "0" : "") + secs
                    }
                    font.pixelSize: 56
                    font.weight: typeScale.weightBold
                    font.family: Styles.ThemeStore.fonts.uiFallback
                    color: colors.text
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    renderType: Text.NativeRendering
                }
                
                Text {
                    text: {
                        if (overlay.modeString === "work") return qsTr("Fokus-Zeit")
                        if (overlay.modeString === "short_break") return qsTr("Kurze Pause")
                        if (overlay.modeString === "long_break") return qsTr("Lange Pause")
                        return qsTr("Fokus-Zeit")
                    }
                    font.pixelSize: typeScale.base
                    font.weight: typeScale.weightMedium
                    font.family: Styles.ThemeStore.fonts.uiFallback
                    color: colors.textMuted
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    renderType: Text.NativeRendering
                }
                
                // Round indicator
                Text {
                    text: qsTr("Runde %1 von %2").arg(overlay.currentRound).arg(overlay.totalRounds)
                    font.pixelSize: typeScale.sm
                    font.weight: typeScale.weightRegular
                    font.family: Styles.ThemeStore.fonts.uiFallback
                    color: colors.textMuted
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    renderType: Text.NativeRendering
                    visible: overlay.isActive && overlay.modeString === "work"
                }
            }
            
            // Controls
            Column {
                width: parent.width
                spacing: gaps.g12
                
                // Main control buttons
                Row {
                    spacing: gaps.g12
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    PillButton {
                        text: {
                            if (!overlay.isActive) return qsTr("Start")
                            if (overlay.isPaused) return qsTr("Fortsetzen")
                            return qsTr("Pause")
                        }
                        kind: "primary"
                        onClicked: {
                            if (!overlay.isActive) {
                                if (pomodoroTimer) {
                                    pomodoroTimer.startSession(selectedPreset, "")
                                }
                            } else if (overlay.isPaused) {
                                if (pomodoroTimer) pomodoroTimer.resume()
                            } else {
                                if (pomodoroTimer) pomodoroTimer.pause()
                            }
                        }
                    }
                    
                    PillButton {
                        text: qsTr("Stop")
                        kind: "neutral"
                        visible: overlay.isActive
                        onClicked: {
                            if (pomodoroTimer) pomodoroTimer.stop()
                            overlay.open = false
                            overlay.closed()
                        }
                    }
                }
                
                // Advanced controls
                Row {
                    spacing: gaps.g8
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: overlay.isActive
                    opacity: visible ? 1 : 0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    
                    PillButton {
                        text: qsTr("Überspringen")
                        kind: "ghost"
                        onClicked: {
                            if (pomodoroTimer) pomodoroTimer.skip()
                        }
                    }
                    
                    PillButton {
                        text: qsTr("+5 Min")
                        kind: "ghost"
                        onClicked: {
                            if (pomodoroTimer) pomodoroTimer.extend(5)
                        }
                    }
                }
            }
        }
    }
    
    // State management
    property string selectedPreset: "25/5"
    
    Connections {
        target: pomodoroTimer
        function onPhaseChanged(newPhase) {
            console.log("Pomodoro phase changed:", newPhase)
            // Could show notification here
        }
        
        function onRoundCompleted() {
            console.log("Pomodoro round completed")
            // Could show notification or play sound
        }
        
        function onSessionCompleted() {
            console.log("Pomodoro session completed")
            overlay.open = false
            overlay.finished()
        }
    }
    
    onOpenChanged: {
        if (open) {
            ring.requestPaint()
        }
    }
}
