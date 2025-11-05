import QtQuick
import QtQuick.Controls
import QtTest

TestCase {
    name: "ComponentSmoke"

    ApplicationWindow {
        id: window
        width: 1024
        height: 768
        visible: false
    }

    QtObject {
        id: stubPlanner
        property bool setupCompleted: false
        property string language: "de"
        property bool darkTheme: true
        property string weekStart: "monday"
        property bool showWeekNumbers: true
        property string selectedDate: ""
        function listCategories() { return []; }
        function addQuickEntry(text) { return ({ id: text || "1" }); }
        function setEntryCategory(id, categoryId) { }
        function jumpToToday() { }
        function setViewMode(mode) { }
        function showToast(message) { }
    }

    function cleanupTestCase() {
        window.destroy()
    }

    function createComponent(url, props) {
        const component = Qt.createComponent(Qt.resolvedUrl(url))
        if (component.status === Component.Error) {
            console.warn("Component load error for", url, component.errorString())
            component.destroy()
            return null
        }
        const parameters = {}
        if (props) {
            for (const key in props) {
                if (Object.prototype.hasOwnProperty.call(props, key)) {
                    parameters[key] = props[key]
                }
            }
        }
        if (!parameters.parent) {
            parameters.parent = window.contentItem
        }
        if (!parameters.hasOwnProperty("planner")) {
            parameters.planner = stubPlanner
        }
        const created = component.createObject(parameters.parent, parameters)
        if (!created) {
            console.warn("Component instantiation failed for", url, component.errorString())
        }
        component.destroy()
        return created
    }

    function destroyComponent(instance) {
        if (instance && instance.destroy) {
            instance.destroy()
        }
    }

    function test_quickAddDialog_instantiates() {
        const dialog = createComponent("../../src/ui/qml/components/QuickAddDialog.qml", { visible: false })
        verify(dialog !== null, "QuickAddDialog failed to instantiate")
        destroyComponent(dialog)
    }

    function test_setupWizard_instantiates() {
        const wizard = createComponent("../../src/ui/qml/components/SetupWizard.qml", { parent: window })
        verify(wizard !== null, "SetupWizard failed to instantiate")
        if (wizard && wizard.launch) {
            wizard.launch()
            wizard.close()
        }
        destroyComponent(wizard)
    }
}
