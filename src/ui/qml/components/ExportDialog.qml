import QtQuick
import QtQuick.Dialogs
import NoahPlanner 1.0

Item {
    id: exporter
    property alias planner: plannerConnection.target

    signal finished(bool success)

    function open(mode) {
        exporterMode = mode
        fileDialog.open()
    }

    property string exporterMode: "week"

    FileDialog {
        id: fileDialog
        title: exporterMode === "month" ? qsTr("Monat als PDF speichern") : qsTr("Woche als PDF speichern")
        fileMode: FileDialog.SaveFile
        nameFilters: [qsTr("PDF Dateien (*.pdf)")]
        onAccepted: {
            var url = selectedFile
            var path = url
            if (url && url.toString)
                path = url.toString()
            if (path && path.startsWith("file://"))
                path = path.substring(7)
            if (!path || !path.length)
                return
            var ok = false
            if (exporterMode === "month") {
                ok = exporter.planner ? exporter.planner.exportMonthPdf(path) : false
            } else {
                ok = exporter.planner ? exporter.planner.exportWeekPdf(path) : false
            }
            exporter.finished(ok)
        }
    }

    Connections {
        id: plannerConnection
        target: null
    }
}
