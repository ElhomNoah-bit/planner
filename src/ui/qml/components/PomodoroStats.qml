import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

GlassPanel {
    id: statsPanel
    property QtObject pomodoroTimer: null
    
    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject radii: Styles.ThemeStore.radii
    
    readonly property int totalFocusMinutes: pomodoroTimer ? pomodoroTimer.totalFocusMinutes : 0
    readonly property int totalRounds: pomodoroTimer ? pomodoroTimer.totalCompletedRounds : 0
    
    padding: gaps.g16
    
    ColumnLayout {
        anchors.fill: parent
        spacing: gaps.g16
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: gaps.g8
            
            Text {
                text: "🍅"
                font.pixelSize: typeScale.lg
                renderType: Text.NativeRendering
            }
            
            Text {
                text: qsTr("Pomodoro Statistiken")
                font.pixelSize: typeScale.lg
                font.weight: typeScale.weightBold
                font.family: Styles.ThemeStore.fonts.heading
                color: colors.text
                renderType: Text.NativeRendering
                Layout.fillWidth: true
            }
        }
        
        // Statistics Grid
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: gaps.g12
            columnSpacing: gaps.g16
            
            // Total Focus Time
            ColumnLayout {
                Layout.fillWidth: true
                spacing: gaps.g4
                
                Text {
                    text: totalFocusMinutes.toString()
                    font.pixelSize: 32
                    font.weight: typeScale.weightBold
                    font.family: Styles.ThemeStore.fonts.heading
                    color: colors.accent
                    renderType: Text.NativeRendering
                }
                
                Text {
                    text: qsTr("Fokus-Minuten")
                    font.pixelSize: typeScale.sm
                    font.weight: typeScale.weightRegular
                    font.family: Styles.ThemeStore.fonts.body
                    color: colors.textMuted
                    renderType: Text.NativeRendering
                }
            }
            
            // Total Rounds
            ColumnLayout {
                Layout.fillWidth: true
                spacing: gaps.g4
                
                Text {
                    text: totalRounds.toString()
                    font.pixelSize: 32
                    font.weight: typeScale.weightBold
                    font.family: Styles.ThemeStore.fonts.heading
                    color: colors.accent
                    renderType: Text.NativeRendering
                }
                
                Text {
                    text: qsTr("Abgeschlossene Runden")
                    font.pixelSize: typeScale.sm
                    font.weight: typeScale.weightRegular
                    font.family: Styles.ThemeStore.fonts.body
                    color: colors.textMuted
                    renderType: Text.NativeRendering
                }
            }
            
            // Average Session Length
            ColumnLayout {
                Layout.fillWidth: true
                spacing: gaps.g4
                
                Text {
                    text: totalRounds > 0 ? Math.round(totalFocusMinutes / totalRounds).toString() : "0"
                    font.pixelSize: 32
                    font.weight: typeScale.weightBold
                    font.family: Styles.ThemeStore.fonts.heading
                    color: colors.success || "#10B981"
                    renderType: Text.NativeRendering
                }
                
                Text {
                    text: qsTr("Ø Min./Runde")
                    font.pixelSize: typeScale.sm
                    font.weight: typeScale.weightRegular
                    font.family: Styles.ThemeStore.fonts.body
                    color: colors.textMuted
                    renderType: Text.NativeRendering
                }
            }
            
            // Focus Hours
            ColumnLayout {
                Layout.fillWidth: true
                spacing: gaps.g4
                
                Text {
                    text: (totalFocusMinutes / 60).toFixed(1)
                    font.pixelSize: 32
                    font.weight: typeScale.weightBold
                    font.family: Styles.ThemeStore.fonts.heading
                    color: colors.success || "#10B981"
                    renderType: Text.NativeRendering
                }
                
                Text {
                    text: qsTr("Fokus-Stunden")
                    font.pixelSize: typeScale.sm
                    font.weight: typeScale.weightRegular
                    font.family: Styles.ThemeStore.fonts.body
                    color: colors.textMuted
                    renderType: Text.NativeRendering
                }
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: colors.divider
        }
        
        // Motivation Text
        Text {
            text: {
                if (totalRounds === 0) return qsTr("Starte deine erste Fokus-Session! 🚀")
                if (totalRounds < 5) return qsTr("Guter Start! Weiter so! 💪")
                if (totalRounds < 20) return qsTr("Du bist auf einem guten Weg! 🎯")
                if (totalRounds < 50) return qsTr("Beeindruckender Fokus! ⭐")
                return qsTr("Du bist ein Fokus-Meister! 🏆")
            }
            font.pixelSize: typeScale.sm
            font.weight: typeScale.weightMedium
            font.family: Styles.ThemeStore.fonts.body
            color: colors.text2
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            renderType: Text.NativeRendering
        }
        
        Item {
            Layout.fillHeight: true
        }
    }
}
