import QtQuick
import NoahPlanner.Styles as Styles

Item {
    id: root
    property alias text: glyph.text
    property string name: ""
    property real size: 14
    property color color: Styles.ThemeStore.text
    property string family: Styles.ThemeStore.fontFamily.length
                                  ? Styles.ThemeStore.fontFamily
                                  : Styles.ThemeStore.fontFallback

    implicitHeight: glyph.implicitHeight
    implicitWidth: glyph.implicitWidth

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

    function updateGlyph() {
        if (root.name.length) {
            glyph.text = resolveSymbol(root.name)
        }
    }

    Component.onCompleted: updateGlyph()
    onNameChanged: updateGlyph()

    Text {
        id: glyph
        anchors.centerIn: parent
        font.pixelSize: root.size
        font.family: root.family
        font.weight: Font.DemiBold
        color: root.color
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        renderType: Text.NativeRendering
    }
}
