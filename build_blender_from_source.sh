#!/bin/bash
# SPDX-FileCopyrightText: 2026 Blender Authors
# SPDX-License-Identifier: GPL-2.0-or-later

set -e

LOG="/Users/lakshaynagpal/Developer/Projects/blender_compile.log"
echo "=== Starting Full Blender C++ Compilation Pipeline ===" | tee "$LOG"
date | tee -a "$LOG"

echo "[1/4] Pulling precompiled binary dependencies via Git LFS (1.1 GB)..." | tee -a "$LOG"
cd /Users/lakshaynagpal/Developer/Projects/blender-main/lib/macos_arm64
git lfs install
git lfs pull 2>&1 | tee -a "$LOG"
git lfs checkout 2>&1 | tee -a "$LOG"

echo "[2/4] Configuring Ninja build with CMake..." | tee -a "$LOG"
cd /Users/lakshaynagpal/Developer/Projects/blender-main
cmake -S /Users/lakshaynagpal/Developer/Projects/blender-main -B /Users/lakshaynagpal/Developer/Projects/build_darwin -GNinja -DCMAKE_BUILD_TYPE=Release 2>&1 | tee -a "$LOG"

echo "[3/4] Compiling Blender with Ninja (AppleClang)..." | tee -a "$LOG"
ninja -C /Users/lakshaynagpal/Developer/Projects/build_darwin 2>&1 | tee -a "$LOG"

echo "[4/4] Installing Blender.app and packaging Source DMG..." | tee -a "$LOG"
ninja -C /Users/lakshaynagpal/Developer/Projects/build_darwin install 2>&1 | tee -a "$LOG"

# Package newly compiled app into DMG
rm -rf /tmp/blender_source_dmg_staging
mkdir -p /tmp/blender_source_dmg_staging
cp -R /Users/lakshaynagpal/Developer/Projects/build_darwin/bin/Blender.app /tmp/blender_source_dmg_staging/
ln -s /Applications /tmp/blender_source_dmg_staging/Applications
hdiutil create -volname "Blender 5.3 Alpha AI Native" -srcfolder /tmp/blender_source_dmg_staging -ov -format UDZO /Users/lakshaynagpal/Developer/Projects/Blender-5.3-Alpha-AI-Compiled.dmg 2>&1 | tee -a "$LOG"

echo "=== Full Blender Compilation Complete! DMG created at /Users/lakshaynagpal/Developer/Projects/Blender-5.3-Alpha-AI-Compiled.dmg ===" | tee -a "$LOG"
date | tee -a "$LOG"
