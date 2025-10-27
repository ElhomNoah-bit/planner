import QtQuick
import NoahPlanner 1.0 as NP

Text {
    id: icon
    property string symbol: ""
    property color tint: NP.ThemeStore.text
    property real size: 16
    property bool muted: false

    color: muted ? NP.ThemeStore.muted : tint
    font.pixelSize: size
    font.weight: Font.DemiBold
    font.preferredFamilies: NP.ThemeStore.fonts.stack
    text: resolvedSymbol(symbol)
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

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

    function resolvedSymbol(name) {
        if (glyphMap[name]) {
            return glyphMap[name];
        }
        const fallback = materialMap[name];
        if (fallback && glyphMap[fallback]) {
            return glyphMap[fallback];
        }
        return name && name.length > 0 ? name.charAt(0) : "";
    }

    readonly property var materialMap: ({
        "chevron.backward": "chevron.left",
        "chevron.forward": "chevron.right",
        "magnifyingglass": "search",
        "sun.max": "sun",
        "moon": "moon"
    })
}
