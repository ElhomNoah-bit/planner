import QtQuick
import NoahPlanner.Styles as Styles

Item {
    id: root
    property var options: [
        { "label": qsTr("Monat"), "value": "month" },
        { "label": qsTr("Woche"), "value": "week" },
        { "label": qsTr("Liste"), "value": "list" }
    ]
    property int currentIndex: 0
    signal activated(string value, int index)

    implicitHeight: Math.max(Styles.ThemeStore.layout.pillH, 36)
    implicitWidth: 260

    readonly property QtObject colors: Styles.ThemeStore.colors
    readonly property QtObject gaps: Styles.ThemeStore.gap
    readonly property QtObject radii: Styles.ThemeStore.radii
    readonly property QtObject typeScale: Styles.ThemeStore.type

    Rectangle {
        id: track
        anchors.fill: parent
        radius: radii.xl
        color: colors.cardBg
        border.width: 1
        border.color: colors.divider
    }

    Rectangle {
        id: indicator
        anchors.verticalCenter: parent.verticalCenter
        width: root.options.length > 0 ? (parent.width - 8) / root.options.length : 0
        height: parent.height - 8
        radius: radii.xl
        color: colors.accent
        visible: root.options.length > 0
        x: 4 + root.currentIndex * width
        Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
    }

    Row {
        id: row
        anchors.fill: parent
        anchors.margins: 4
        spacing: 0
        Repeater {
            model: root.options
            delegate: Item {
                width: row.width / Math.max(1, root.options.length)
                height: row.height
                property var option: modelData
                HoverHandler { id: hover }
                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: {
                        if (index !== root.currentIndex) {
                            root.activated(option.value, index)
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: option.label
                    font.pixelSize: typeScale.sm
                    font.weight: index === root.currentIndex ? typeScale.weightBold : typeScale.weightMedium
                    font.family: Styles.ThemeStore.fonts.uiFallback
                    color: index === root.currentIndex
                        ? colors.appBg
                        : (hover.hovered ? colors.text : colors.text2)
                    renderType: Text.NativeRendering
                }
            }
        }
    }
}
