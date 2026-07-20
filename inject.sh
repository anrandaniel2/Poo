#!/bin/bash
# NexusClient Injection Script for LeviLauncher
# Usage: ./inject.sh [path-to-libclient.so]

set -euo pipefail

SO_FILE="${1:-output/libclient.so}"
PACKAGE="com.mojang.minecraftpe"
LEVI_DIR="/data/data/${PACKAGE}/files/levi/mods"

echo "╔══════════════════════════════════════╗"
echo "║   NexusClient Injector for Levi      ║"
echo "╚══════════════════════════════════════╝"

# Check ADB
if ! command -v adb &> /dev/null; then
    echo "[ERROR] ADB not found"
    exit 1
fi

# Check file
if [ ! -f "$SO_FILE" ]; then
    echo "[ERROR] $SO_FILE not found. Build first."
    exit 1
fi

# Push to device
echo "[*] Pushing libclient.so to device..."
adb push "$SO_FILE" "/sdcard/libclient.so"

# Move to LeviLauncher mods directory  
echo "[*] Installing to LeviLauncher..."
adb shell "su -c 'mkdir -p $LEVI_DIR'"
adb shell "su -c 'cp /sdcard/libclient.so $LEVI_DIR/libclient.so'"
adb shell "su -c 'chmod 755 $LEVI_DIR/libclient.so'"

echo "[*] Restarting Minecraft..."
adb shell "am force-stop $PACKAGE"
sleep 1
adb shell "am start -n $PACKAGE/com.mojang.minecraftpe.MainActivity"

echo "[✓] Injection complete. Launch Minecraft via LeviLauncher."
echo "[✓] Open menu with Right Shift or triple-tap screen."
