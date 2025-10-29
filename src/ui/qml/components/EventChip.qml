import QtQuick
import QtQuick.Layouts
import NoahPlanner.Styles as Styles

Rectangle {
    id: chip
    property string label: ""
    property color subjectColor: Styles.ThemeStore.accent
    property bool muted: false
    property bool overdue: false
    property string timeText: ""
    property bool timed: timeText.length > 0
    property string categoryColor: ""
    property string deadlineSeverity: "none"
    property bool zenMode: false

    implicitHeight: 26
    implicitWidth: Math.max(92, contentRow.implicitWidth + Styles.ThemeStore.g16)
    radius: Styles.ThemeStore.r12
    color: muted ? Styles.ThemeStore.cardAlt : Styles.ThemeStore.cardBg
    
    border.width: {
        if (categoryColor.length > 0) return 2
        if (deadlineSeverity === "danger" || deadlineSeverity === "overdue") return 2
        if (deadlineSeverity === "warn") return 1
        if (overdue) return 1
        return 0
    }
    
    border.color: {
        if (categoryColor.length > 0) return categoryColor
        if (deadlineSeverity === "overdue") return Styles.ThemeStore.colors.overdue
        if (deadlineSeverity === "danger") return Styles.ThemeStore.colors.danger
        if (deadlineSeverity === "warn") return Styles.ThemeStore.colors.warn
        if (overdue) return Styles.ThemeStore.danger
        return "transparent"
    }

    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.margins: Styles.ThemeStore.g12
        spacing: Styles.ThemeStore.g8

        Rectangle {
            width: timed ? 6 : 0
            height: timed ? 6 : 0
            radius: 3
            color: muted ? Styles.ThemeStore.divider : subjectColor
            visible: timed
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                visible: timed
                text: chip.timeText
                font.pixelSize: Styles.ThemeStore.type.xs
                font.weight: Styles.ThemeStore.type.weightMedium
                font.family: Styles.ThemeStore.fonts.uiFallback
                color: Styles.ThemeStore.colors.text2
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }

            Text {
                id: labelText
                text: chip.label
                color: Styles.ThemeStore.colors.textPrimary
                font.pixelSize: Styles.ThemeStore.type.sm
                font.weight: Styles.ThemeStore.type.weightMedium
                font.family: Styles.ThemeStore.fonts.heading
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                renderType: Text.NativeRendering
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: chip.radius
        color: Styles.ThemeStore.hover
        visible: hoverHandler.hovered
        opacity: 0.2
    }

    HoverHandler {
        id: hoverHandler
    }
    
    // Pulse glow effect for danger/overdue (reduced in Zen Mode)
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        radius: chip.radius + 2
        color: "transparent"
        border.width: 2
        border.color: {
            if (deadlineSeverity === "overdue") return Styles.ThemeStore.colors.overdue
            if (deadlineSeverity === "danger") return Styles.ThemeStore.colors.danger
            return "transparent"
        }
        opacity: glowAnimation.running ? 0.4 : 0
        visible: !zenMode && (deadlineSeverity === "danger" || deadlineSeverity === "overdue")
        
        SequentialAnimation on opacity {
            id: glowAnimation
            running: !zenMode && (chip.deadlineSeverity === "danger" || chip.deadlineSeverity === "overdue")
            loops: Animation.Infinite
            NumberAnimation { from: 0; to: 0.4; duration: 1500; easing.type: Easing.InOutSine }
            NumberAnimation { from: 0.4; to: 0; duration: 1500; easing.type: Easing.InOutSine }
        }
    }
}
