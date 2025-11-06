cmake_minimum_required(VERSION 3.16)
project(noah_planner LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable automatic MOC, UIC, and RCC for Qt
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC_COMPILER_PREDEFINES OFF)

# Windows-specific settings
if(WIN32)
    # Enable Unicode support
    add_definitions(-DUNICODE -D_UNICODE)
endif()

find_package(Qt6 6.4 COMPONENTS Core Quick Qml QuickControls2 QuickLayouts Widgets Sql PrintSupport QuickTest REQUIRED)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

qt_standard_project_setup()

qt_add_executable(noah_planner
    src/main.cpp
    src/core/PlannerService.cpp
    src/core/PlannerService.h
    src/core/EventRepository.cpp
    src/core/EventRepository.h
    src/core/CategoryRepository.cpp
    src/core/CategoryRepository.h
    src/core/IcsImportService.cpp
    src/core/IcsImportService.h
    src/core/FocusSession.cpp
    src/core/FocusSession.h
    src/core/FocusSessionRepository.cpp
    src/core/FocusSessionRepository.h
    src/core/QuickAddParser.cpp
    src/core/QuickAddParser.h
    src/core/PomodoroTimer.cpp
    src/core/PomodoroTimer.h
    src/core/ScheduleExporter.cpp
    src/core/ScheduleExporter.h
    src/core/SpacedRepetitionService.cpp
    src/core/SpacedRepetitionService.h
    src/core/Task.h
    src/core/Subject.h
    src/core/Exam.h
    src/core/Review.h
    src/core/Category.h
    src/models/EventModel.cpp
    src/models/EventModel.h
    src/models/TaskModel.cpp
    src/models/TaskModel.h
    src/models/ExamModel.cpp
    src/models/ExamModel.h
    src/models/ReviewModel.cpp
    src/models/ReviewModel.h
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
    NO_PLUGIN
    QML_FILES
        src/ui/qml/App.qml
        src/ui/qml/Main.qml
        src/ui/qml/components/DayCell.qml
        src/ui/qml/components/EventChip.qml
        src/ui/qml/components/FilterPill.qml
        src/ui/qml/components/GlassPanel.qml
        src/ui/qml/components/IconGlyph.qml
        src/ui/qml/components/CategoryPicker.qml
        src/ui/qml/components/CommandPalette.qml
        src/ui/qml/components/ExportDialog.qml
        src/ui/qml/components/FocusControls.qml
        src/ui/qml/components/PillButton.qml
        src/ui/qml/components/QuickAddDialog.qml
        src/ui/qml/components/QuickAddPill.qml
        src/ui/qml/components/PomodoroOverlay.qml
        src/ui/qml/components/PomodoroStats.qml
        src/ui/qml/components/SearchField.qml
        src/ui/qml/components/SegmentedControl.qml
        src/ui/qml/components/StreakBadge.qml
        src/ui/qml/components/TimerOverlay.qml
        src/ui/qml/components/Toast.qml
        src/ui/qml/components/ToastHost.qml
        src/ui/qml/components/SettingsDialog.qml
        src/ui/qml/components/SetupWizard.qml
        src/ui/qml/components/TodayTaskDelegate.qml
        src/ui/qml/components/ZenToggleButton.qml
        src/ui/qml/components/ReviewIndicator.qml
        src/ui/qml/components/ReviewDialog.qml
        src/ui/qml/views/AgendaView.qml
        src/ui/qml/views/MonthView.qml
        src/ui/qml/views/SidebarToday.qml
        src/ui/qml/views/WeekView.qml
        src/ui/qml/components/WeeklyHeatmap.qml
    RESOURCES
        src/ui/qml/qmldir
        src/ui/qml/utils/Safe.js
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
    URI Styles
    VERSION 1.0
    RESOURCE_PREFIX "/qt/qml"
    NO_PLUGIN
    OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/NoahPlanner/Styles
    QML_FILES
        src/ui/qml/styles/ThemeStore.qml
    RESOURCES
        src/ui/qml/styles/qmldir
)

target_link_libraries(noah_planner PRIVATE
    styles_module
    Qt6::Gui
    Qt6::Quick
    Qt6::Qml
    Qt6::QuickControls2
    Qt6::QuickLayouts
    Qt6::Widgets
    Qt6::Sql
    Qt6::PrintSupport)

target_include_directories(noah_planner PRIVATE src)

# Platform-specific installation
if(WIN32)
    install(TARGETS noah_planner 
            RUNTIME DESTINATION .
            LIBRARY DESTINATION .
            ARCHIVE DESTINATION .)
else()
    install(TARGETS noah_planner RUNTIME DESTINATION bin)
endif()

enable_testing()

