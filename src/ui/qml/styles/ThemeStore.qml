pragma Singleton
import QtQuick

QtObject {
    readonly property QtObject colors: QtObject {
        readonly property color appBg:    "#0F1115"
        readonly property color cardBg:   "#161A23"
        readonly property color cardGlass:"#161A23CC"
        readonly property color text:     "#F2F5F9"
        readonly property color text2:    "#B7C0CC"
        readonly property color divider:  "#2A2F3A"
        readonly property color accent:   "#0A84FF"
        readonly property color accentBg: "#0A84FF1F"
        readonly property color hover:    "#FFFFFF1A"
        readonly property color press:    "#FFFFFF33"
        readonly property color focus:    accent
    }

    readonly property QtObject type: QtObject {
        readonly property int monthTitle: 28
        readonly property int h1: 22
        readonly property int lg: 16
        readonly property int md: 14
        readonly property int sm: 12
        readonly property int xs: 11
        readonly property int dateSize: 12
        readonly property int eventChipSize: 11
        readonly property int weightRegular: 400
        readonly property int weightMedium: 600
        readonly property int weightBold: 700
    }

    readonly property QtObject radii: QtObject {
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 20
        readonly property int xxl: 24
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
        readonly property int pillH: 32
        readonly property int sidebarW: 340
        readonly property int gridGap: 14
        readonly property int margin: 24
    }

    readonly property QtObject fonts: QtObject {
        readonly property string uiFallback: "Sans Serif"
        readonly property url interUrl: "qrc:/fonts/Inter-Regular.ttf"
    }
}
