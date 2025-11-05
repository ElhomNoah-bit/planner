pragma Singleton
import QtQuick

QtObject {
    id: theme

    // --- Color tokens ---------------------------------------------------
    readonly property color surface: "#0E1116"
    readonly property color surfaceAlt: "#171B22"
    readonly property color surfaceRaised: "#1C222B"
    readonly property color surfaceMuted: "#131821"
    readonly property color text: "#F6FAFF"
    readonly property color textSecondary: "#AFB8C5"
    readonly property color textMuted: "#8A93A3"
    readonly property color accent: "#3B82F6"
    readonly property color accentWeak: "#1A2B4D"
    readonly property color accentStrong: "#5BA5FF"
    readonly property color ok: "#22C55E"
    readonly property color danger: "#F97066"
    readonly property color warning: "#F59E0B"
    readonly property color info: "#38BDF8"
    readonly property color overlayBg: "#000000A8"
    readonly property color overlayStroke: "#1C222B"
    readonly property color divider: "#2A3340"
    readonly property color hover: "#223043"
    readonly property color focus: "#5BA5FF"
    readonly property color neutral: "#1C222B"
    readonly property color surfaceOnWeak: "#FFFFFF"
    readonly property color overdue: "#DC2626"

    // --- Typography tokens ---------------------------------------------
    readonly property string fontFamily: "Inter"
    readonly property string fontHeading: "Inter"
    readonly property string fontFallback: "Sans Serif"
    readonly property int fontSizeXs: 11
    readonly property int fontSizeSm: 13
    readonly property int fontSizeMd: 14
    readonly property int fontSizeLg: 18
    readonly property int fontSizeXl: 24
    readonly property real lineHeight: 1.35
    readonly property int fontWeightRegular: 400
    readonly property int fontWeightMedium: 600
    readonly property int fontWeightBold: 700

    // --- Spacing & radii ------------------------------------------------
    readonly property int gapXs: 4
    readonly property int gapSm: 8
    readonly property int gapMd: 12
    readonly property int gapLg: 16
    readonly property int gapXl: 24

    readonly property int radiusSm: 8
    readonly property int radiusMd: 12
    readonly property int radiusLg: 16
    readonly property int radiusXl: 24

    // --- Misc tokens ----------------------------------------------------
    readonly property real opacityFull: 1.0
    readonly property real opacityMuted: 0.25
    readonly property real opacityDisabled: 0.4

    // Legacy groups kept for gradual migration --------------------------
    readonly property QtObject colors: QtObject {
        readonly property alias appBg: theme.surface
        readonly property alias cardBg: theme.surfaceAlt
        readonly property alias cardGlass: theme.surfaceRaised
        readonly property alias text: theme.text
        readonly property alias text2: theme.textSecondary
        readonly property alias textPrimary: theme.text
        readonly property alias divider: theme.divider
        readonly property alias hover: theme.hover
        readonly property alias focus: theme.focus
        readonly property alias accent: theme.accent
        readonly property alias accentBg: theme.accentWeak
        readonly property alias surfaceOnWeak: theme.surfaceOnWeak
        readonly property alias neutralBg: theme.surfaceRaised
        readonly property alias press: theme.hover
        readonly property alias prioHigh: theme.danger
        readonly property alias prioMedium: theme.warning
        readonly property color prioLow: "#66BB6A"
        readonly property alias warn: theme.warning
        readonly property alias overdue: theme.overdue
        readonly property alias danger: theme.danger
        readonly property alias ok: theme.ok
    }

    readonly property QtObject type: QtObject {
        readonly property alias xs: theme.fontSizeXs
        readonly property alias sm: theme.fontSizeSm
        readonly property alias md: theme.fontSizeMd
        readonly property alias lg: theme.fontSizeLg
        readonly property alias xl: theme.fontSizeXl
        readonly property alias h1: theme.fontSizeXl
        readonly property alias monthTitle: theme.fontSizeXl
        readonly property alias dateSize: theme.fontSizeSm
        readonly property alias eventChipSize: theme.fontSizeSm
        readonly property alias weightRegular: theme.fontWeightRegular
        readonly property alias weightMedium: theme.fontWeightMedium
        readonly property alias weightBold: theme.fontWeightBold
        readonly property alias line: theme.lineHeight
    }

    readonly property QtObject radii: QtObject {
        readonly property alias sm: theme.radiusSm
        readonly property alias md: theme.radiusMd
        readonly property alias lg: theme.radiusLg
        readonly property alias xl: theme.radiusXl
        readonly property int xxl: theme.radiusXl + 8
    }

    readonly property QtObject gap: QtObject {
        readonly property alias g4: theme.gapXs
        readonly property alias g8: theme.gapSm
        readonly property alias g12: theme.gapMd
        readonly property alias g16: theme.gapLg
        readonly property alias g24: theme.gapXl
    }

    readonly property QtObject layout: QtObject {
        readonly property int headerH: 64
        readonly property int pillH: 36
        readonly property int sidebarW: 360
        readonly property int gridGap: theme.gapLg
        readonly property int margin: theme.gapXl
    }

    readonly property QtObject fonts: QtObject {
        readonly property alias body: theme.fontFamily
        readonly property alias heading: theme.fontHeading
        readonly property alias uiFallback: theme.fontFamily
        readonly property alias fallback: theme.fontFallback
        readonly property url interUrl: "qrc:/fonts/Inter-Regular.ttf"
    }
}
