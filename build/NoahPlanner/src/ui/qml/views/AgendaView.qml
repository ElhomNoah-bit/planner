import QtQuick
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner.Styles as Styles

Flickable {
    id: root
    property var buckets: []
    anchors.fill: parent
    contentWidth: width
    contentHeight: contentItem.implicitHeight
    clip: true

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject radii: Styles.ThemeStore.radii
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject metrics: Styles.ThemeStore.layout

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
                        font.family: Styles.ThemeStore.fonts.uiFallback
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
                                        color: modelData.color
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: gaps.g4

                                        Text {
                                            text: modelData.title
                                            font.pixelSize: typeScale.md
                                            font.weight: typeScale.weightMedium
                                            font.family: Styles.ThemeStore.fonts.uiFallback
                                            color: colors.text
                                            elide: Text.ElideRight
                                            renderType: Text.NativeRendering
                                        }

                                        Text {
                                            text: modelData.goal
                                            font.pixelSize: typeScale.xs
                                            font.weight: typeScale.weightRegular
                                            font.family: Styles.ThemeStore.fonts.uiFallback
                                            color: colors.text2
                                            elide: Text.ElideRight
                                            renderType: Text.NativeRendering
                                        }
                                    }

                                    PillButton {
                                        kind: "ghost"
                                        text: qsTr("Zum Tag")
                                        onClicked: PlannerBackend.selectDateIso(modelData.iso)
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
        buckets = PlannerBackend.listBuckets()
    }

    Component.onCompleted: reload()

    Connections {
        target: PlannerBackend
        function onFiltersChanged() { reload() }
        function onTasksChanged() { reload() }
    }
}
