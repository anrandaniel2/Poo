#!/bin/bash
# NexusClient Build Script
# Requires: Android NDK r25+, CMake 3.21+, Ninja

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     NexusClient Build System v1.0    ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"

# Check prerequisites
check_prereq() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}[ERROR] $1 not found. Please install it.${NC}"
        exit 1
    fi
}

check_prereq cmake
check_prereq ninja

# Check NDK
if [ -z "${ANDROID_NDK_HOME:-}" ]; then
    echo -e "${YELLOW}[WARN] ANDROID_NDK_HOME not set.${NC}"
    
    # Try common paths
    for ndk_path in "$HOME/Android/Sdk/ndk"/* "/opt/android-ndk"*; do
        if [ -d "$ndk_path" ]; then
            export ANDROID_NDK_HOME="$ndk_path"
            echo -e "${GREEN}[INFO] Found NDK at: $ndk_path${NC}"
            break
        fi
    done
    
    if [ -z "${ANDROID_NDK_HOME:-}" ]; then
        echo -e "${RED}[ERROR] Android NDK not found. Set ANDROID_NDK_HOME.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}[INFO] Using NDK: ${ANDROID_NDK_HOME}${NC}"

# Build directory
BUILD_DIR="build/arm64"
mkdir -p "$BUILD_DIR"

# Configure
echo -e "${CYAN}[BUILD] Configuring CMake...${NC}"
cmake -B "$BUILD_DIR" \
    -G Ninja \
    -DCMAKE_TOOLCHAIN_FILE="cmake/android-arm64.toolchain.cmake" \
    -DCMAKE_BUILD_TYPE=Release \
    -DANDROID_ABI=arm64-v8a \
    -DANDROID_PLATFORM=android-26

# Build
echo -e "${CYAN}[BUILD] Compiling...${NC}"
cmake --build "$BUILD_DIR" --config Release -j$(nproc)

# Output
SO_FILE="$BUILD_DIR/lib/arm64-v8a/libclient.so"
if [ -f "$SO_FILE" ]; then
    echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║       Build Successful!              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
    echo -e "${GREEN}Output: $SO_FILE${NC}"
    echo -e "${GREEN}Size: $(du -h "$SO_FILE" | cut -f1)${NC}"
    
    # Copy to output
    mkdir -p output
    cp "$SO_FILE" output/libclient.so
    echo -e "${GREEN}Copied to: output/libclient.so${NC}"
else
    echo -e "${RED}[ERROR] Build failed - .so not found${NC}"
    exit 1
fi
