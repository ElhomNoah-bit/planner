import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import Styles 1.0 as Styles

Rectangle {
    id: root
    property var categories: []
    property string selectedCategoryId: ""
    signal categorySelected(string categoryId)

    implicitWidth: 200
    implicitHeight: Math.min(400, contentColumn.implicitHeight + Styles.ThemeStore.g16)
    radius: Styles.ThemeStore.r12
    color: Styles.ThemeStore.colors.cardBg
    border.width: 1
    border.color: Styles.ThemeStore.colors.divider

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject typeScale: Styles.ThemeStore.type
    readonly property QtObject fonts: Styles.ThemeStore.fonts

    Flickable {
        anchors.fill: parent
        anchors.margins: gaps.g8
        contentWidth: width
        contentHeight: contentColumn.implicitHeight
        clip: true

        ColumnLayout {
            id: contentColumn
            width: parent.width
            spacing: gaps.g4

            Label {
                text: qsTr("Keine Kategorie")
                font.pixelSize: typeScale.sm
                font.weight: typeScale.weightMedium
                font.family: fonts.body
                color: root.selectedCategoryId === "" ? colors.accent : colors.text
                Layout.fillWidth: true
                padding: gaps.g8
                renderType: Text.NativeRendering

                background: Rectangle {
                    radius: Styles.ThemeStore.r8
                    color: root.selectedCategoryId === "" ? colors.accentBg : "transparent"
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.categorySelected("")

                    onEntered: parent.background.opacity = 0.8
                    onExited: parent.background.opacity = 1.0
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: colors.divider
            }

            Repeater {
                model: root.categories
                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: gaps.g8

                    property bool isSelected: root.selectedCategoryId === modelData.id

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 4
                        color: modelData.color || colors.accent
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Label {
                        text: modelData.name
                        font.pixelSize: typeScale.sm
                        font.weight: parent.isSelected ? typeScale.weightBold : typeScale.weightMedium
                        font.family: fonts.body
                        color: parent.isSelected ? colors.accent : colors.text
                        Layout.fillWidth: true
                        renderType: Text.NativeRendering
                    }

                    background: Rectangle {
                        radius: Styles.ThemeStore.r8
                        color: parent.isSelected ? colors.accentBg : "transparent"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.categorySelected(modelData.id)

                        onEntered: parent.background.opacity = 0.8
                        onExited: parent.background.opacity = 1.0
                    }
                }
            }
        }
    }
}
