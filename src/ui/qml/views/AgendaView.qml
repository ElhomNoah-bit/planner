import QtQuick
import QtQuick.Layouts
import NoahPlanner 1.0
import "../styles" as Styles

Flickable {
    id: root
    property var buckets: []
    anchors.fill: parent
    contentWidth: width
    contentHeight: contentItem.implicitHeight
    clip: true

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var space: theme ? theme.space : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var typeScale: theme ? theme.type : null
    readonly property var layout: theme ? theme.layout : null

    Column {
        id: contentItem
        width: root.width
        spacing: space ? space.gap20 : 20
        anchors.margins: 0

        Repeater {
            model: root.buckets
            delegate: GlassPanel {
                width: parent.width
                padding: space ? space.gap20 : 20

                Column {
                    width: parent.width
                    spacing: space ? space.gap16 : 16

                    Text {
                        text: modelData.label
                        font.pixelSize: typeScale ? typeScale.lg : 18
                        font.weight: typeScale ? typeScale.weightBold : Font.DemiBold
                        font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                        color: colors ? colors.text : "#FFFFFF"
                        renderType: Text.NativeRendering
                    }

                    Column {
                        spacing: space ? space.gap12 : 12
                        Repeater {
                            model: modelData.items
                            delegate: GlassPanel {
                                padding: space ? space.gap16 : 16

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: space ? space.gap12 : 12

                                    Rectangle {
                                        width: 10
                                        height: layout ? layout.pillH : 30
                                        radius: 6
                                        color: modelData.color
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: space ? space.gap4 : 4

                                        Text {
                                            text: modelData.title
                                            font.pixelSize: typeScale ? typeScale.md : 15
                                            font.weight: typeScale ? typeScale.weightBold : Font.DemiBold
                                            font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                                            color: colors ? colors.text : "#FFFFFF"
                                            elide: Text.ElideRight
                                            renderType: Text.NativeRendering
                                        }

                                        Text {
                                            text: modelData.goal
                                            font.pixelSize: typeScale ? typeScale.metaSize : 12
                                            font.weight: typeScale ? typeScale.metaWeight : Font.Normal
                                            font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                                            color: colors ? colors.textMuted : "#9AA3AF"
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
