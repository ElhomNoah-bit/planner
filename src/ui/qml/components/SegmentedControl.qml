import QtQuick
import NoahPlanner 1.0 as NP

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

    Rectangle {
        anchors.fill: parent
        radius: NP.ThemeStore.radii.xl
        color: Qt.rgba(1, 1, 1, NP.ThemeStore.dark ? 0.08 : 0.12)
        border.color: NP.ThemeStore.border
        border.width: 1
    }

    Rectangle {
        id: indicator
        anchors.verticalCenter: parent.verticalCenter
        width: root.options.length > 0 ? (parent.width - 8) / root.options.length : 0
        height: parent.height - 8
        radius: NP.ThemeStore.radii.xl
        color: Qt.rgba(0.04, 0.35, 0.84, 0.22)
        border.color: NP.ThemeStore.accent
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
                    font.pixelSize: 14
                    font.weight: root.value === option.value ? Font.DemiBold : Font.Medium
                    font.family: NP.ThemeStore.defaultFontFamily
                    color: root.value === option.value ? NP.ThemeStore.accent : NP.ThemeStore.text
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
