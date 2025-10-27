pragma Singleton
import QtQuick
import QtQml

QtObject {
    // Farben
    readonly property QtObject colors: QtObject {
        readonly property color appBg:    "#0F1115"
        readonly property color cardBg:   "#161A23"
        readonly property color cardGlass:"#161A23CC"  // 80% alpha
        readonly property color text:     "#F2F5F9"
        readonly property color text2:    "#B7C0CC"
        readonly property color textMuted:"#8B93A2"
        readonly property color divider:  "#2A2F3A"
        readonly property color accent:   "#0A84FF"
        readonly property color accentBg: "#0A84FF1F"  // 12% fill
        readonly property color focus:    "#0A84FF"
        readonly property color hover:    "#FFFFFF1A"
        readonly property color press:    "#FFFFFF33"
        readonly property color warning:  "#FF9F0A"
        readonly property color success:  "#32D74B"
        readonly property color danger:   "#FF453A"
    }

    // Typografie
    readonly property QtObject type: QtObject {
        readonly property int monthTitle: 28
        readonly property int h1: 22
        readonly property int lg: 16
        readonly property int md: 14
        readonly property int sm: 12
        readonly property int xs: 11
        readonly property int dateSize: 12
        readonly property int eventChipSize: 11
        readonly property int metaSize: 11
        readonly property int weightRegular: 400
        readonly property int weightMedium:  600
        readonly property int weightBold:    700
    }

    // Radien & Layout
    readonly property QtObject radii: QtObject {
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 20
    }
    readonly property QtObject gap: QtObject {
        readonly property int g4: 4
        readonly property int g8: 8
        readonly property int g12: 12
        readonly property int g16: 16
        readonly property int g24: 24
    }
    readonly property QtObject layout: QtObject {
        readonly property int headerH: 56
        readonly property int pillH: 30
        readonly property int sidebarW: 340
        readonly property int gridGap: 12
        readonly property int margin: 24
    }

    // Fonts – zentraler Zugriff
    readonly property QtObject fonts: QtObject {
        // Name wird aus FontLoader.name geholt (siehe IconGlyph)
        readonly property string uiFallback: "Sans Serif"
        readonly property url interUrl: "qrc:/qt/qml/NoahPlanner/assets/fonts/Inter-Regular.ttf"
    }
}
