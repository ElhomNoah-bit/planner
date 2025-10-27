pragma Singleton
import QtQuick

QtObject {
    // Surface hierarchy
    property QtObject surface: QtObject {
        property color level0: "#0B0C0F"
        property color level1: "#121318"
        property color level1Glass: "#121318CC"
    }

    // Text system
    property QtObject text: QtObject {
        property color primary: "#F5F7FA"
        property color secondary: "#A3ACB8"
        property color muted: "#7A8390"
        property real subtle: 0.55
    }

    // Accent palette
    property QtObject accent: QtObject {
        property color base: "#0A84FF"
        property color dim: "#1B4F91"
        property color bg: "#0A84FF1A"
    }

    // UI states
    property QtObject state: QtObject {
        property color today: "#0A84FF33"
        property color select: "#0A84FF4D"
        property color hover: "#FFFFFF14"
        property color press: "#FFFFFF26"
    }

    // Layout metrics
    property QtObject layout: QtObject {
        property int headerH: 56
        property int pillH: 30
        property int sidebarW: 340
        property int gridGap: 12
        property int margin: 24
    }

    // Typography scale
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
        property int gap20: 20
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

    // Compatibility accessors for existing references
    property QtObject colors: QtObject {
        property color bg: surface.level0
        property color card: surface.level1
        property color cardGlass: surface.level1Glass
        property color text: text.primary
        property color textMuted: text.secondary
        property color tint: accent.base
        property color pillBg: Qt.rgba(0.12, 0.13, 0.18, 0.9)
        property color pillBorder: Qt.rgba(0.28, 0.3, 0.36, 1)
        property color divider: Qt.rgba(0.32, 0.34, 0.4, text.subtle)
        property color chipBg: Qt.rgba(0.16, 0.18, 0.24, 0.86)
        property color chipFg: text.primary
        property color success: "#34C759"
        property color warning: "#FFD60A"
        property color danger: "#FF453A"
    }
}
