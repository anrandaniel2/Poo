# NexusClient — Minecraft Bedrock Edition Client

## Overview
A C++20 client for Minecraft Bedrock Edition targeting Android ARM64 via LeviLauncher.

## Prerequisites
- Android NDK r25+ (r26b recommended)
- CMake 3.21+
- Ninja build system

## Build Instructions

```bash
# Set NDK path
export ANDROID_NDK_HOME=/path/to/android-ndk-r26b

# Build
chmod +x scripts/build.sh
./scripts/build.sh
```

## Output
The compiled `libclient.so` will be in `output/`.

## Installation
1. Copy `libclient.so` to your device
2. Place in LeviLauncher's mod directory
3. Launch Minecraft through LeviLauncher
4. Triple-tap screen to open menu

## Project Structure
- `/src/core` — Hooks, memory scanner, event bus, obfuscation
- `/src/modules` — All module implementations
- `/src/sdk` — Bedrock class definitions
- `/src/gui` — ClickGUI and HUD rendering
- `/src/config` — JSON config serialization
- `/src/imgui` — ImGui source (add from official repo)
- `/cmake` — NDK toolchain files
- `/scripts` — Build and injection scripts

## License
Educational purposes only.
