import QtQuick
import QtQuick.Layouts
import NoahPlanner 1.0
import styles 1.0 as Styles

Flickable {
    id: root
    property var buckets: []
    anchors.fill: parent
    contentWidth: width
    contentHeight: contentItem.implicitHeight
    clip: true

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var gap: theme ? theme.gap : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var typeScale: theme ? theme.type : null
    readonly property var layout: theme ? theme.layout : null

    Column {
        id: contentItem
        width: root.width
    spacing: gap ? gap.g24 : 24
        anchors.margins: 0

        Repeater {
            model: root.buckets
            delegate: GlassPanel {
                width: parent.width
                padding: gap ? gap.g16 : 16

                Column {
                    width: parent.width
                    spacing: gap ? gap.g16 : 16

                    Text {
                        text: modelData.label
                        font.pixelSize: typeScale ? typeScale.lg : 16
                        font.weight: typeScale ? typeScale.weightMedium : Font.Medium
                        font.family: Styles.ThemeStore.fonts.uiFallback
                        color: colors ? colors.text : "#F2F5F9"
                        renderType: Text.NativeRendering
                    }

                    Column {
                        spacing: gap ? gap.g12 : 12
                        Repeater {
                            model: modelData.items
                            delegate: GlassPanel {
                                padding: gap ? gap.g16 : 16

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: gap ? gap.g12 : 12

                                    Rectangle {
                                        width: 10
                                        height: layout ? layout.pillH : 30
                                        radius: 6
                                        color: modelData.color
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: gap ? gap.g4 : 4

                                        Text {
                                            text: modelData.title
                                            font.pixelSize: typeScale ? typeScale.md : 14
                                            font.weight: typeScale ? typeScale.weightMedium : Font.Medium
                                            font.family: Styles.ThemeStore.fonts.uiFallback
                                            color: colors ? colors.text : "#F2F5F9"
                                            elide: Text.ElideRight
                                            renderType: Text.NativeRendering
                                        }

                                        Text {
                                            text: modelData.goal
                                            font.pixelSize: typeScale ? typeScale.metaSize : 11
                                            font.weight: typeScale ? typeScale.weightRegular : Font.Normal
                                            font.family: Styles.ThemeStore.fonts.uiFallback
                                            color: colors ? colors.text2 : "#B7C0CC"
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
