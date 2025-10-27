import QtQuick
import NoahPlanner 1.0
import "../styles" as Styles

Item {
    id: root
    property string text: ""
    property string name: ""
    property int size: 16
    property color color: glyphColor

    implicitHeight: glyph.implicitHeight
    implicitWidth: glyph.implicitWidth

    // Embedded fonts served via Qt resource system.
    FontLoader {
        id: inter
        source: "qrc:/fonts/assets/fonts/Inter-Regular.ttf"
        onStatusChanged: if (status === FontLoader.Error) console.warn("Inter font failed to load:", errorString)
    }

    readonly property color glyphColor: Styles.ThemeStore && Styles.ThemeStore.colors ? Styles.ThemeStore.colors.text : "#F5F7FA"

    readonly property var glyphMap: ({
        "chevron.backward": "\u2039",
        "chevron.forward": "\u203A",
        "chevron.left": "\u2039",
        "chevron.right": "\u203A",
        "plus": "+",
        "magnifyingglass": "\u2315",
        "sun.max": "\u2600",
        "moon": "\u263D",
        "calendar": "\u25A1",
        "list.bullet": "\u2022",
        "ellipsis": "\u2026"
    })

    readonly property var materialMap: ({
        "chevron.backward": "chevron.left",
        "chevron.forward": "chevron.right",
        "magnifyingglass": "search",
        "sun.max": "sun",
        "moon": "moon"
    })

    function pickFamily() {
        if (inter.status === FontLoader.Ready && inter.name.length) {
            return inter.name
        }
        if (Qt.application.font && Qt.application.font.family.length) {
            return Qt.application.font.family
        }
        return "Sans"
    }

    function resolveSymbol(iconName) {
        if (!iconName || !iconName.length) {
            return ""
        }
        if (glyphMap[iconName]) {
            return glyphMap[iconName]
        }
        const fallback = materialMap[iconName]
        if (fallback && glyphMap[fallback]) {
            return glyphMap[fallback]
        }
        return iconName.charAt(0)
    }

    Text {
        id: glyph
        anchors.centerIn: parent
        font.pixelSize: root.size
        font.family: pickFamily()
        font.weight: Font.DemiBold
        color: root.color
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: root.name.length ? resolveSymbol(root.name) : root.text
    }
}
