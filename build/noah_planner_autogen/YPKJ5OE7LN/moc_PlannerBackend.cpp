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
        "selectedDateChanged",
        "viewModeChanged",
        "onlyOpenChanged",
        "eventsChanged",
        "todayEventsChanged",
        "upcomingEventsChanged",
        "examEventsChanged",
        "commandsChanged",
        "searchQueryChanged",
        "toastRequested",
        "message",
        "selectDateIso",
        "isoDate",
        "setViewMode",
        "mode",
        "setOnlyOpenQml",
        "value",
        "jumpToToday",
        "addQuickEntry",
        "QVariant",
        "text",
        "search",
        "QVariantList",
        "query",
        "dayEvents",
        "weekEvents",
        "weekStartIso",
        "listBuckets",
        "eventById",
        "QVariantMap",
        "id",
        "setEventDone",
        "done",
        "showToast",
        "darkTheme",
        "selectedDate",
        "viewMode",
        "ViewMode",
        "viewModeString",
        "onlyOpen",
        "events",
        "QAbstractListModel*",
        "today",
        "upcoming",
        "exams",
        "commands",
        "searchQuery",
        "Month",
        "Week",
        "List"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'darkThemeChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'selectedDateChanged'
        QtMocHelpers::SignalData<void()>(3, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'viewModeChanged'
        QtMocHelpers::SignalData<void()>(4, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'onlyOpenChanged'
        QtMocHelpers::SignalData<void()>(5, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'eventsChanged'
        QtMocHelpers::SignalData<void()>(6, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'todayEventsChanged'
        QtMocHelpers::SignalData<void()>(7, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'upcomingEventsChanged'
        QtMocHelpers::SignalData<void()>(8, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'examEventsChanged'
        QtMocHelpers::SignalData<void()>(9, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'commandsChanged'
        QtMocHelpers::SignalData<void()>(10, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'searchQueryChanged'
        QtMocHelpers::SignalData<void()>(11, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'toastRequested'
        QtMocHelpers::SignalData<void(const QString &)>(12, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 13 },
        }}),
        // Method 'selectDateIso'
        QtMocHelpers::MethodData<void(const QString &)>(14, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 15 },
        }}),
        // Method 'setViewMode'
        QtMocHelpers::MethodData<void(const QString &)>(16, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 17 },
        }}),
        // Method 'setOnlyOpenQml'
        QtMocHelpers::MethodData<void(bool)>(18, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 19 },
        }}),
        // Method 'jumpToToday'
        QtMocHelpers::MethodData<void()>(20, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'addQuickEntry'
        QtMocHelpers::MethodData<QVariant(const QString &)>(21, 2, QMC::AccessPublic, 0x80000000 | 22, {{
            { QMetaType::QString, 23 },
        }}),
        // Method 'search'
        QtMocHelpers::MethodData<QVariantList(const QString &) const>(24, 2, QMC::AccessPublic, 0x80000000 | 25, {{
            { QMetaType::QString, 26 },
        }}),
        // Method 'dayEvents'
        QtMocHelpers::MethodData<QVariantList(const QString &) const>(27, 2, QMC::AccessPublic, 0x80000000 | 25, {{
            { QMetaType::QString, 15 },
        }}),
        // Method 'weekEvents'
        QtMocHelpers::MethodData<QVariantList(const QString &) const>(28, 2, QMC::AccessPublic, 0x80000000 | 25, {{
            { QMetaType::QString, 29 },
        }}),
        // Method 'listBuckets'
        QtMocHelpers::MethodData<QVariantList() const>(30, 2, QMC::AccessPublic, 0x80000000 | 25),
        // Method 'eventById'
        QtMocHelpers::MethodData<QVariantMap(const QString &) const>(31, 2, QMC::AccessPublic, 0x80000000 | 32, {{
            { QMetaType::QString, 33 },
        }}),
        // Method 'setEventDone'
        QtMocHelpers::MethodData<void(const QString &, bool)>(34, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 33 }, { QMetaType::Bool, 35 },
        }}),
        // Method 'showToast'
        QtMocHelpers::MethodData<void(const QString &)>(36, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 13 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'darkTheme'
        QtMocHelpers::PropertyData<bool>(37, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 0),
        // property 'selectedDate'
        QtMocHelpers::PropertyData<QString>(38, QMetaType::QString, QMC::DefaultPropertyFlags, 1),
        // property 'viewMode'
        QtMocHelpers::PropertyData<enum ViewMode>(39, 0x80000000 | 40, QMC::DefaultPropertyFlags | QMC::Writable | QMC::EnumOrFlag | QMC::StdCppSet, 2),
        // property 'viewModeString'
        QtMocHelpers::PropertyData<QString>(41, QMetaType::QString, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 2),
        // property 'onlyOpen'
        QtMocHelpers::PropertyData<bool>(42, QMetaType::Bool, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 3),
        // property 'events'
        QtMocHelpers::PropertyData<QAbstractListModel*>(43, 0x80000000 | 44, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 4),
        // property 'today'
        QtMocHelpers::PropertyData<QVariantList>(45, 0x80000000 | 25, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 5),
        // property 'upcoming'
        QtMocHelpers::PropertyData<QVariantList>(46, 0x80000000 | 25, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 6),
        // property 'exams'
        QtMocHelpers::PropertyData<QVariantList>(47, 0x80000000 | 25, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 7),
        // property 'commands'
        QtMocHelpers::PropertyData<QVariantList>(48, 0x80000000 | 25, QMC::DefaultPropertyFlags | QMC::EnumOrFlag, 8),
        // property 'searchQuery'
        QtMocHelpers::PropertyData<QString>(49, QMetaType::QString, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 9),
    };
    QtMocHelpers::UintData qt_enums {
        // enum 'ViewMode'
        QtMocHelpers::EnumData<enum ViewMode>(40, 40, QMC::EnumIsScoped).add({
            {   50, ViewMode::Month },
            {   51, ViewMode::Week },
            {   52, ViewMode::List },
        }),
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
        case 1: _t->selectedDateChanged(); break;
        case 2: _t->viewModeChanged(); break;
        case 3: _t->onlyOpenChanged(); break;
        case 4: _t->eventsChanged(); break;
        case 5: _t->todayEventsChanged(); break;
        case 6: _t->upcomingEventsChanged(); break;
        case 7: _t->examEventsChanged(); break;
        case 8: _t->commandsChanged(); break;
        case 9: _t->searchQueryChanged(); break;
        case 10: _t->toastRequested((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 11: _t->selectDateIso((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 12: _t->setViewMode((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 13: _t->setOnlyOpenQml((*reinterpret_cast< std::add_pointer_t<bool>>(_a[1]))); break;
        case 14: _t->jumpToToday(); break;
        case 15: { QVariant _r = _t->addQuickEntry((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariant*>(_a[0]) = std::move(_r); }  break;
        case 16: { QVariantList _r = _t->search((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 17: { QVariantList _r = _t->dayEvents((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 18: { QVariantList _r = _t->weekEvents((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 19: { QVariantList _r = _t->listBuckets();
            if (_a[0]) *reinterpret_cast< QVariantList*>(_a[0]) = std::move(_r); }  break;
        case 20: { QVariantMap _r = _t->eventById((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QVariantMap*>(_a[0]) = std::move(_r); }  break;
        case 21: _t->setEventDone((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<bool>>(_a[2]))); break;
        case 22: _t->showToast((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::darkThemeChanged, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::selectedDateChanged, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::viewModeChanged, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::onlyOpenChanged, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::eventsChanged, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::todayEventsChanged, 5))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::upcomingEventsChanged, 6))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::examEventsChanged, 7))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::commandsChanged, 8))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)()>(_a, &PlannerBackend::searchQueryChanged, 9))
            return;
        if (QtMocHelpers::indexOfMethod<void (PlannerBackend::*)(const QString & )>(_a, &PlannerBackend::toastRequested, 10))
            return;
    }
    if (_c == QMetaObject::RegisterPropertyMetaType) {
        switch (_id) {
        default: *reinterpret_cast<int*>(_a[0]) = -1; break;
        case 5:
            *reinterpret_cast<int*>(_a[0]) = qRegisterMetaType< QAbstractListModel* >(); break;
        }
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<bool*>(_v) = _t->darkTheme(); break;
        case 1: *reinterpret_cast<QString*>(_v) = _t->selectedDateIso(); break;
        case 2: *reinterpret_cast<enum ViewMode*>(_v) = _t->viewMode(); break;
        case 3: *reinterpret_cast<QString*>(_v) = _t->viewModeString(); break;
        case 4: *reinterpret_cast<bool*>(_v) = _t->onlyOpen(); break;
        case 5: *reinterpret_cast<QAbstractListModel**>(_v) = _t->eventsModel(); break;
        case 6: *reinterpret_cast<QVariantList*>(_v) = _t->todayEvents(); break;
        case 7: *reinterpret_cast<QVariantList*>(_v) = _t->upcomingEvents(); break;
        case 8: *reinterpret_cast<QVariantList*>(_v) = _t->examEvents(); break;
        case 9: *reinterpret_cast<QVariantList*>(_v) = _t->commands(); break;
        case 10: *reinterpret_cast<QString*>(_v) = _t->searchQuery(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setDarkTheme(*reinterpret_cast<bool*>(_v)); break;
        case 2: _t->setViewMode(*reinterpret_cast<enum ViewMode*>(_v)); break;
        case 3: _t->setViewModeString(*reinterpret_cast<QString*>(_v)); break;
        case 4: _t->setOnlyOpen(*reinterpret_cast<bool*>(_v)); break;
        case 10: _t->setSearchQuery(*reinterpret_cast<QString*>(_v)); break;
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
void PlannerBackend::selectedDateChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void PlannerBackend::viewModeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void PlannerBackend::onlyOpenChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void PlannerBackend::eventsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void PlannerBackend::todayEventsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 5, nullptr);
}

// SIGNAL 6
void PlannerBackend::upcomingEventsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 6, nullptr);
}

// SIGNAL 7
void PlannerBackend::examEventsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 7, nullptr);
}

// SIGNAL 8
void PlannerBackend::commandsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 8, nullptr);
}

// SIGNAL 9
void PlannerBackend::searchQueryChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 9, nullptr);
}

// SIGNAL 10
void PlannerBackend::toastRequested(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 10, nullptr, _t1);
}
QT_WARNING_POP
