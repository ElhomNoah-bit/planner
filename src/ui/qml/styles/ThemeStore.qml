pragma Singleton
import QtQuick

QtObject {
    property bool dark: true

    readonly property var darkPalette: ({
        "bg": "#000000",
        "panel": Qt.rgba(1, 1, 1, 0.06),
        "border": Qt.rgba(1, 1, 1, 0.14),
        "text": "#F5F7FA",
        "muted": "#AEB6C2",
        "accent": "#0A84FF",
        "chipBg": "#2C2C2E",
        "danger": "#FF453A",
        "warning": "#FFD60A",
        "success": "#32D74B"
    })

    readonly property var lightPalette: ({
        "bg": "#FFFFFF",
        "panel": Qt.rgba(0, 0, 0, 0.06),
        "border": Qt.rgba(0, 0, 0, 0.08),
        "text": "#0A0A0A",
        "muted": "#667085",
        "accent": "#0A84FF",
        "chipBg": Qt.rgba(0, 0, 0, 0.06),
        "danger": "#FF453A",
        "warning": "#FFD60A",
        "success": "#32D74B"
    })

    readonly property var radii: ({
        "sm": 10,
        "md": 14,
        "lg": 18,
        "xl": 28
    })

    readonly property var spacing: ({
        "gap8": 8,
        "gap12": 12,
        "gap16": 16,
        "gap24": 24
    })

    readonly property var blur: ({
        "strong": 24,
        "medium": 16
    })

    readonly property var fonts: ({
        "stack": [
            "SF Pro Display",
            "SF Pro Text",
            "Inter",
            "Helvetica Neue",
            "Segoe UI",
            "Source Sans Pro",
            "Sans Serif"
        ]
    })

    readonly property string defaultFontFamily: (Qt.application.font && Qt.application.font.family && Qt.application.font.family.length)
        ? Qt.application.font.family
        : (fonts.stack.length > 0 ? fonts.stack[0] : "Sans")

    readonly property var typography: ({
        "monthTitleSize": 42,
        "monthTitleWeight": Font.ExtraBold,
        "dateSize": 14,
        "dateWeight": Font.DemiBold,
        "eventChipSize": 12,
        "eventChipWeight": Font.DemiBold,
        "metaSize": 12,
        "metaWeight": Font.Normal
    })

    readonly property var palette: dark ? darkPalette : lightPalette
    readonly property color bg: palette.bg
    readonly property color panel: palette.panel
    readonly property color border: palette.border
    readonly property color text: palette.text
    readonly property color muted: palette.muted
    readonly property color accent: palette.accent
    readonly property color chipBg: palette.chipBg
    readonly property color danger: palette.danger
    readonly property color warning: palette.warning
    readonly property color success: palette.success
}
