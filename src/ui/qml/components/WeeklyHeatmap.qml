import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Styles 1.0 as Styles

Item {
    id: heatmap
    property var entries: []
    property int cellSize: 16
    property int maxMinutes: 120

    implicitHeight: cellSize + Styles.ThemeStore.gap.g4 * 2
    implicitWidth: (cellSize + Styles.ThemeStore.gap.g4) * (entries ? entries.length : 0)

    RowLayout {
        anchors.centerIn: parent
        spacing: Styles.ThemeStore.gap.g4

        Repeater {
            model: heatmap.entries || []
            delegate: ColumnLayout {
                spacing: Styles.ThemeStore.gap.g4 / 2
                Layout.alignment: Qt.AlignHCenter

                Rectangle {
                    width: heatmap.cellSize
                    height: heatmap.cellSize
                    radius: Styles.ThemeStore.radii.sm
                    color: {
                        const minutes = modelData ? (modelData.minutes || 0) : 0
                        const ratio = Math.min(1, minutes / Math.max(1, heatmap.maxMinutes))
                        const base = Styles.ThemeStore.colors.accent
                        const alpha = 0.2 + ratio * 0.6
                        return Qt.rgba(base.r, base.g, base.b, alpha)
                    }
                    border.width: (modelData && modelData.completed) ? 2 : 0
                    border.color: Styles.ThemeStore.colors.focus
                    ToolTip.visible: hoverHandler.hovered
                    ToolTip.delay: 300
                    ToolTip.text: {
                        if (!modelData)
                            return ""
                        const date = modelData.date || ""
                        const minutes = modelData.minutes || 0
                        return qsTr("%1 – %2 Minuten").arg(date).arg(minutes)
                    }

                    HoverHandler { id: hoverHandler }
                }

                Text {
                    text: {
                        if (!modelData)
                            return ""
                        const date = modelData.date || ""
                        if (date.length < 10)
                            return ""
                        const iso = new Date(date)
                        if (iso.toString() === "Invalid Date")
                            return ""
                        return Qt.formatDate(iso, "dd")
                    }
                    font.pixelSize: Styles.ThemeStore.type.xs
                    color: Styles.ThemeStore.colors.text2
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
