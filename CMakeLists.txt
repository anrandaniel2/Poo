cmake_minimum_required(VERSION 3.21)
project(NexusClient VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Android NDK Toolchain
if(NOT DEFINED ANDROID_ABI)
    set(ANDROID_ABI "arm64-v8a")
endif()
if(NOT DEFINED ANDROID_PLATFORM)
    set(ANDROID_PLATFORM android-26)
endif()

# Optimization flags
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -flto -ffunction-sections -fdata-sections -fvisibility=hidden -fvisibility-inlines-hidden")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-Wl,--gc-sections -Wl,--strip-all -s -flto")
set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")

# ARM64 specific optimizations
if(ANDROID_ABI STREQUAL "arm64-v8a")
    add_compile_options(-march=armv8-a+crypto -mtune=cortex-a76)
endif()

# ImGui sources
set(IMGUI_DIR ${CMAKE_SOURCE_DIR}/src/imgui)
set(IMGUI_SOURCES
    ${IMGUI_DIR}/imgui.cpp
    ${IMGUI_DIR}/imgui_demo.cpp
    ${IMGUI_DIR}/imgui_draw.cpp
    ${IMGUI_DIR}/imgui_tables.cpp
    ${IMGUI_DIR}/imgui_widgets.cpp
    ${IMGUI_DIR}/backends/imgui_impl_opengl3.cpp
    ${IMGUI_DIR}/backends/imgui_impl_android.cpp
)

# Dobby hooking library
add_subdirectory(${CMAKE_SOURCE_DIR}/external/dobby)

# JSON library (nlohmann)
include(FetchContent)
FetchContent_Declare(json
    GIT_REPOSITORY https://github.com/nlohmann/json.git
    GIT_TAG v3.11.3
)
FetchContent_MakeAvailable(json)

# Collect all source files
file(GLOB_RECURSE CORE_SOURCES "src/core/*.cpp")
file(GLOB_RECURSE MODULE_SOURCES "src/modules/*.cpp")
file(GLOB_RECURSE SDK_SOURCES "src/sdk/*.cpp")
file(GLOB_RECURSE GUI_SOURCES "src/gui/*.cpp")
file(GLOB_RECURSE CONFIG_SOURCES "src/config/*.cpp")

# Main shared library target
add_library(client SHARED
    src/main.cpp
    ${CORE_SOURCES}
    ${MODULE_SOURCES}
    ${SDK_SOURCES}
    ${GUI_SOURCES}
    ${CONFIG_SOURCES}
    ${IMGUI_SOURCES}
)

target_include_directories(client PRIVATE
    ${CMAKE_SOURCE_DIR}/src
    ${IMGUI_DIR}
    ${IMGUI_DIR}/backends
    ${CMAKE_SOURCE_DIR}/external/dobby/include
)

target_link_libraries(client PRIVATE
    dobby
    nlohmann_json::nlohmann_json
    GLESv3
    EGL
    android
    log
    z
)

# Set output name
set_target_properties(client PROPERTIES
    OUTPUT_NAME "client"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/${ANDROID_ABI}"
    PREFIX "lib"
)

# Post-build: verify .so
add_custom_command(TARGET client POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "Built libclient.so successfully for ${ANDROID_ABI}"
    COMMAND ls -la $<TARGET_FILE:client>
)
