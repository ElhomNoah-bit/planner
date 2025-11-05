import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Styles 1.0

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
        color: ThemeStore.surface
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: ThemeStore.gapMd
            spacing: ThemeStore.gapSm
            
            Text {
                text: "📚 Reviews"
                font.pixelSize: 18
                font.weight: Font.Bold
                color: ThemeStore.text
            }
            
            Rectangle {
                width: dueText.width + 16
                height: 24
                radius: 12
                color: ThemeStore.accent
                visible: backend && backend.dueReviewCount > 0
                
                Text {
                    id: dueText
                    anchors.centerIn: parent
                    text: backend ? backend.dueReviewCount + " fällig" : ""
                    font.pixelSize: ThemeStore.type.xs
                    font.weight: ThemeStore.type.weightBold
                    color: ThemeStore.surfaceOnWeak
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
        spacing: ThemeStore.gapSm
        
        // Tab bar for filtering
        RowLayout {
            Layout.fillWidth: true
            spacing: ThemeStore.gapSm
            
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
            spacing: ThemeStore.gapSm
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
                height: delegateLayout.implicitHeight + ThemeStore.gapSm * 2
                color: modelData.isDue
                       ? Qt.rgba(ThemeStore.accent.r, ThemeStore.accent.g, ThemeStore.accent.b, 0.14)
                       : ThemeStore.surfaceAlt
                radius: ThemeStore.radii.md
                border.width: 1
                border.color: ThemeStore.divider
                
                ColumnLayout {
                    id: delegateLayout
                    anchors.fill: parent
                    anchors.margins: ThemeStore.gapSm
                    spacing: ThemeStore.gapSm
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: ThemeStore.gapSm
                        
                        Text {
                            text: modelData.topic
                            font.pixelSize: ThemeStore.type.md
                            font.weight: ThemeStore.type.weightBold
                            color: ThemeStore.text
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: modelData.isDue ? "🔴 Fällig" : "⏳ " + modelData.nextReviewDate
                            font.pixelSize: ThemeStore.type.xs
                            color: modelData.isDue ? ThemeStore.danger : ThemeStore.textSecondary
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
                        spacing: ThemeStore.gapMd
                        
                        Text {
                            text: "Fach: " + modelData.subjectId
                            font.pixelSize: ThemeStore.type.xs
                            color: ThemeStore.textSecondary
                        }
                        
                        Text {
                            text: "Wiederholungen: " + modelData.repetitionNumber
                            font.pixelSize: ThemeStore.type.xs
                            color: ThemeStore.textSecondary
                        }
                        
                        Text {
                            text: "Intervall: " + modelData.intervalDays + " Tage"
                            font.pixelSize: ThemeStore.type.xs
                            color: ThemeStore.textSecondary
                        }
                        
                        Text {
                            text: "EF: " + modelData.easeFactor.toFixed(2)
                            font.pixelSize: ThemeStore.type.xs
                            color: ThemeStore.textSecondary
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
            anchors.margins: ThemeStore.gapMd
            spacing: ThemeStore.gapMd
            
            Text {
                text: "Neues Review hinzufügen"
                font.pixelSize: ThemeStore.type.lg
                font.weight: ThemeStore.type.weightBold
                color: ThemeStore.text
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
                spacing: ThemeStore.gapSm
                
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
            anchors.margins: ThemeStore.gapMd
            spacing: ThemeStore.gapMd
            
            Text {
                text: "Review: " + performReviewPopup.topic
                font.pixelSize: ThemeStore.type.lg
                font.weight: ThemeStore.type.weightBold
                color: ThemeStore.text
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            
            Text {
                text: "Wie gut konntest du dich erinnern?"
                font.pixelSize: ThemeStore.type.sm
                color: ThemeStore.textSecondary
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: ThemeStore.gapSm
                
                Repeater {
                    model: [
                        { value: 5, label: "5 - Perfekte Antwort", color: ThemeStore.ok },
                        { value: 4, label: "4 - Richtig nach kurzem Überlegen", color: ThemeStore.ok },
                        { value: 3, label: "3 - Richtig mit Schwierigkeit", color: ThemeStore.warning },
                        { value: 2, label: "2 - Falsch, aber leicht zu erinnern", color: ThemeStore.warning },
                        { value: 1, label: "1 - Falsch, aber erinnert", color: ThemeStore.danger },
                        { value: 0, label: "0 - Keine Erinnerung", color: ThemeStore.danger }
                    ]
                    
                    Button {
                        Layout.fillWidth: true
                        text: modelData.label
                        
                        background: Rectangle {
                            color: parent.down ? Qt.darker(modelData.color, 1.2) : modelData.color
                            radius: ThemeStore.radii.sm
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: ThemeStore.type.sm
                            color: ThemeStore.surfaceOnWeak
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
