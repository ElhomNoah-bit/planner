import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Item {
    id: exportDialog
    anchors.fill: parent
    visible: false
    z: 250

    property date selectedDate: new Date()
    property string exportType: "week"  // "week" or "month"

    signal exportRequested(string filePath)
    signal cancelled()

    function open(type, date) {
        exportDialog.exportType = type || "week"
        exportDialog.selectedDate = date || new Date()
        exportDialog.visible = true
        Qt.callLater(() => {
            filePathField.forceActiveFocus()
        })
    }

    function close() {
        exportDialog.visible = false
    }

    // Semi-transparent backdrop
    Rectangle {
        anchors.fill: parent
        color: Styles.ThemeStore.opacity80
        opacity: Styles.ThemeStore.backdropOpacity

        MouseArea {
            anchors.fill: parent
            onClicked: exportDialog.close()
        }
    }

    // Dialog panel
    GlassPanel {
        id: panel
        anchors.centerIn: parent
        width: Math.min(500, parent.width - 40)
        height: Math.min(350, parent.height - 40)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Label {
                    text: exportDialog.exportType === "week" ? "Woche exportieren" : "Monat exportieren"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: Styles.ThemeStore.text
                    Layout.fillWidth: true
                }

                Button {
                    text: "×"
                    font.pixelSize: 20
                    flat: true
                    onClicked: exportDialog.close()
                    
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: Styles.ThemeStore.textSoft
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? Styles.ThemeStore.surfaceHover : "transparent"
                        radius: 4
                    }
                }
            }

            // Description
            Label {
                text: {
                    if (exportDialog.exportType === "week") {
                        return "Exportiere die aktuelle Woche als PDF mit allen Terminen und Kategorien."
                    } else {
                        return "Exportiere den aktuellen Monat als PDF mit allen Terminen und Kategorien."
                    }
                }
                font.pixelSize: 13
                color: Styles.ThemeStore.textSoft
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            // Date info
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: Styles.ThemeStore.surfaceHover
                radius: 8

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Label {
                        text: "Zeitraum"
                        font.pixelSize: 11
                        color: Styles.ThemeStore.textSoft
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: {
                            let date = exportDialog.selectedDate
                            if (exportDialog.exportType === "week") {
                                // Calculate week range
                                let d = new Date(date)
                                while (d.getDay() !== 1) {  // Find Monday
                                    d.setDate(d.getDate() - 1)
                                }
                                let monday = d.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit', year: 'numeric' })
                                let sunday = new Date(d)
                                sunday.setDate(sunday.getDate() + 6)
                                let sundayStr = sunday.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit', year: 'numeric' })
                                return monday + " – " + sundayStr
                            } else {
                                return date.toLocaleDateString('de-DE', { month: 'long', year: 'numeric' })
                            }
                        }
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: Styles.ThemeStore.text
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // File path
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Label {
                    text: "Speicherort"
                    font.pixelSize: 12
                    color: Styles.ThemeStore.textSoft
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    TextField {
                        id: filePathField
                        Layout.fillWidth: true
                        placeholderText: {
                            let baseName = exportDialog.exportType === "week" ? "wochenplan" : "monatsplan"
                            let date = exportDialog.selectedDate
                            let dateStr = date.toISOString().split('T')[0]
                            return baseName + "_" + dateStr + ".pdf"
                        }
                        color: Styles.ThemeStore.text

                        background: Rectangle {
                            color: Styles.ThemeStore.surface
                            border.color: filePathField.activeFocus ? Styles.ThemeStore.primary : Styles.ThemeStore.border
                            border.width: 1
                            radius: 6
                        }

                        Keys.onReturnPressed: exportButton.clicked()
                        Keys.onEscapePressed: exportDialog.close()
                    }

                    Button {
                        text: "Durchsuchen..."
                        onClicked: fileDialog.open()

                        contentItem: Text {
                            text: parent.text
                            font: parent.font
                            color: Styles.ThemeStore.text
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            color: parent.hovered ? Styles.ThemeStore.surfaceHover : Styles.ThemeStore.surface
                            border.color: Styles.ThemeStore.border
                            border.width: 1
                            radius: 6
                        }
                    }
                }

                Label {
                    text: "Tipp: Lasse das Feld leer für einen automatischen Dateinamen"
                    font.pixelSize: 10
                    color: Styles.ThemeStore.textSoft
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            // Spacer
            Item {
                Layout.fillHeight: true
            }

            // Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: "Abbrechen"
                    onClicked: exportDialog.close()

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: Styles.ThemeStore.text
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? Styles.ThemeStore.surfaceHover : Styles.ThemeStore.surface
                        border.color: Styles.ThemeStore.border
                        border.width: 1
                        radius: 6
                    }
                }

                Button {
                    id: exportButton
                    text: "Exportieren"
                    onClicked: {
                        let filePath = filePathField.text.trim()
                        
                        // Generate default filename if empty
                        if (!filePath) {
                            let baseName = exportDialog.exportType === "week" ? "wochenplan" : "monatsplan"
                            let date = exportDialog.selectedDate
                            let dateStr = date.toISOString().split('T')[0]
                            
                            // Use home directory or a temp directory
                            // Qt will handle the path separator correctly
                            filePath = baseName + "_" + dateStr + ".pdf"
                        }

                        // Ensure .pdf extension
                        if (!filePath.toLowerCase().endsWith('.pdf')) {
                            filePath += '.pdf'
                        }

                        // Perform export
                        let dateStr = exportDialog.selectedDate.toISOString().split('T')[0]
                        let success = false
                        
                        if (exportDialog.exportType === "week") {
                            success = planner.exportWeekPdf(dateStr, filePath)
                        } else {
                            success = planner.exportMonthPdf(dateStr, filePath)
                        }

                        if (success) {
                            exportDialog.close()
                        }
                    }

                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.hovered ? Qt.darker(Styles.ThemeStore.primary, 1.1) : Styles.ThemeStore.primary
                        radius: 6
                    }
                }
            }
        }
    }

    // File dialog
    FileDialog {
        id: fileDialog
        fileMode: FileDialog.SaveFile
        nameFilters: ["PDF files (*.pdf)"]
        defaultSuffix: "pdf"
        onAccepted: {
            let path = selectedFile.toString()
            // Remove file:// prefix if present
            if (path.startsWith("file://")) {
                path = path.substring(7)
            }
            filePathField.text = path
        }
    }
}
