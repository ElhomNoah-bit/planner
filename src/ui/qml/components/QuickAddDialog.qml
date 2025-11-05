import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NoahPlanner 1.0
import Styles 1.0 as Styles

Item {
    id: dialog
    anchors.fill: parent
    visible: false
    z: 200

    property string entryType: "task"
    property bool allDay: true
    property date selectedDate: new Date()
    property int startHour: 17
    property int startMinute: 0
    property int durationMinutes: 60
    property string locationText: ""
    property string tagText: ""
    property string selectedCategoryId: ""
    property int priorityLevel: 0
    property var categories: []

    signal accepted(var payload)
    signal dismissed()

    function open(initialText) {
        resetForm()
        categories = planner ? planner.listCategories() : []

        var iso = planner && planner.selectedDate && planner.selectedDate.length ? planner.selectedDate : ""
        if (iso.length) {
            var parsed = new Date(iso)
            if (!isNaN(parsed)) {
                selectedDate = parsed
            }
        }

        if (initialText && initialText.length) {
            applyPrefill(initialText)
        }

        visible = true
        dialog.forceActiveFocus()
        Qt.callLater(function() {
            titleField.selectAll()
            titleField.forceActiveFocus()
        })
    }

    function close() {
        visible = false
        dialog.dismissed()
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            event.accepted = true
            dialog.close()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
        visible: dialog.visible
    }

    GlassPanel {
        id: panel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(parent.width - Styles.ThemeStore.gap.g24 * 2, 560)
        padding: Styles.ThemeStore.gap.g24
        radius: Styles.ThemeStore.radii.lg
        visible: dialog.visible

        ColumnLayout {
            anchors.fill: parent
            spacing: Styles.ThemeStore.gap.g16

            Text {
                text: qsTr("+ Neue Aufgabe / Termin")
                font.pixelSize: Styles.ThemeStore.type.lg
                font.weight: Styles.ThemeStore.type.weightBold
                font.family: Styles.ThemeStore.fonts.heading
                color: Styles.ThemeStore.colors.text
                renderType: Text.NativeRendering
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Styles.ThemeStore.gap.g8

                TextField {
                    id: titleField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Titel, z.B. Mathe lernen")
                    font.pixelSize: Styles.ThemeStore.type.md
                    font.family: Styles.ThemeStore.fonts.heading
                    color: Styles.ThemeStore.colors.text
                    placeholderTextColor: Styles.ThemeStore.colors.text2
                    selectionColor: Styles.ThemeStore.colors.accent
                    selectedTextColor: Styles.ThemeStore.colors.appBg
                    background: Rectangle {
                        radius: Styles.ThemeStore.radii.md
                        color: Styles.ThemeStore.colors.cardBg
                        border.color: titleField.activeFocus ? Styles.ThemeStore.colors.focus : Styles.ThemeStore.colors.divider
                        border.width: titleField.activeFocus ? 2 : 1
                    }
                    onAccepted: dialog.submit()
                    onActiveFocusChanged: if (!activeFocus) dialog.submitIfValid()
                    Keys.onReturnPressed: function(event) {
                        if (!event.modifiers) {
                            dialog.submit()
                            event.accepted = true
                        }
                    }
                    Keys.onEnterPressed: function(event) {
                        if (!event.modifiers) {
                            dialog.submit()
                            event.accepted = true
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styles.ThemeStore.gap.g8
                    Label {
                        text: qsTr("Typ")
                        font.pixelSize: Styles.ThemeStore.type.sm
                        color: Styles.ThemeStore.colors.text2
                    }
                    Item { Layout.fillWidth: true }
                    RowLayout {
                        spacing: Styles.ThemeStore.gap.g8
                        Button {
                            text: qsTr("Aufgabe")
                            checkable: true
                            checked: dialog.entryType === "task"
                            ButtonGroup.group: typeGroup
                            onClicked: dialog.entryType = "task"
                        }
                        Button {
                            text: qsTr("Termin")
                            checkable: true
                            checked: dialog.entryType === "event"
                            ButtonGroup.group: typeGroup
                            onClicked: dialog.entryType = "event"
                        }
                    }
                    ButtonGroup { id: typeGroup }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Styles.ThemeStore.gap.g8

                Label {
                    text: qsTr("Datum & Zeit")
                    font.pixelSize: Styles.ThemeStore.type.sm
                    font.weight: Styles.ThemeStore.type.weightBold
                    font.family: Styles.ThemeStore.fonts.heading
                    color: Styles.ThemeStore.colors.text
                    renderType: Text.NativeRendering
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styles.ThemeStore.gap.g12

                    ColumnLayout {
                        id: dateSelector
                        Layout.fillWidth: true
                        spacing: Styles.ThemeStore.gap.g8
                        property bool internalUpdate: false

                        function updateFromSelectedDate() {
                            internalUpdate = true
                            var current = dialog.selectedDate
                            if (!current || isNaN(current)) {
                                current = new Date()
                                dialog.selectedDate = current
                            }
                            var normalized = new Date(current.getFullYear(), current.getMonth(), current.getDate())
                            dayBox.value = normalized.getDate()
                            monthBox.currentIndex = normalized.getMonth()
                            yearBox.value = normalized.getFullYear()
                            internalUpdate = false
                        }

                        function commitSelection() {
                            if (internalUpdate) {
                                return
                            }
                            internalUpdate = true
                            var year = Math.round(yearBox.value)
                            var month = monthBox.currentIndex
                            var day = Math.round(dayBox.value)
                            var maxDay = new Date(year, month + 1, 0).getDate()
                            if (day > maxDay) {
                                day = maxDay
                                dayBox.value = day
                            }
                            if (day < 1) {
                                day = 1
                                dayBox.value = day
                            }
                            var candidate = new Date(year, month, day)
                            dialog.selectedDate = candidate
                            dayBox.value = candidate.getDate()
                            monthBox.currentIndex = candidate.getMonth()
                            yearBox.value = candidate.getFullYear()
                            internalUpdate = false
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Styles.ThemeStore.gap.g8

                            ColumnLayout {
                                spacing: Styles.ThemeStore.gap.g4
                                Label {
                                    text: qsTr("Tag")
                                    font.pixelSize: Styles.ThemeStore.type.xs
                                    color: Styles.ThemeStore.colors.text2
                                }
                                SpinBox {
                                    id: dayBox
                                    from: 1
                                    to: 31
                                    value: 1
                                    onValueModified: dateSelector.commitSelection()
                                    onActiveFocusChanged: if (!activeFocus) dateSelector.commitSelection()
                                }
                            }

                            ColumnLayout {
                                spacing: Styles.ThemeStore.gap.g4
                                Label {
                                    text: qsTr("Monat")
                                    font.pixelSize: Styles.ThemeStore.type.xs
                                    color: Styles.ThemeStore.colors.text2
                                }
                                ComboBox {
                                    id: monthBox
                                    Layout.fillWidth: true
                                    model: [qsTr("Jan"), qsTr("Feb"), qsTr("Mär"), qsTr("Apr"), qsTr("Mai"), qsTr("Jun"),
                                             qsTr("Jul"), qsTr("Aug"), qsTr("Sep"), qsTr("Okt"), qsTr("Nov"), qsTr("Dez")]
                                    onActivated: dateSelector.commitSelection()
                                    onCurrentIndexChanged: dateSelector.commitSelection()
                                }
                            }

                            ColumnLayout {
                                spacing: Styles.ThemeStore.gap.g4
                                Label {
                                    text: qsTr("Jahr")
                                    font.pixelSize: Styles.ThemeStore.type.xs
                                    color: Styles.ThemeStore.colors.text2
                                }
                                SpinBox {
                                    id: yearBox
                                    from: 1970
                                    to: 2100
                                    value: (new Date()).getFullYear()
                                    onValueModified: dateSelector.commitSelection()
                                    onActiveFocusChanged: if (!activeFocus) dateSelector.commitSelection()
                                }
                            }
                        }

                        Component.onCompleted: updateFromSelectedDate()
                    }

                    ColumnLayout {
                        spacing: Styles.ThemeStore.gap.g8

                        CheckBox {
                            text: qsTr("Ganztägig")
                            checked: dialog.allDay
                            onToggled: dialog.allDay = checked
                        }

                        RowLayout {
                            spacing: Styles.ThemeStore.gap.g8
                            enabled: !dialog.allDay
                            opacity: enabled ? 1 : 0.4

                            Label {
                                text: qsTr("Start")
                                font.pixelSize: Styles.ThemeStore.type.xs
                                color: Styles.ThemeStore.colors.text2
                            }

                            SpinBox {
                                from: 0
                                to: 23
                                value: dialog.startHour
                                stepSize: 1
                                onValueModified: dialog.startHour = value
                            }

                            Label {
                                text: ":"
                                font.pixelSize: Styles.ThemeStore.type.sm
                                color: Styles.ThemeStore.colors.text2
                            }

                            SpinBox {
                                from: 0
                                to: 55
                                stepSize: 5
                                value: dialog.startMinute
                                onValueModified: dialog.startMinute = value
                            }

                            Label {
                                text: qsTr("Dauer (Min)")
                                font.pixelSize: Styles.ThemeStore.type.xs
                                color: Styles.ThemeStore.colors.text2
                            }

                            SpinBox {
                                from: 0
                                to: 480
                                stepSize: 15
                                value: dialog.durationMinutes
                                onValueModified: dialog.durationMinutes = value
                            }
                        }
                    }
                }
            }

            Connections {
                target: dialog
                function onSelectedDateChanged() {
                    if (dateSelector) {
                        dateSelector.updateFromSelectedDate()
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Styles.ThemeStore.gap.g8

                Label {
                    text: qsTr("Kategorie & Kontext")
                    font.pixelSize: Styles.ThemeStore.type.sm
                    font.weight: Styles.ThemeStore.type.weightBold
                    font.family: Styles.ThemeStore.fonts.heading
                    color: Styles.ThemeStore.colors.text
                    renderType: Text.NativeRendering
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styles.ThemeStore.gap.g12

                    ComboBox {
                        id: categoryBox
                        Layout.fillWidth: true
                        model: categoriesModel
                        textRole: "label"
                        delegate: ItemDelegate {
                            width: parent.width
                            text: model.label
                        }
                        onActivated: if (index >= 0 && index < categoriesModel.count) dialog.selectedCategoryId = categoriesModel.get(index).id
                        onCurrentIndexChanged: if (currentIndex >= 0 && currentIndex < categoriesModel.count) dialog.selectedCategoryId = categoriesModel.get(currentIndex).id
                    }

                    ComboBox {
                        id: priorityBox
                        model: [qsTr("Priorität"), "!", "!!", "!!!"]
                        currentIndex: dialog.priorityLevel
                        onActivated: dialog.priorityLevel = index
                        onCurrentIndexChanged: dialog.priorityLevel = currentIndex
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Styles.ThemeStore.gap.g12

                    TextField {
                        id: locationField
                        Layout.fillWidth: true
                        placeholderText: qsTr("Ort, z.B. @Schule")
                        text: dialog.locationText
                        onTextChanged: dialog.locationText = text
                        background: Rectangle {
                            radius: Styles.ThemeStore.radii.sm
                            color: Styles.ThemeStore.colors.cardBg
                            border.color: locationField.activeFocus ? Styles.ThemeStore.colors.focus : Styles.ThemeStore.colors.divider
                            border.width: locationField.activeFocus ? 2 : 1
                        }
                    }

                    TextField {
                        id: tagField
                        Layout.fillWidth: true
                        placeholderText: qsTr("Tags, z.B. Lernen, Mathe")
                        text: dialog.tagText
                        onTextChanged: dialog.tagText = text
                        background: Rectangle {
                            radius: Styles.ThemeStore.radii.sm
                            color: Styles.ThemeStore.colors.cardBg
                            border.color: tagField.activeFocus ? Styles.ThemeStore.colors.focus : Styles.ThemeStore.colors.divider
                            border.width: tagField.activeFocus ? 2 : 1
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Styles.ThemeStore.gap.g12
                PillButton {
                    text: qsTr("Speichern")
                    kind: "primary"
                    Layout.preferredWidth: 160
                    onClicked: submit()
                }
                PillButton {
                    text: qsTr("Abbrechen")
                    kind: "ghost"
                    Layout.preferredWidth: 160
                    onClicked: dialog.close()
                }
                Item { Layout.fillWidth: true }
            }
        }
    }

    ListModel {
        id: categoriesModel
    }

    function resetForm() {
        entryType = "task"
        allDay = true
        startHour = 17
        startMinute = 0
        durationMinutes = 60
        locationText = ""
        tagText = ""
        selectedCategoryId = ""
        priorityLevel = 0
        categoriesModel.clear()
        categoriesModel.append({ id: "", label: qsTr("Keine Kategorie") })
        var list = planner ? planner.listCategories() : []
        if (list && list.length) {
            for (var i = 0; i < list.length; ++i) {
                categoriesModel.append({ id: list[i].id, label: list[i].name })
            }
        }
        categoryBox.currentIndex = 0
        priorityBox.currentIndex = 0
        selectedDate = new Date()
        titleField.text = ""
    }

    onEntryTypeChanged: {
        if (entryType === "task") {
            allDay = true
        } else if (entryType === "event" && allDay) {
            allDay = false
        }
    }

    function applyPrefill(text) {
        var working = text
        var match = /(Termin|Aufgabe) am (\d{1,2}\.\d{1,2}\.\d{4})\s*/i.exec(working)
        if (match) {
            entryType = match[1].toLowerCase() === "termin" ? "event" : "task"
            var parsed = parseDateString(match[2])
            if (parsed) {
                selectedDate = parsed
            }
            working = working.slice(match[0].length)
        }
        titleField.text = working.trim()
    }

    function parseDateString(value) {
        var parts = value.split(".")
        if (parts.length < 2) {
            return new Date()
        }
        var day = parseInt(parts[0])
        var month = parseInt(parts[1]) - 1
        var year = parts.length >= 3 ? parseInt(parts[2]) : (new Date()).getFullYear()
        if (isNaN(day) || isNaN(month) || isNaN(year)) {
            return new Date()
        }
        return new Date(year, month, day)
    }

    function assembleText() {
        var title = titleField.text.trim()
        if (!title.length) {
            titleField.forceActiveFocus()
            return ""
        }

        var parts = [title]
        var dateString = Qt.formatDate(selectedDate, "dd.MM.yyyy")
        if (dateString.length) {
            parts.push(dateString)
        }

        if (!allDay) {
            var hh = twoDigits(startHour)
            var mm = twoDigits(startMinute)
            parts.push(hh + ":" + mm)
            if (durationMinutes > 0) {
                parts.push(durationMinutes + "min")
            }
        }

        if (locationText.trim().length) {
            var normalizedLocation = locationText.trim()
            if (normalizedLocation.startsWith("@")) {
                parts.push(normalizedLocation)
            } else {
                parts.push("@" + normalizedLocation)
            }
        }

        if (tagText.trim().length) {
            var tagTokens = tagText.split(/[\s,;]+/)
            for (var i = 0; i < tagTokens.length; ++i) {
                var tag = tagTokens[i].trim()
                if (!tag.length) {
                    continue
                }
                if (tag.startsWith("#")) {
                    parts.push(tag)
                } else {
                    parts.push("#" + tag)
                }
            }
        }

        if (priorityLevel > 0) {
            parts.push(repeatChar("!", priorityLevel))
        }

        return parts.join(" ")
    }

    function buildSubmissionPayload() {
        var value = assembleText()
        if (!value.length) {
            return null
        }
        return {
            text: value,
            categoryId: selectedCategoryId,
            entryType: entryType,
            allDay: allDay
        }
    }

    function finalizeSubmission(payload) {
        accepted(payload)
        dialog.close()
    }

    function submit() {
        var payload = buildSubmissionPayload()
        if (!payload) {
            return
        }
        finalizeSubmission(payload)
    }

    function submitIfValid() {
        var payload = buildSubmissionPayload()
        if (!payload) {
            return
        }
        finalizeSubmission(payload)
    }

    onVisibleChanged: function() {
        if (!visible) {
            resetForm()
        }
    }

    function twoDigits(value) {
        return value < 10 ? "0" + value : "" + value
    }

    function repeatChar(ch, count) {
        var result = ""
        for (var i = 0; i < count; ++i) {
            result += ch
        }
        return result
    }
}
