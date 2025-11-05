import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Styles 1.0 as Styles

TextField {
    id: search
    property alias placeholder: search.placeholderText

    implicitHeight: Styles.ThemeStore.layout.pillH
    leftPadding: Styles.ThemeStore.gap.g12 + icon.width + Styles.ThemeStore.gap.g8
    rightPadding: Styles.ThemeStore.gap.g12
    font.pixelSize: Styles.ThemeStore.type.sm
    font.weight: Styles.ThemeStore.type.weightRegular
    font.family: Styles.ThemeStore.fonts.body
    color: Styles.ThemeStore.colors.text
    placeholderTextColor: Styles.ThemeStore.colors.text2
    selectionColor: Styles.ThemeStore.colors.accent
    selectedTextColor: Styles.ThemeStore.colors.appBg

    background: Rectangle {
        radius: Styles.ThemeStore.radii.xl
        color: search.focus ? Styles.ThemeStore.colors.hover : Styles.ThemeStore.colors.cardBg
        border.color: search.focus ? Styles.ThemeStore.colors.focus : Styles.ThemeStore.colors.divider
        border.width: search.focus ? 2 : 1
    }

    IconGlyph {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: Styles.ThemeStore.gap.g12
        anchors.verticalCenter: parent.verticalCenter
        name: "magnifyingglass"
        size: 16
        color: search.focus ? Styles.ThemeStore.colors.accent : Styles.ThemeStore.colors.text2
    }

    Keys.onEscapePressed: clear()
}
