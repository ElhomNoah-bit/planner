pragma Singleton
import QtQuick

QtObject {
    id: theme

    // Farben
    readonly property color appBg:    "#0E1116"
    readonly property color cardBg:   "#171B22"
    readonly property color cardAlt:  "#1C222B"
    readonly property color text:     "#E6EAF2"
    readonly property color text2:    "#AFB8C5"
    readonly property color divider:  "#2A3340"
    readonly property color hover:    "#223043"
    readonly property color focus:    "#5BA5FF"
    readonly property color accent:   "#3B82F6"
    readonly property color accentBg: "#1A2B4D"
    readonly property color danger:   "#F97066"

    // Typo
    readonly property int baseSize: 14
    readonly property int sm: baseSize - 2
    readonly property int md: baseSize
    readonly property int lg: baseSize + 2
    readonly property int xl: baseSize + 6
    readonly property int xs: baseSize - 3
    readonly property real line: 1.35

    // Spacing & Radii
    readonly property int g4: 4
    readonly property int g8: 8
    readonly property int g12: 12
    readonly property int g16: 16
    readonly property int g24: 24

    readonly property int r8: 8
    readonly property int r12: 12
    readonly property int r16: 16

    // Fonts
    readonly property string fontFamily: "Inter"
    readonly property string fontFallback: "Sans Serif"

    // Legacy groupings kept for gradual migration
    readonly property QtObject colors: QtObject {
        readonly property alias appBg: theme.appBg
        readonly property alias cardBg: theme.cardBg
        readonly property alias cardGlass: theme.cardAlt
        readonly property alias text: theme.text
        readonly property alias text2: theme.text2
        readonly property alias divider: theme.divider
        readonly property alias hover: theme.hover
        readonly property alias focus: theme.focus
        readonly property alias accent: theme.accent
        readonly property alias accentBg: theme.accentBg
        readonly property alias neutralBg: theme.cardAlt
        readonly property alias press: theme.hover
    }

    readonly property QtObject type: QtObject {
        readonly property alias md: theme.md
        readonly property alias sm: theme.sm
        readonly property alias lg: theme.lg
        readonly property alias xs: theme.xs
        readonly property alias h1: theme.xl
        readonly property alias monthTitle: theme.xl
        readonly property alias dateSize: theme.sm
        readonly property alias eventChipSize: theme.sm
        readonly property int weightRegular: 400
        readonly property int weightMedium: 600
        readonly property int weightBold: 700
    }

    readonly property QtObject radii: QtObject {
        readonly property alias sm: theme.r8
        readonly property alias md: theme.r12
        readonly property alias lg: theme.r16
        readonly property int xl: theme.r16 + 4
        readonly property int xxl: theme.r16 + 8
    }

    readonly property QtObject gap: QtObject {
        readonly property alias g4: theme.g4
        readonly property alias g8: theme.g8
        readonly property alias g12: theme.g12
        readonly property alias g16: theme.g16
        readonly property alias g24: theme.g24
    }

    readonly property QtObject layout: QtObject {
        readonly property int headerH: 64
        readonly property int pillH: 36
        readonly property int sidebarW: 360
        readonly property int gridGap: theme.g16
        readonly property int margin: theme.g24
    }

    readonly property QtObject fonts: QtObject {
        readonly property alias uiFallback: theme.fontFallback
        readonly property url interUrl: "qrc:/fonts/Inter-Regular.ttf"
    }
}
