cmake_minimum_required(VERSION 3.16)
project(noah_planner LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 COMPONENTS Quick Qml QuickControls2 QuickLayouts Widgets Sql REQUIRED)

qt_standard_project_setup()

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

qt_add_executable(noah_planner
    src/main.cpp
    src/core/PlannerService.cpp
    src/core/PlannerService.h
    src/core/EventRepository.cpp
    src/core/EventRepository.h
    src/core/CategoryRepository.cpp
    src/core/CategoryRepository.h
    src/core/QuickAddParser.cpp
    src/core/QuickAddParser.h
    src/core/Task.h
    src/core/Subject.h
    src/core/Exam.h
    src/core/Category.h
    src/models/EventModel.cpp
    src/models/EventModel.h
    src/models/TaskModel.cpp
    src/models/TaskModel.h
    src/models/ExamModel.cpp
    src/models/ExamModel.h
    src/models/TaskFilterProxy.cpp
    src/models/TaskFilterProxy.h
    src/ui/AppState.cpp
    src/ui/AppState.h
    src/ui/PlannerBackend.cpp
    src/ui/PlannerBackend.h
)

set_source_files_properties(src/ui/qml/styles/ThemeStore.qml
    PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(noah_planner
    URI NoahPlanner
    VERSION 1.0
    RESOURCE_PREFIX "/qt/qml"
    QML_FILES
        src/ui/qml/App.qml
        src/ui/qml/Main.qml
        src/ui/qml/components/DayCell.qml
        src/ui/qml/components/EventChip.qml
        src/ui/qml/components/FilterPill.qml
        src/ui/qml/components/GlassPanel.qml
        src/ui/qml/components/IconGlyph.qml
    src/ui/qml/components/CommandPalette.qml
        src/ui/qml/components/PillButton.qml
    src/ui/qml/components/QuickAddDialog.qml
        src/ui/qml/components/QuickAddPill.qml
    src/ui/qml/components/SearchField.qml
        src/ui/qml/components/SegmentedControl.qml
        src/ui/qml/components/TimerOverlay.qml
        src/ui/qml/components/Toast.qml
        src/ui/qml/components/ToastHost.qml
    src/ui/qml/components/SettingsDialog.qml
        src/ui/qml/components/TodayTaskDelegate.qml
        src/ui/qml/components/ZenToggleButton.qml
        src/ui/qml/views/AgendaView.qml
        src/ui/qml/views/MonthView.qml
        src/ui/qml/views/SidebarToday.qml
        src/ui/qml/views/WeekView.qml
)

set_source_files_properties(
    ${CMAKE_CURRENT_SOURCE_DIR}/assets/fonts/Inter-Regular.ttf
    PROPERTIES QT_RESOURCE_ALIAS "Inter-Regular.ttf"
)
set_source_files_properties(
    ${CMAKE_CURRENT_SOURCE_DIR}/assets/fonts/Inter-Bold.ttf
    PROPERTIES QT_RESOURCE_ALIAS "Inter-Bold.ttf"
)

qt_add_resources(noah_planner fonts
    PREFIX "/fonts"
    FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/assets/fonts/Inter-Regular.ttf
        ${CMAKE_CURRENT_SOURCE_DIR}/assets/fonts/Inter-Bold.ttf
)

qt_add_qml_module(styles_module
    URI NoahPlanner.Styles
    VERSION 1.0
    RESOURCE_PREFIX "/qt/qml"
    STATIC
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/NoahPlanner/Styles
    QML_FILES
        src/ui/qml/styles/ThemeStore.qml
)

target_link_libraries(noah_planner PRIVATE styles_module)

target_include_directories(noah_planner PRIVATE src)

target_link_libraries(noah_planner PRIVATE Qt6::Gui Qt6::Quick Qt6::Qml Qt6::QuickControls2 Qt6::QuickLayouts Qt6::Widgets Qt6::Sql)

install(TARGETS noah_planner RUNTIME DESTINATION bin)
