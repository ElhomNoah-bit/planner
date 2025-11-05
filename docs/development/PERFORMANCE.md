# Performance Optimization Guide

## Overview

This document describes performance optimizations implemented in Noah Planner and best practices for maintaining performance.

## Startup Optimization

### Current Optimizations

1. **Lazy Loading**: Data is loaded only when needed
   - Event repository initializes on first access
   - Review data loads on demand

2. **Efficient Data Structures**:
   - Use of `QVector` for sequential data
   - `QHash` for quick lookups
   - Proper use of `reserve()` before bulk operations

3. **Smart Pointer Usage**:
   - `std::unique_ptr` for automatic memory management
   - Avoids manual `new`/`delete` and potential leaks

## Memory Management

### Best Practices

1. **Use Qt Parent-Child Ownership**: Let Qt manage object lifetimes where possible
2. **Use Smart Pointers**: Prefer `std::unique_ptr` and `std::shared_ptr` for C++ objects
3. **Avoid Unnecessary Copies**: Use const references for function parameters
4. **Reserve Capacity**: Pre-allocate containers when size is known

Example:
```cpp
QVector<Task> tasks;
tasks.reserve(expectedSize);  // Avoids multiple reallocations
```

## File I/O Optimization

### Current Implementations

1. **Error Handling**: All file operations check for errors and log warnings
2. **Efficient JSON Parsing**: Read entire file at once, parse in memory
3. **Write Verification**: Check bytes written match expected size

### Recommendations

- Use SQLite for large datasets (already implemented in EventRepository)
- Batch operations to reduce I/O calls
- Consider caching frequently accessed data

## Algorithm Optimization

### Task Generation

The `generateDay()` function has been optimized:
- **Division by Zero Protection**: Guards against `maxSlots - placed` becoming zero
- **Early Exit**: Returns immediately if capacity is zero or during breaks
- **Efficient Sorting**: Uses `std::sort` with lambda comparator

### Priority Calculation

Optimized using inline functions:
- No virtual dispatch overhead
- Minimal branching
- Clear, maintainable logic

## UI Performance

### Signal Management

- Batch signal emissions where possible
- Use `blockSignals()` during bulk updates
- Avoid emitting signals in tight loops

### QML Best Practices

1. **Minimize Property Bindings**: Complex bindings can cause performance issues
2. **Use Loaders**: Defer loading of non-visible components
3. **Optimize Delegates**: Keep ListView/GridView delegates simple
4. **Profile Performance**: Use Qt's QML Profiler to identify bottlenecks

## Testing Performance

### Benchmarking

Create benchmarks for critical operations:
```cpp
QElapsedTimer timer;
timer.start();
// Operation to benchmark
qint64 elapsed = timer.elapsed();
qDebug() << "Operation took" << elapsed << "ms";
```

### Memory Profiling

Use Valgrind on Linux or similar tools:
```bash
valgrind --tool=memcheck --leak-check=full ./noah_planner
```

## Future Optimizations

1. **Async Data Loading**: Load data in background threads
2. **Incremental Updates**: Update only changed items, not entire lists
3. **Data Pagination**: Load events in chunks for large date ranges
4. **Caching Strategy**: Cache computed results that don't change often
5. **Database Indexing**: Add more indexes for frequently queried fields

## Measuring Impact

Before and after optimization:
1. Measure startup time
2. Monitor memory usage
3. Profile critical operations
4. Run test suite for correctness

## Performance Checklist

- [ ] No memory leaks (use smart pointers, Qt ownership)
- [ ] No division by zero
- [ ] Input validation for all user/file data
- [ ] Proper error handling
- [ ] Efficient data structures
- [ ] Minimal unnecessary copies
- [ ] Tests pass
- [ ] No performance regressions
