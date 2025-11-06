pragma Singleton
import QtQuick

QtObject {
    id: theme

    property bool darkMode: true

    function setDarkMode(preferDark) {
        if (preferDark === undefined) {
            if (Qt.styleHints && Qt.styleHints.colorScheme !== undefined && typeof Qt.ColorScheme !== "undefined") {
                darkMode = Qt.styleHints.colorScheme === Qt.ColorScheme.Dark
            }
            return
        }
        darkMode = !!preferDark
    }

    // Base palette
    readonly property color surface: darkMode ? "#0E1116" : "#F7F9FC"
    readonly property color surfaceAlt: darkMode ? "#171B22" : "#FFFFFF"
    readonly property color surfaceRaised: darkMode ? "#1C222B" : "#E2E8F0"
    readonly property color surfaceGlass: darkMode ? "#22304380" : "#BFD2EA7F"
    readonly property color overlayBg: darkMode ? "#00000080" : "#0A1E3380"
    readonly property color text: darkMode ? "#E6EAF2" : "#1B2433"
    readonly property color textSecondary: darkMode ? "#AFB8C5" : "#3E4C63"
    readonly property color textMuted: darkMode ? "#7A8696" : "#5B6B82"
    readonly property color surfaceOnWeak: darkMode ? "#FFFFFF" : "#0E1116"
    readonly property color divider: darkMode ? "#2A3340" : "#CBD5E1"
    readonly property color focus: darkMode ? "#5BA5FF" : "#2563EB"
    readonly property color accent: darkMode ? "#3B82F6" : "#2563EB"
    readonly property color accentWeak: darkMode ? "#1A2B4D" : "#D6E4FF"
    readonly property color ok: darkMode ? "#22C55E" : "#15803D"
    readonly property color warning: darkMode ? "#F59E0B" : "#B45309"
    readonly property color danger: darkMode ? "#F97066" : "#DC2626"

    // Legacy compatibility shorthands
    readonly property QtObject colors: QtObject {
        readonly property color appBg: theme.surface
        readonly property color cardBg: theme.surfaceAlt
        readonly property color cardAlt: theme.surfaceRaised
        readonly property color cardGlass: theme.surfaceGlass
        readonly property color text: theme.text
        readonly property color text2: theme.textSecondary
        readonly property color textPrimary: theme.surfaceOnWeak
        readonly property color divider: theme.divider
        readonly property color hover: theme.darkMode ? theme.surfaceRaised : theme.surfaceAlt
        readonly property color focus: theme.focus
        readonly property color accent: theme.accent
        readonly property color accentBg: theme.accentWeak
        readonly property color surfaceOnWeak: theme.surfaceOnWeak
        readonly property color neutralBg: theme.surfaceRaised
        readonly property color press: theme.darkMode ? theme.surfaceRaised : theme.surfaceAlt
        readonly property color prioHigh: theme.danger
        readonly property color prioMedium: theme.warning
        readonly property color prioLow: theme.ok
        readonly property color warn: theme.warning
        readonly property color overdue: theme.danger
        readonly property color border: theme.divider
        readonly property color primary: theme.accent
        readonly property color danger: theme.danger
    }

    // Typography scale
    readonly property QtObject type: QtObject {
        readonly property int xs: 12
        readonly property int sm: 13
        readonly property int md: 14
        readonly property int lg: 16
        readonly property int xl: 20
        readonly property int xxl: 24
        readonly property int weightRegular: 400
        readonly property int weightMedium: 600
        readonly property int weightBold: 700
    }

    // Spacing tokens
    readonly property int gapXs: 4
    readonly property int gapSm: 8
    readonly property int gapMd: 12
    readonly property int gapLg: 16
    readonly property int gapXl: 24

    readonly property QtObject gap: QtObject {
        readonly property int g4: theme.gapXs
        readonly property int g8: theme.gapSm
        readonly property int g12: theme.gapMd
        readonly property int g16: theme.gapLg
        readonly property int g24: theme.gapXl
    }

    // Radius tokens
    readonly property int radiusSm: 6
    readonly property int radiusMd: 10
    readonly property int radiusLg: 16
    readonly property int radiusXl: 24

    readonly property QtObject radii: QtObject {
        readonly property int sm: theme.radiusSm
        readonly property int md: theme.radiusMd
        readonly property int lg: theme.radiusLg
        readonly property int xl: theme.radiusXl
        readonly property int xxl: theme.radiusXl + 6
    }

    // Layout metrics
    readonly property QtObject layout: QtObject {
        readonly property int headerH: 64
        readonly property int pillH: 36
        readonly property int sidebarW: 360
        readonly property int gridGap: theme.gapLg
        readonly property int margin: theme.gapXl
    }

    // Font families
    readonly property QtObject fonts: QtObject {
        readonly property string body: "Inter"
        readonly property string heading: "Inter"
        readonly property string uiFallback: "Inter"
        readonly property string fallback: "Sans Serif"
        readonly property url interUrl: "qrc:/fonts/Inter-Regular.ttf"
    }

    // Opacity
    readonly property real opacityFull: 1.0
    readonly property real opacityMuted: 0.3
    readonly property real opacityDisabled: 0.4

    readonly property QtObject opacity: QtObject {
        readonly property real full: theme.opacityFull
        readonly property real muted: theme.opacityMuted
        readonly property real disabled: theme.opacityDisabled
    }

    // Legacy scalar aliases for backwards compatibility with older QML bindings
    readonly property int g4: gapXs
    readonly property int g8: gapSm
    readonly property int g12: gapMd
    readonly property int g16: gapLg
    readonly property int g24: gapXl

    readonly property int r4: 4
    readonly property int r8: 8
    readonly property int r12: 12
    readonly property int r16: 16

}
