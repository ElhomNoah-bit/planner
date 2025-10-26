cmake_minimum_required(VERSION 3.16)
project(noah_planner LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.2 COMPONENTS Widgets REQUIRED)

qt_standard_project_setup()

qt_add_resources(ui_resources src/ui/ui.qrc)

add_executable(noah_planner
    src/main.cpp
    src/MainWindow.cpp
    src/MainWindow.h
    src/ExamDialog.cpp
    src/ExamDialog.h
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
    src/ui/TaskDelegate.cpp
    src/ui/TaskDelegate.h
    src/ui/ToastManager.cpp
    src/ui/ToastManager.h
    src/ui/AppState.cpp
    src/ui/AppState.h
    src/ui/theme/ThemeManager.cpp
    src/ui/theme/ThemeManager.h
    src/ui/views/MonthView.cpp
    src/ui/views/MonthView.h
    src/ui/components/DayCardWidget.cpp
    src/ui/components/DayCardWidget.h
    src/ui/components/FilterChip.cpp
    src/ui/components/FilterChip.h
)

target_include_directories(noah_planner PRIVATE src)

target_link_libraries(noah_planner PRIVATE Qt6::Widgets)
target_sources(noah_planner PRIVATE ${ui_resources})

# Install rules (optional)
install(TARGETS noah_planner RUNTIME DESTINATION bin)
