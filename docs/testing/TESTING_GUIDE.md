# Testing Guide

## Overview

Noah Planner includes a comprehensive test suite to ensure code quality and catch bugs early.

## Running Tests

### Linux
```bash
cd build
ctest --output-on-failure
```

### Windows
```cmd
cd build
ctest --output-on-failure -C Release
```

## Test Suites

- **priority_rules_test**: Priority calculation logic
- **planner_service_test**: Core planner operations
- **spaced_repetition_test**: Learning algorithm tests
- **quick_add_parser_test**: Natural language parsing

See individual test files in `tests/` for detailed coverage.
