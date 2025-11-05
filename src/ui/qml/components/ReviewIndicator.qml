import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner.Styles

/**
 * ReviewIndicator - Shows due reviews count and provides quick access
 * 
 * Displays the number of reviews due today with a clickable badge.
 * Can be placed in the sidebar or header for quick visibility.
 */
Item {
    id: root
    
    property int dueCount: 0
    signal clicked()
    
    width: badge.width
    height: badge.height
    
    visible: dueCount > 0
    
    Rectangle {
        id: badge
        width: contentRow.width + 16
        height: 28
        radius: 14
        color: ThemeStore.theme.accent
        
        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: 6
            
            Text {
                text: "🔄"
                font.pixelSize: 14
            }
            
            Text {
                text: root.dueCount
                font.pixelSize: 13
                font.weight: Font.Bold
                color: "white"
            }
            
            Text {
                text: root.dueCount === 1 ? "Wiederholung" : "Wiederholungen"
                font.pixelSize: 12
                color: "white"
                visible: root.width > 80
            }
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            
            onClicked: root.clicked()
            onEntered: badge.opacity = 0.9
            onExited: badge.opacity = 1.0
            
            ToolTip.visible: mouseArea.containsMouse
            ToolTip.text: root.dueCount === 1 
                          ? qsTr("1 Wiederholung fällig heute")
                          : qsTr("%1 Wiederholungen fällig heute").arg(root.dueCount)
            ToolTip.delay: 500
        }
    }
}
