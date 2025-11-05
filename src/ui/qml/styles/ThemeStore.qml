pragma Singleton
import QtQuick

QtObject {
    id: theme

    // --- Color tokens ---------------------------------------------------
    readonly property color surface: "#0E1116"
    readonly property color surfaceAlt: "#171B22"
    readonly property color surfaceRaised: "#1C222B"
    pragma Singleton
    import QtQuick

    QtObject {
        // Base colors
        readonly property color surface: "#0E1116"
        readonly property color surfaceAlt: "#171B22"
        readonly property color surfaceRaised: "#1C222B"
        readonly property color surfaceGlass: "#22304380"
        readonly property color overlayBg: "#00000080"
        readonly property color text: "#E6EAF2"
        readonly property color textSecondary: "#AFB8C5"
        readonly property color textMuted: "#7A8696"
        readonly property color surfaceOnWeak: "#FFFFFF"
        readonly property color divider: "#2A3340"
        readonly property color focus: "#5BA5FF"
        readonly property color accent: "#3B82F6"
        readonly property color accentWeak: "#1A2B4D"
        readonly property color ok: "#22C55E"
        readonly property color warning: "#F59E0B"
        readonly property color danger: "#F97066"

        // Legacy aliases
        readonly property QtObject colors: QtObject {
            readonly property color appBg: ThemeStore.surface
            readonly property color cardBg: ThemeStore.surfaceAlt
            readonly property color cardGlass: ThemeStore.surfaceGlass
            readonly property color text: ThemeStore.text
            readonly property color text2: ThemeStore.textSecondary
            readonly property color textPrimary: ThemeStore.surfaceOnWeak
            readonly property color divider: ThemeStore.divider
            readonly property color hover: ThemeStore.surfaceRaised
            readonly property color focus: ThemeStore.focus
            readonly property color accent: ThemeStore.accent
            readonly property color accentBg: ThemeStore.accentWeak
            readonly property color surfaceOnWeak: ThemeStore.surfaceOnWeak
            readonly property color neutralBg: ThemeStore.surfaceRaised
            readonly property color press: ThemeStore.surfaceRaised
            readonly property color prioHigh: ThemeStore.danger
            readonly property color prioMedium: ThemeStore.warning
            readonly property color prioLow: ThemeStore.ok
            readonly property color warn: ThemeStore.warning
            readonly property color overdue: ThemeStore.danger
        }

        // Typography
        readonly property QtObject type: QtObject {
            readonly property int xs: 12
            readonly property int sm: 13
            readonly property int md: 14
            readonly property int lg: 16
            readonly property int xl: 20
            readonly property int weightRegular: 400
            readonly property int weightMedium: 600
            readonly property int weightBold: 700
        }

        // Spacing utilities
        readonly property int gapXs: 4
        readonly property int gapSm: 8
        readonly property int gapMd: 12
        readonly property int gapLg: 16
        readonly property int gapXl: 24

        readonly property QtObject gap: QtObject {
            readonly property int g4: ThemeStore.gapXs
            readonly property int g8: ThemeStore.gapSm
            readonly property int g12: ThemeStore.gapMd
            readonly property int g16: ThemeStore.gapLg
            readonly property int g24: ThemeStore.gapXl
        }

        // Radii tokens
        readonly property int radiusSm: 6
        readonly property int radiusMd: 10
        readonly property int radiusLg: 16
        readonly property int radiusXl: 24

        readonly property QtObject radii: QtObject {
            readonly property int sm: ThemeStore.radiusSm
            readonly property int md: ThemeStore.radiusMd
            readonly property int lg: ThemeStore.radiusLg
            readonly property int xl: ThemeStore.radiusXl
            readonly property int xxl: ThemeStore.radiusXl + 6
        }

        // Layout metrics
        readonly property QtObject layout: QtObject {
            readonly property int headerH: 64
            readonly property int pillH: 36
            readonly property int sidebarW: 360
            readonly property int gridGap: ThemeStore.gapLg
            readonly property int margin: ThemeStore.gapXl
        }

        // Fonts
        readonly property QtObject fonts: QtObject {
            readonly property string body: "Inter"
            readonly property string heading: "Inter"
            readonly property string uiFallback: "Inter"
            readonly property string fallback: "Sans Serif"
            readonly property url interUrl: "qrc:/fonts/Inter-Regular.ttf"
        }

        // Opacity tokens
        readonly property real opacityFull: 1.0
        readonly property real opacityMuted: 0.3
        readonly property real opacityDisabled: 0.4
    }
        readonly property int headerH: 64
