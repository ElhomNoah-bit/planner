cmake_minimum_required(VERSION 3.16)
project(noah_planner LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 COMPONENTS Quick Qml QuickControls2 QuickLayouts REQUIRED)

qt_standard_project_setup()

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

qt_add_executable(noah_planner
    src/main.cpp
    src/core/PlannerService.cpp
    src/core/PlannerService.h
    src/core/Task.h
    src/core/Subject.h
    src/core/Exam.h
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
        src/ui/qml/components/PillButton.qml
        src/ui/qml/components/QuickAddPill.qml
        src/ui/qml/components/SegmentedControl.qml
        src/ui/qml/components/TimerOverlay.qml
        src/ui/qml/components/Toast.qml
        src/ui/qml/components/ToastHost.qml
        src/ui/qml/components/TodayTaskDelegate.qml
        src/ui/qml/styles/ThemeStore.qml
        src/ui/qml/views/AgendaView.qml
        src/ui/qml/views/MonthView.qml
        src/ui/qml/views/SidebarToday.qml
        src/ui/qml/views/WeekView.qml
)

qt_add_resources(noah_planner font_assets
    PREFIX "/fonts"
    BASE assets/fonts
    FILES
        Inter-Regular.ttf
)

target_include_directories(noah_planner PRIVATE src)

target_link_libraries(noah_planner PRIVATE Qt6::Quick Qt6::Qml Qt6::QuickControls2 Qt6::QuickLayouts)

install(TARGETS noah_planner RUNTIME DESTINATION bin)
