import QtQuick
import styles 1.0 as Styles

Item {
    id: root
    property var options: [
        { "label": qsTr("Monat"), "value": "month" },
        { "label": qsTr("Woche"), "value": "week" },
        { "label": qsTr("Liste"), "value": "list" }
    ]
    property string value: options.length > 0 ? options[0].value : ""

    implicitHeight: Styles.ThemeStore.layout.pillH
    implicitWidth: 260

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var gap: theme ? theme.gap : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var typeScale: theme ? theme.type : null

    Rectangle {
        id: track
        anchors.fill: parent
        radius: radii ? radii.xl : 20
        color: colors ? colors.hover : Qt.rgba(1, 1, 1, 0.12)
        border.color: colors ? colors.divider : Qt.rgba(1, 1, 1, 0.18)
        border.width: 1
    }

    Rectangle {
        id: indicator
        anchors.verticalCenter: parent.verticalCenter
        width: root.options.length > 0 ? (parent.width - (gap ? gap.g8 : 8)) / root.options.length : 0
        height: parent.height - (gap ? gap.g8 : 8)
        radius: radii ? radii.xl : 20
        color: colors ? colors.accent : "#0A84FF"
        visible: root.options.length > 0
        x: (gap ? gap.g4 : 4) + currentIndex() * width
        Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
        Behavior on width { NumberAnimation { duration: 140; easing.type: Easing.InOutQuad } }
    }

    Row {
        id: row
        anchors.fill: parent
        anchors.margins: gap ? gap.g4 : 4
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
                        if (root.value !== option.value) {
                            root.value = option.value
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: option.label
                    font.pixelSize: typeScale ? typeScale.sm : 12
                    font.weight: root.value === option.value
                        ? (typeScale ? typeScale.weightBold : Font.Bold)
                        : (typeScale ? typeScale.weightMedium : Font.Medium)
                    font.family: Styles.ThemeStore.fonts.uiFallback
                    color: root.value === option.value
                        ? (colors ? colors.appBg : "#0F1115")
                        : (hover.hovered ? (colors ? colors.text : "#F2F5F9") : (colors ? colors.text2 : "#B7C0CC"))
                    renderType: Text.NativeRendering
                }
            }
        }
    }

    function currentIndex() {
        for (var i = 0; i < root.options.length; ++i) {
            if (root.options[i].value === value)
                return i
        }
        return 0
    }
}
