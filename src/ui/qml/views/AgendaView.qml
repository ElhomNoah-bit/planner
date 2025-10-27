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

    Column {
        id: contentItem
        width: root.width
        spacing: space ? space.gap16 : 16
        anchors.margins: 0

        Repeater {
            model: root.buckets
            delegate: GlassPanel {
                width: parent.width
                radius: radii ? radii.lg : 16
                Column {
                    anchors.fill: parent
                    spacing: space ? space.gap12 : 12

                    Text {
                        text: modelData.label
                        font.pixelSize: typeScale ? typeScale.lg : 18
                        font.weight: typeScale ? typeScale.weightBold : Font.DemiBold
                        font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                        color: colors ? colors.text : "#FFFFFF"
                    }

                    Column {
                        spacing: space ? space.gap8 : 8
                        Repeater {
                            model: modelData.items
                            delegate: Rectangle {
                                radius: radii ? radii.md : 14
                                height: 52
                                color: Qt.rgba(1, 1, 1, theme ? theme.glassBack : 0.12)
                                border.color: colors ? colors.divider : Qt.rgba(1, 1, 1, 0.18)
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: space ? space.gap16 : 16
                                    spacing: space ? space.gap12 : 12

                                    Rectangle {
                                        width: 10
                                        radius: 5
                                        color: modelData.color
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        width: parent.width - 120
                                        spacing: space ? space.gap4 : 4
                                        Text {
                                            text: modelData.title
                                            font.pixelSize: typeScale ? typeScale.md : 15
                                            font.weight: typeScale ? typeScale.weightBold : Font.DemiBold
                                            font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                                            color: colors ? colors.text : "#FFFFFF"
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: modelData.goal
                                            font.pixelSize: typeScale ? typeScale.metaSize : 12
                                            font.weight: typeScale ? typeScale.metaWeight : Font.Normal
                                            font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                                            color: colors ? colors.textMuted : "#9AA3AF"
                                            elide: Text.ElideRight
                                        }
                                    }

                                    PillButton {
                                        text: qsTr("Zum Tag")
                                        subtle: true
                                        onClicked: {
                                            PlannerBackend.selectDateIso(modelData.iso)
                                        }
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
