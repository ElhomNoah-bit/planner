pragma Singleton
import QtQuick

QtObject {
    // Colors tuned for a dark, glassy UI baseline
    property QtObject colors: QtObject {
        property color bg: "#0B0B0D"
        property color card: "#121216"
        property color cardGlass: "#121216CC"
        property color text: "#FFFFFF"
        property color textMuted: "#9AA3AF"
        property color tint: "#0A84FF"
        property color pillBg: "#1F1F24"
        property color pillBorder: "#2A2A30"
        property color divider: "#26262B"
        property color chipBg: "#1A1A1F"
        property color chipFg: "#E5E7EB"
        property color success: "#34C759"
        property color warning: "#FFD60A"
        property color danger: "#FF453A"
    }

    property QtObject type: QtObject {
        property int xs: 11
        property int sm: 13
        property int md: 15
        property int lg: 17
        property int xl: 22
        property int display: 28

        property int weightRegular: Font.Normal
        property int weightMedium: Font.DemiBold
        property int weightBold: Font.Bold

        property int monthTitleSize: 28
        property int monthTitleWeight: Font.DemiBold
        property int dateSize: 13
        property int dateWeight: Font.Medium
        property int eventChipSize: 12
        property int eventChipWeight: Font.Medium
        property int metaSize: 12
        property int metaWeight: Font.Normal
    }

    property QtObject space: QtObject {
        property int gap4: 4
        property int gap8: 8
        property int gap12: 12
        property int gap16: 16
        property int gap24: 24
        property int gap32: 32
    }

    property QtObject radii: QtObject {
        property int sm: 8
        property int md: 12
        property int lg: 16
        property int xl: 22
    }

    property real glassBack: 0.12
    property real glassBorder: 0.25
}
