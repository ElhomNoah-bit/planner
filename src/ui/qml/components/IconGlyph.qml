import QtQuick
import NoahPlanner 1.0 as NP

Item {
    id: root
    property alias text: glyph.text
    property int size: 16
    // Fallback loaders
    FontLoader { id: sf;    name: "SF Pro" }
    FontLoader { id: inter; name: "Inter" }
    FontLoader { id: noto;  name: "Noto Sans" }

    function pickFamily() {
        if (sf.status === FontLoader.Ready)    return sf.name
        if (inter.status === FontLoader.Ready) return inter.name
        if (noto.status === FontLoader.Ready)  return noto.name
        return "Sans"
    }

    Text {
        id: glyph
        anchors.centerIn: parent
        font.pixelSize: root.size
        font.family: pickFamily()
        font.weight: Font.DemiBold
        color: NP.ThemeStore.text
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
}
