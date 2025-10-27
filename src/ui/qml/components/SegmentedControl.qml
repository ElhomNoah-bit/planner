import QtQuick
import "../styles" as Styles

Item {
    id: root
    property var options: [
        { "label": qsTr("Monat"), "value": "month" },
        { "label": qsTr("Woche"), "value": "week" },
        { "label": qsTr("Liste"), "value": "list" }
    ]
    property string value: options.length > 0 ? options[0].value : ""

    implicitHeight: 40
    implicitWidth: 240

    readonly property var theme: Styles.ThemeStore
    readonly property var colors: theme ? theme.colors : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var typeScale: theme ? theme.type : null

    Rectangle {
        anchors.fill: parent
        radius: radii ? radii.xl : 22
        color: Qt.rgba(1, 1, 1, theme ? theme.glassBack : 0.12)
        border.color: colors ? colors.divider : Qt.rgba(1, 1, 1, 0.16)
        border.width: 1
    }

    Rectangle {
        id: indicator
        anchors.verticalCenter: parent.verticalCenter
        width: root.options.length > 0 ? (parent.width - 8) / root.options.length : 0
        height: parent.height - 8
        radius: radii ? radii.xl : 22
    color: colors ? Qt.rgba(colors.tint.r, colors.tint.g, colors.tint.b, 0.22) : Qt.rgba(0.04, 0.35, 0.84, 0.22)
        border.color: colors ? colors.tint : "#0A84FF"
        visible: root.options.length > 0
        x: 4 + currentIndex() * width
        Behavior on x {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
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
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (root.value === option.value)
                            return
                        root.value = option.value
                    }
                }
                Text {
                    anchors.centerIn: parent
                    text: option.label
                    font.pixelSize: typeScale ? typeScale.sm : 14
                    font.weight: root.value === option.value
                        ? (typeScale ? typeScale.weightBold : Font.DemiBold)
                        : (typeScale ? typeScale.weightMedium : Font.Medium)
                    font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                    color: root.value === option.value
                        ? (colors ? colors.tint : "#0A84FF")
                        : (colors ? colors.text : "#FFFFFF")
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
