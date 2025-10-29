import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Item {
    id: heatmap
    property var weeklyData: []  // Array of {date, minutes, dayName}
    property int maxMinutes: 120  // Maximum expected minutes for scaling
    
    implicitHeight: 180
    
    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject radii: Styles.ThemeStore.radii
    
    Column {
        anchors.fill: parent
        spacing: gaps.g12
        
        Text {
            text: qsTr("Fokuszeit diese Woche")
            font.pixelSize: typeScale.sm
            font.weight: typeScale.weightMedium
            font.family: Styles.ThemeStore.fonts.uiFallback
            color: colors.text
            renderType: Text.NativeRendering
        }
        
        Row {
            spacing: gaps.g8
            width: parent.width
            
            Repeater {
                model: weeklyData
                
                delegate: Column {
                    spacing: gaps.g4
                    width: (heatmap.width - (gaps.g8 * 6)) / 7
                    
                    Rectangle {
                        width: parent.width
                        height: 80
                        color: colors.background
                        border.color: colors.border
                        radius: radii.sm
                        
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 2
                            
                            height: {
                                var minutes = modelData.minutes || 0;
                                var ratio = Math.min(minutes / maxMinutes, 1.0);
                                return Math.max(4, (parent.height - 4) * ratio);
                            }
                            
                            color: {
                                var minutes = modelData.minutes || 0;
                                if (minutes === 0) return "transparent";
                                if (minutes < 15) return Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.2);
                                if (minutes < 30) return Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.4);
                                if (minutes < 60) return Qt.rgba(colors.accent.r, colors.accent.g, colors.accent.b, 0.6);
                                return colors.accent;
                            }
                            
                            radius: radii.xs
                            
                            Behavior on height {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.minutes || 0
                            font.pixelSize: typeScale.xs
                            font.weight: typeScale.weightMedium
                            font.family: Styles.ThemeStore.fonts.uiFallback
                            color: (modelData.minutes || 0) > 30 ? colors.background : colors.textSecondary
                            renderType: Text.NativeRendering
                            visible: (modelData.minutes || 0) > 0
                        }
                    }
                    
                    Text {
                        text: modelData.dayName || ""
                        font.pixelSize: typeScale.xs
                        font.family: Styles.ThemeStore.fonts.uiFallback
                        color: colors.textSecondary
                        anchors.horizontalCenter: parent.horizontalCenter
                        renderType: Text.NativeRendering
                    }
                }
            }
        }
        
        Text {
            text: {
                var total = 0;
                for (var i = 0; i < weeklyData.length; i++) {
                    total += weeklyData[i].minutes || 0;
                }
                return qsTr("Gesamt: %1 Minuten").arg(total);
            }
            font.pixelSize: typeScale.xs
            font.family: Styles.ThemeStore.fonts.uiFallback
            color: colors.textSecondary
            renderType: Text.NativeRendering
        }
    }
}
