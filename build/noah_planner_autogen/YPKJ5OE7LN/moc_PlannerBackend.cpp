/****************************************************************************
** Meta object code from reading C++ file 'PlannerBackend.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.9.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/ui/PlannerBackend.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'PlannerBackend.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.9.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN14PlannerBackendE_t {};
} // unnamed namespace

template <> constexpr inline auto PlannerBackend::qt_create_metaobjectdata<qt_meta_tag_ZN14PlannerBackendE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "PlannerBackend",
        "darkThemeChanged",
        "",
        "subjectsChanged",
        "selectedDateChanged",
        "tasksChanged",
        "examsChanged",
        "viewModeChanged",
        "filtersChanged",
        "toastRequested",
        "message",
        "settingsChanged",
        "selectDateIso",
        "isoDate",
        "refreshToday",
        "toggleTaskDone",
        "proxyRow",
        "done",
        "dayEvents",
        "QVariantList",
        "daySummary",
        "QVariantMap",
        "toggleSubject",
        "subjectId",
        "setSubjectFilter",
        "subjectIds",
        "subjectFilter",
        "subjectById",
        "id",
        "subjectColor",
        "weekEvents",
        "weekStartIso",
        "listBuckets",
        "quickAdd",
        "input",
        "showToast",
        "darkTheme",
        "todayTasks",
        "TaskFilterProxy*",
        "exams",
        "ExamModel*",
        "subjects",
        "selectedDate",
        "viewMode",
        "onlyOpen",
        "searchQuery",
        "language",
        "weekStart",
        "showWeekNumbers"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'darkThemeChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'subjectsChanged'
        QtMocHelpers::SignalData<void()>(3, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'selectedDateChanged'
        QtMocHelpers::SignalData<void()>(4, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'tasksChanged'
        QtMocHelpers::SignalData<void()>(5, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'examsChanged'
        QtMocHelpers::SignalData<void()>(6, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'viewModeChanged'
        QtMocHelpers::SignalData<void()>(7, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'filtersChanged'
        QtMocHelpers::SignalData<void()>(8, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'toastRequested'
        QtMocHelpers::SignalData<void(const QString &)>(9, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 10 },
        }}),
        // Signal 'settingsChanged'
        QtMocHelpers::SignalData<void()>(11, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'selectDateIso'
        QtMocHelpers::MethodData<void(const QString &)>(12, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 13 },
        }}),
        // Method 'refreshToday'
        QtMocHelpers::MethodData<void()>(14, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'toggleTaskDone'
        QtMocHelpers::MethodData<void(int, bool)>(15, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 16 }, { QMetaType::Bool, 17 },
        }}),
        // Method 'dayEvents'
        QtMocHelpers::MethodData<QVariantList(const QString &) const>(18, 2, QMC::AccessPublic, 0x80000000 | 19, {{
            { QMetaType::QString, 13 },
        }}),
        // Method 'daySummary'
        QtMocHelpers::MethodData<QVariantMap(const QString &) const>(20, 2, QMC::AccessPublic, 0x80000000 | 21, {{
            { QMetaType::QString, 13 },
        }}),
        // Method 'toggleSubject'
        QtMocHelpers::MethodData<void(const QString &)>(22, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 23 },
        }}),
        // Method 'setSubjectFilter'
        QtMocHelpers::MethodData<void(const QStringList &)>(24, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QStringList, 25 },
        }}),
        // Method 'subjectFilter'
        QtMocHelpers::MethodData<QStringList() const>(26, 2, QMC::AccessPublic, QMetaType::QStringList),
        // Method 'subjectById'
        QtMocHelpers::MethodData<QVariantMap(const QString &) const>(27, 2, QMC::AccessPublic, 0x80000000 | 21, {{
            { QMetaType::QString, 28 },
        }}),
        // Method 'subjectColor'
        QtMocHelpers::MethodData<QColor(const QString &) const>(29, 2, QMC::AccessPublic, QMetaType::QColor, {{
            { QMetaType::QString, 28 },
        }}),
        // Method 'weekEvents'
        QtMocHelpers::MethodData<QVariantList(const QString &) const>(30, 2, QMC::AccessPublic, 0x80000000 | 19, {{
            { QMetaType::QString, 31 },
        }}),
        // Method 'listBuckets'
        QtMocHelpers::MethodData<QVariantList() const>(32, 2, QMC::AccessPublic, 0x80000000 | 19),
        // Method 'quickAdd'
        QtMocHelpers::MethodData<void(const QString &)>(33, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 34 },
        }}),
        // Method 'showToast'
        QtMocHelpers::MethodData<void(const QString &)>(35, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 10 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'darkTheme'
        QtMocHelpers::PropertyData<bool>(36, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 0),
        // property 'todayTasks'
        QtMocHelpers::PropertyData<TaskFilterProxy*>(37, 0x80000000 | 38, QMC::DefaultPropertyFlags | QMC::EnumOrFlag | QMC::Constant),
        // property 'exams'
        QtMocHelpers::PropertyData<ExamModel*>(39, 0x80000000 | 40, QMC::DefaultPropertyFlags | QMC::EnumOrFlag | QMC::Constant),
        // property 'subjects'
        QtMocHelpers::PropertyData<QVariantList>(41, 0x80000000 | 19, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 1),
        // property 'selectedDate'
        QtMocHelpers::PropertyData<QString>(42, QMetaType::QString, QMC::DefaultPropertyFlags, 2),
        // property 'viewMode'
        QtMocHelpers::PropertyData<QString>(43, QMetaType::QString, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 5),
        // property 'onlyOpen'
        QtMocHelpers::PropertyData<bool>(44, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 6),
        // property 'searchQuery'
        QtMocHelpers::PropertyData<QString>(45, QMetaType::QString, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 6),
        // property 'language'
        QtMocHelpers::PropertyData<QString>(46, QMetaType::QString, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 8),
        // property 'weekStart'
        QtMocHelpers::PropertyData<QString>(47, QMetaType::QString, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 8),
        // property 'showWeekNumbers'
        QtMocHelpers::PropertyData<bool>(48, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 8),
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<PlannerBackend, qt_meta_tag_ZN14PlannerBackendE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject PlannerBackend::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN14PlannerBackendE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN14PlannerBackendE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN14PlannerBackendE_t>.metaTypes,
    nullptr
} };

void PlannerBackend::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<PlannerBackend *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->darkThemeChanged(); break;
        case 1: _t->subjectsChanged(); break;
        case 2: _t->selectedDateChanged(); break;
        case 3: _t->tasksChanged(); break;
        case 4: _t->examsChanged(); break;
        case 5: _t->viewModeChanged(); break;
        case 6: _t->filtersChanged(); break;
        case 7: _t->toastRequested((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 8: _t->settingsChanged(); break;
        case 9: _t->selectDateIso((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 10: _t->refreshToday(); break;
        case 11: _t->toggleTaskDone((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<bool>>(_a[2]))); break;
        case 12: { QVariantList _r = _t->dayEvents((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 13: { QVariantMap _r = _t->daySummary((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 14: _t->toggleSubject((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 15: _t->setSubjectFilter((*reinterpret_cast< std::add_pointer_t<QStringList>>(_a[1]))); break;
        case 16: { QStringList _r = _t->subjectFilter();
            if (_a[0]) *reinterpret_cast< QStringList*>(_a[0]) = std::move(_r); }  break;
        case 17: { QVariantMap _r = _t->subjectById((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 18: { QColor _r = _t->subjectColor((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QColor*>(_a[0]) = std::move(_r); }  break;
        case 19: { QVariantList _r = _t->weekEvents((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 20: { QVariantList _r = _t->listBuckets();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 21: _t->quickAdd((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 22: _t->showToast((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::darkThemeChanged, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::subjectsChanged, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::selectedDateChanged, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::tasksChanged, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::examsChanged, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::viewModeChanged, 5))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::filtersChanged, 6))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)(const QString & )>(_a, &PlannerBackend::toastRequested, 7))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::settingsChanged, 8))
            return;
    }
    if (_c == QMetaObject::RegisterPropertyMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 2:
            *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< ExamModel* >(); break;
        case 1:
            *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< TaskFilterProxy* >(); break;
        }
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<bool*>(_v) = _t->darkTheme(); break;
        case 1: *reinterpret_cast<TaskFilterProxy**>(_v) = _t->todayTasks(); break;
        case 2: *reinterpret_cast<ExamModel**>(_v) = _t->exams(); break;
        case 3: *reinterpret_cast<QVariantList*>(_v) = _t->subjects(); break;
        case 4: *reinterpret_cast<QString*>(_v) = _t->selectedDateIso(); break;
        case 5: *reinterpret_cast<QString*>(_v) = _t->viewMode(); break;
        case 6: *reinterpret_cast<bool*>(_v) = _t->onlyOpen(); break;
        case 7: *reinterpret_cast<QString*>(_v) = _t->searchQuery(); break;
        case 8: *reinterpret_cast<QString*>(_v) = _t->language(); break;
        case 9: *reinterpret_cast<QString*>(_v) = _t->weekStart(); break;
        case 10: *reinterpret_cast<bool*>(_v) = _t->showWeekNumbers(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setDarkTheme(*reinterpret_cast<bool*>(_v)); break;
        case 5: _t->setViewMode(*reinterpret_cast<QString*>(_v)); break;
        case 6: _t->setOnlyOpen(*reinterpret_cast<bool*>(_v)); break;
        case 7: _t->setSearchQuery(*reinterpret_cast<QString*>(_v)); break;
        case 8: _t->setLanguage(*reinterpret_cast<QString*>(_v)); break;
        case 9: _t->setWeekStart(*reinterpret_cast<QString*>(_v)); break;
        case 10: _t->setShowWeekNumbers(*reinterpret_cast<bool*>(_v)); break;
        default: break;
        }
    }
}

const QMetaObject *PlannerBackend::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *PlannerBackend::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN14PlannerBackendE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int PlannerBackend::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 23)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 23;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 23)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 23;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 11;
    }
    return _id;
}

// SIGNAL 0
void PlannerBackend::darkThemeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void PlannerBackend::subjectsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void PlannerBackend::selectedDateChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void PlannerBackend::tasksChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void PlannerBackend::examsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void PlannerBackend::viewModeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void PlannerBackend::filtersChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 6, nullptr);
}

// SIGNAL 7
void PlannerBackend::toastRequested(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 7, nullptr, _t1);
}

// SIGNAL 8
void PlannerBackend::settingsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 8, nullptr);
}
QT_WARNING_POP
