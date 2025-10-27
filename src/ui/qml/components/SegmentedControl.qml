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
    readonly property var accent: theme ? theme.accent : null
    readonly property var state: theme ? theme.state : null
    readonly property var radii: theme ? theme.radii : null
    readonly property var typeScale: theme ? theme.type : null

    Rectangle {
        anchors.fill: parent
        radius: radii ? radii.xl : 22
        color: colors ? colors.pillBg : Qt.rgba(0.12, 0.13, 0.18, 0.9)
        border.color: colors ? colors.pillBorder : Qt.rgba(0.28, 0.3, 0.36, 1)
        border.width: 1
    }

    Rectangle {
        id: indicator
        anchors.verticalCenter: parent.verticalCenter
        width: root.options.length > 0 ? (parent.width - 8) / root.options.length : 0
        height: parent.height - 8
        radius: radii ? radii.xl : 22
        color: accent ? accent.base : "#0A84FF"
        visible: root.options.length > 0
        x: 4 + currentIndex() * width
        Behavior on x {
            NumberAnimation { duration: 140; easing.type: Easing.InOutQuad }
        }
        Behavior on width {
            NumberAnimation { duration: 140; easing.type: Easing.InOutQuad }
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
                property bool hovered: false

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.hovered = true
                    onExited: parent.hovered = false
                    onClicked: {
                        if (root.value !== option.value) {
                            root.value = option.value
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: radii ? radii.xl : 22
                    color: parent.hovered && root.value !== option.value
                        ? (state ? state.hover : Qt.rgba(1, 1, 1, 0.12))
                        : "transparent"
                }

                Text {
                    anchors.centerIn: parent
                    text: option.label
                    font.pixelSize: typeScale ? typeScale.sm : 14
                    font.weight: root.value === option.value
                        ? (typeScale ? typeScale.weightBold : Font.DemiBold)
                        : (typeScale ? typeScale.weightMedium : Font.Medium)
                    font.family: Qt.application.font && Qt.application.font.family.length ? Qt.application.font.family : "Inter"
                    color: root.value === option.value ? "#0B0C0F" : (colors ? colors.textMuted : "#9AA3AF")
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
