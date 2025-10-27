import QtQuick
import QtQuick.Layouts
import NoahPlanner 1.0
import NoahPlanner 1.0 as NP

Flickable {
    id: root
    property var buckets: []
    anchors.fill: parent
    contentWidth: width
    contentHeight: contentItem.implicitHeight
    clip: true

    Column {
        id: contentItem
        width: root.width
        spacing: NP.ThemeStore.spacing.gap16
        anchors.margins: 0

        Repeater {
            model: root.buckets
            delegate: GlassPanel {
                width: parent.width
                radius: NP.ThemeStore.radii.lg
                Column {
                    anchors.fill: parent
                    spacing: NP.ThemeStore.spacing.gap12

                    Text {
                        text: modelData.label
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        font.preferredFamilies: NP.ThemeStore.fonts.stack
                        color: NP.ThemeStore.text
                    }

                    Column {
                        spacing: NP.ThemeStore.spacing.gap8
                        Repeater {
                            model: modelData.items
                            delegate: Rectangle {
                                radius: NP.ThemeStore.radii.md
                                height: 52
                                color: Qt.rgba(1, 1, 1, NP.ThemeStore.dark ? 0.08 : 0.12)
                                border.color: NP.ThemeStore.border
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: NP.ThemeStore.spacing.gap12

                                    Rectangle {
                                        width: 10
                                        radius: 5
                                        color: modelData.color
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Column {
                                        width: parent.width - 120
                                        spacing: 4
                                        Text {
                                            text: modelData.title
                                            font.pixelSize: 15
                                            font.weight: Font.DemiBold
                                            font.preferredFamilies: NP.ThemeStore.fonts.stack
                                            color: NP.ThemeStore.text
                                            elide: Text.ElideRight
                                        }
                                        Text {
                                            text: modelData.goal
                                            font.pixelSize: NP.ThemeStore.typography.metaSize
                                            font.weight: NP.ThemeStore.typography.metaWeight
                                            font.preferredFamilies: NP.ThemeStore.fonts.stack
                                            color: NP.ThemeStore.muted
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