set(QML_TEST_IMPORT_DIR ${CMAKE_CURRENT_BINARY_DIR}/qml_test_imports/NoahPlanner)
set(QML_TEST_IMPORT_STAMP ${QML_TEST_IMPORT_DIR}/.stamp)
add_custom_command(
    OUTPUT ${QML_TEST_IMPORT_STAMP}
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/NoahPlanner/qmldir $<TARGET_FILE:styles_module>
    COMMAND ${CMAKE_COMMAND} -E rm -rf ${QML_TEST_IMPORT_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_BINARY_DIR}/NoahPlanner ${QML_TEST_IMPORT_DIR}
    COMMAND ${CMAKE_COMMAND} -DINPUT=${QML_TEST_IMPORT_DIR}/qmldir -DOUTPUT=${QML_TEST_IMPORT_DIR}/qmldir -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/StripQmldirPrefer.cmake
    COMMAND ${CMAKE_COMMAND} -DINPUT=${QML_TEST_IMPORT_DIR}/Styles/qmldir -DOUTPUT=${QML_TEST_IMPORT_DIR}/Styles/qmldir -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/StripQmldirPrefer.cmake
    COMMAND ${CMAKE_COMMAND} -DINPUT=${QML_TEST_IMPORT_DIR}/src/ui/qml/components/qmldir -DOUTPUT=${QML_TEST_IMPORT_DIR}/src/ui/qml/components/qmldir -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/StripQmldirPrefer.cmake
    COMMAND ${CMAKE_COMMAND} -DINPUT=${QML_TEST_IMPORT_DIR}/src/ui/qml/views/qmldir -DOUTPUT=${QML_TEST_IMPORT_DIR}/src/ui/qml/views/qmldir -P ${CMAKE_CURRENT_SOURCE_DIR}/cmake/StripQmldirPrefer.cmake
    COMMAND ${CMAKE_COMMAND} -E copy_if_different $<TARGET_FILE:styles_module> ${QML_TEST_IMPORT_DIR}/Styles
    COMMAND ${CMAKE_COMMAND} -E touch ${QML_TEST_IMPORT_STAMP}
)
add_custom_target(qml_test_imports ALL DEPENDS ${QML_TEST_IMPORT_STAMP})

# Priority rules test
add_executable(priority_rules_test
    tests/priority_rules_test.cpp
)
target_include_directories(priority_rules_test PRIVATE src)
target_link_libraries(priority_rules_test PRIVATE Qt6::Core Qt6::Gui)
add_test(NAME priority_rules_test COMMAND priority_rules_test)

# PlannerService test
add_executable(planner_service_test
    tests/planner_service_test.cpp
    src/core/PlannerService.cpp
    src/core/SpacedRepetitionService.cpp
)
target_include_directories(planner_service_test PRIVATE src)
target_link_libraries(planner_service_test PRIVATE Qt6::Core Qt6::Gui)
add_test(NAME planner_service_test COMMAND planner_service_test)

# SpacedRepetitionService test
add_executable(spaced_repetition_test
    tests/spaced_repetition_test.cpp
    src/core/SpacedRepetitionService.cpp
)
target_include_directories(spaced_repetition_test PRIVATE src)
target_link_libraries(spaced_repetition_test PRIVATE Qt6::Core Qt6::Gui)
add_test(NAME spaced_repetition_test COMMAND spaced_repetition_test)

# QuickAddParser test
add_executable(quick_add_parser_test
    tests/quick_add_parser_test.cpp
    src/core/QuickAddParser.cpp
)
target_include_directories(quick_add_parser_test PRIVATE src)
target_link_libraries(quick_add_parser_test PRIVATE Qt6::Core Qt6::Gui)
add_test(NAME quick_add_parser_test COMMAND quick_add_parser_test)

# Edge cases test
add_executable(edge_cases_test
    tests/edge_cases_test.cpp
    src/core/PlannerService.cpp
    src/core/SpacedRepetitionService.cpp
    src/core/QuickAddParser.cpp
)
target_include_directories(edge_cases_test PRIVATE src)
target_link_libraries(edge_cases_test PRIVATE Qt6::Core Qt6::Gui)
add_test(NAME edge_cases_test COMMAND edge_cases_test)

set(QML_TEST_DIR ${CMAKE_CURRENT_SOURCE_DIR}/tests/qml)
if(EXISTS ${QML_TEST_DIR})
    add_test(NAME qml_component_smoke
        COMMAND Qt6::qmltestrunner
        -import ${CMAKE_CURRENT_BINARY_DIR}/qml_test_imports
        -import ${CMAKE_CURRENT_BINARY_DIR}/qml_test_imports/NoahPlanner
                -input ${QML_TEST_DIR}/tst_component_smoke.qml)
endif()
