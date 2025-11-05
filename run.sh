#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# Dependencies (Fedora):
#   sudo dnf install -y qt6-qtbase-devel qt6-qtdeclarative-devel cmake gcc-c++

build_dir="build"
mkdir -p "$build_dir"
cmake -S . -B "$build_dir" -DCMAKE_BUILD_TYPE=Release
cmake --build "$build_dir" --parallel

echo "Starting Noah Planner v2.0 ..."
"./$build_dir/noah_planner"
