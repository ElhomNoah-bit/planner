import QtQuick
import QtQuick.Effects
import NoahPlanner 1.0

Item {
    id: root
    property real radius: baseRadius
    property real padding: basePadding
    property bool blurEnabled: true
    property color tint: baseTint
    property color stroke: baseStroke
    default property alias contentData: content.data

    readonly property real baseRadius: theme(["radii", "lg"], 18)
    readonly property real basePadding: theme(["spacing", "gap16"], 16)
    readonly property color baseTint: theme(["panel"], Qt.rgba(0, 0, 0, 0.06))
    readonly property color baseStroke: theme(["border"], Qt.rgba(0, 0, 0, 0.08))
    readonly property real baseBlur: theme(["blur", "medium"], 16)

    Rectangle {
        id: backdrop
        anchors.fill: parent
        radius: root.radius
        color: root.tint
        border.color: root.stroke
        border.width: 1
        layer.enabled: root.blurEnabled
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: Math.min(root.baseBlur, 64)
            blur: 1.0
        }
    }

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: root.padding
    }

    function theme(path, fallback) {
        if (typeof ThemeStore === "undefined" || !ThemeStore) {
            return fallback
        }
        var value = ThemeStore
        for (var i = 0; i < path.length; ++i) {
            if (value === undefined || value === null) {
                return fallback
            }
            value = value[path[i]]
        }
        return value === undefined ? fallback : value
    }
}
