import QtQuick
import QtQuick.Layouts
import NoahPlanner 1.0
import Styles 1.0
import "../utils/Safe.js" as Safe

Flickable {
    id: root
    property var buckets: []
    contentWidth: width
    contentHeight: contentItem.implicitHeight
    clip: true

    readonly property QtObject colors: ThemeStore.colors
    readonly property QtObject gaps: ThemeStore.gap
    readonly property QtObject radii: ThemeStore.radii
    readonly property QtObject typeScale: ThemeStore.type
    readonly property QtObject metrics: ThemeStore.layout

    Column {
        id: contentItem
        width: root.width
        spacing: gaps.g24
        anchors.margins: 0

        Repeater {
            model: root.buckets
            delegate: GlassPanel {
                width: parent.width
                padding: gaps.g16

                Column {
                    width: parent.width
                    spacing: gaps.g16

                    Text {
                        text: modelData.label
                        font.pixelSize: typeScale.lg
                        font.weight: typeScale.weightMedium
                        font.family: ThemeStore.fonts.uiFallback
                        color: colors.text
                        renderType: Text.NativeRendering
                    }

                    Column {
                        spacing: gaps.g12
                        Repeater {
                            model: modelData.items
                            delegate: GlassPanel {
                                padding: gaps.g16

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: gaps.g12

                                    Rectangle {
                                        width: 10
                                        height: metrics.pillH
                                        radius: 6
                                        color: Safe.s(modelData && modelData.colorHint ? modelData.colorHint : ThemeStore.accent, ThemeStore.accent)
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Rectangle {
                                        width: 10
                                        height: 10
                                        radius: 5
                                        color: {
                                            if (!modelData) return colors.prioLow
                                            const priority = modelData.priority || 0
                                            if (priority === 2) return colors.prioHigh
                                            if (priority === 1) return colors.prioMedium
                                            return colors.prioLow
                                        }
                                        visible: modelData && !modelData.isDone
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: gaps.g4

                                        Text {
                                            text: Safe.s(modelData ? modelData.title : undefined)
                                            font.pixelSize: typeScale.md
                                            font.weight: typeScale.weightMedium
                                            font.family: ThemeStore.fonts.uiFallback
                                            color: colors.text
                                            elide: Text.ElideRight
                                            renderType: Text.NativeRendering
                                        }

                                        Text {
                                            text: Safe.s(modelData ? modelData.goal : undefined)
                                            font.pixelSize: typeScale.xs
                                            font.weight: typeScale.weightRegular
                                            font.family: ThemeStore.fonts.uiFallback
                                            color: colors.text2
                                            elide: Text.ElideRight
                                            renderType: Text.NativeRendering
                                        }
                                    }

                                    PillButton {
                                        kind: "ghost"
                                        text: qsTr("Zum Tag")
                                        onClicked: planner.selectDateIso(modelData.iso)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function reload() {
        buckets = planner.listBuckets()
    }

    Component.onCompleted: reload()

    Connections {
        target: planner
        function onEventsChanged() { reload() }
        function onOnlyOpenChanged() { reload() }
        function onSelectedDateChanged() { reload() }
    }
}
