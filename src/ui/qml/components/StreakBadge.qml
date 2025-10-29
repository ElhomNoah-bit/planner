import QtQuick
import QtQuick.Controls
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Item {
    id: badge
    property int streak: 0
    property bool compact: false
    
    width: compact ? 60 : 120
    height: compact ? 60 : 80
    
    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject radii: Styles.ThemeStore.radii
    
    Rectangle {
        anchors.fill: parent
        color: streak > 0 ? Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.1) : "transparent"
        border.color: streak > 0 ? colors.accent : colors.border
        border.width: 2
        radius: radii.md
        
        Column {
            anchors.centerIn: parent
            spacing: gaps.g4
            
            Text {
                text: "🔥"
                font.pixelSize: compact ? typeScale.xl : typeScale.monthTitle
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: streak > 0 ? 1.0 : 0.3
            }
            
            Text {
                text: streak.toString()
                font.pixelSize: compact ? typeScale.lg : typeScale.xl
                font.weight: typeScale.weightBold
                font.family: Styles.ThemeStore.fonts.uiFallback
                color: colors.text
                anchors.horizontalCenter: parent.horizontalCenter
                renderType: Text.NativeRendering
            }
            
            Text {
                text: qsTr("Tage")
                font.pixelSize: compact ? typeScale.xs : typeScale.sm
                font.family: Styles.ThemeStore.fonts.uiFallback
                color: colors.textSecondary
                anchors.horizontalCenter: parent.horizontalCenter
                renderType: Text.NativeRendering
                visible: !compact
            }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        ToolTip {
            visible: parent.containsMouse
            text: streak > 0 
                ? qsTr("%1 Tage Streak! Mindestens 30 Minuten pro Tag.").arg(streak)
                : qsTr("Keine aktive Streak. Fokussiere mindestens 30 Minuten heute!")
            delay: 500
        }
    }
}
