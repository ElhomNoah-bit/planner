import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner.Styles

/**
 * ReviewDialog - Manage spaced repetition reviews
 * 
 * Allows users to:
 * - View all reviews
 * - Add new review items
 * - Record review performance (quality 0-5)
 * - See due reviews
 */
Dialog {
    id: root
    
    title: "Spaced Repetition Reviews"
    modal: true
    width: 600
    height: 500
    
    property var backend: null
    
    header: Rectangle {
        height: 60
        color: ThemeStore.theme.surface
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12
            
            Text {
                text: "📚 Reviews"
                font.pixelSize: 18
                font.weight: Font.Bold
                color: ThemeStore.theme.text
            }
            
            Rectangle {
                width: dueText.width + 16
                height: 24
                radius: 12
                color: ThemeStore.theme.accent
                visible: backend && backend.dueReviewCount > 0
                
                Text {
                    id: dueText
                    anchors.centerIn: parent
                    text: backend ? backend.dueReviewCount + " fällig" : ""
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: "white"
                }
            }
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "Neues Review"
                onClicked: addReviewPopup.open()
            }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 8
        
        // Tab bar for filtering
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Button {
                text: "Alle"
                flat: true
                checked: listView.filterMode === "all"
                onClicked: listView.filterMode = "all"
            }
            
            Button {
                text: "Fällig"
                flat: true
                checked: listView.filterMode === "due"
                onClicked: listView.filterMode = "due"
            }
            
            Item { Layout.fillWidth: true }
        }
        
        // Reviews list
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            clip: true
            
            property string filterMode: "all"
            
            model: {
                if (!backend) return []
                
                const all = backend.getAllReviews()
                if (filterMode === "due") {
                    return all.filter(r => r.isDue)
                }
                return all
            }
            
            delegate: Rectangle {
                width: listView.width
                height: delegateLayout.height + 16
                color: modelData.isDue ? ThemeStore.theme.accent + "20" : ThemeStore.theme.surface
                radius: 8
                border.width: 1
                border.color: ThemeStore.theme.border
                
                ColumnLayout {
                    id: delegateLayout
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 12
                    spacing: 8
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: modelData.topic
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: ThemeStore.theme.text
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: modelData.isDue ? "🔴 Fällig" : "⏳ " + modelData.nextReviewDate
                            font.pixelSize: 11
                            color: modelData.isDue ? ThemeStore.theme.error : ThemeStore.theme.textSecondary
                        }
                        
                        Button {
                            text: "Review"
                            visible: modelData.isDue
                            onClicked: {
                                performReviewPopup.reviewId = modelData.id
                                performReviewPopup.topic = modelData.topic
                                performReviewPopup.open()
                            }
                        }
                        
                        Button {
                            text: "×"
                            flat: true
                            onClicked: {
                                if (backend) {
                                    backend.removeReview(modelData.id)
                                    listView.model = backend.getAllReviews()
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Fach: " + modelData.subjectId
                            font.pixelSize: 11
                            color: ThemeStore.theme.textSecondary
                        }
                        
                        Text {
                            text: "Wiederholungen: " + modelData.repetitionNumber
                            font.pixelSize: 11
                            color: ThemeStore.theme.textSecondary
                        }
                        
                        Text {
                            text: "Intervall: " + modelData.intervalDays + " Tage"
                            font.pixelSize: 11
                            color: ThemeStore.theme.textSecondary
                        }
                        
                        Text {
                            text: "EF: " + modelData.easeFactor.toFixed(2)
                            font.pixelSize: 11
                            color: ThemeStore.theme.textSecondary
                        }
                    }
                }
            }
            
            ScrollBar.vertical: ScrollBar {}
        }
    }
    
    // Add review popup
    Popup {
        id: addReviewPopup
        anchors.centerIn: parent
        width: 400
        height: 200
        modal: true
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 12
            
            Text {
                text: "Neues Review hinzufügen"
                font.pixelSize: 16
                font.weight: Font.Bold
                color: ThemeStore.theme.text
            }
            
            TextField {
                id: subjectField
                Layout.fillWidth: true
                placeholderText: "Fach-ID (z.B. ma, en, de)"
            }
            
            TextField {
                id: topicField
                Layout.fillWidth: true
                placeholderText: "Thema (z.B. Quadratische Gleichungen)"
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "Abbrechen"
                    onClicked: addReviewPopup.close()
                }
                
                Button {
                    text: "Hinzufügen"
                    enabled: subjectField.text.length > 0 && topicField.text.length > 0
                    onClicked: {
                        if (backend) {
                            backend.addReview(subjectField.text, topicField.text)
                            listView.model = backend.getAllReviews()
                        }
                        subjectField.text = ""
                        topicField.text = ""
                        addReviewPopup.close()
                    }
                }
            }
        }
    }
    
    // Perform review popup
    Popup {
        id: performReviewPopup
        anchors.centerIn: parent
        width: 450
        height: 350
        modal: true
        
        property string reviewId: ""
        property string topic: ""
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 16
            
            Text {
                text: "Review: " + performReviewPopup.topic
                font.pixelSize: 16
                font.weight: Font.Bold
                color: ThemeStore.theme.text
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            
            Text {
                text: "Wie gut konntest du dich erinnern?"
                font.pixelSize: 13
                color: ThemeStore.theme.textSecondary
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Repeater {
                    model: [
                        { value: 5, label: "5 - Perfekte Antwort", color: "#10b981" },
                        { value: 4, label: "4 - Richtig nach kurzem Überlegen", color: "#22c55e" },
                        { value: 3, label: "3 - Richtig mit Schwierigkeit", color: "#eab308" },
                        { value: 2, label: "2 - Falsch, aber leicht zu erinnern", color: "#f97316" },
                        { value: 1, label: "1 - Falsch, aber erinnert", color: "#ef4444" },
                        { value: 0, label: "0 - Keine Erinnerung", color: "#dc2626" }
                    ]
                    
                    Button {
                        Layout.fillWidth: true
                        text: modelData.label
                        
                        background: Rectangle {
                            color: parent.down ? Qt.darker(modelData.color, 1.2) : modelData.color
                            radius: 6
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 12
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            if (backend) {
                                backend.recordReview(performReviewPopup.reviewId, modelData.value)
                                listView.model = backend.getAllReviews()
                            }
                            performReviewPopup.close()
                        }
                    }
                }
            }
        }
    }
    
    standardButtons: Dialog.Close
}
