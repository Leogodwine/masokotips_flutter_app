cmake_minimum_required(VERSION 3.22.1)

project("masokotips")

# Set the C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Support for 16 KB memory page sizes (required for Android 15+)
set(CMAKE_ANDROID_PAGE_SIZE_AGNOSTIC ON)

# Enable page size agnostic builds
set(CMAKE_ANDROID_PAGE_SIZE_AGNOSTIC ON)

# Add the Flutter engine
add_library(flutter SHARED IMPORTED)
set_target_properties(flutter PROPERTIES
    IMPORTED_LOCATION ${FLUTTER_ENGINE_LIBRARY}
    INTERFACE_INCLUDE_DIRECTORIES ${FLUTTER_ENGINE_INCLUDE_DIR}
)

# Add the Flutter plugin libraries
add_library(flutter_plugin_registrant SHARED IMPORTED)
set_target_properties(flutter_plugin_registrant PROPERTIES
    IMPORTED_LOCATION ${FLUTTER_PLUGIN_REGISTRANT_LIBRARY}
)

# Create the main library
add_library(${PROJECT_NAME} SHARED
    "src/main/cpp/main.cpp"
)

# Link libraries
target_link_libraries(${PROJECT_NAME}
    flutter
    flutter_plugin_registrant
    android
    log
)

# Include directories
target_include_directories(${PROJECT_NAME} PRIVATE
    ${FLUTTER_ENGINE_INCLUDE_DIR}
)
