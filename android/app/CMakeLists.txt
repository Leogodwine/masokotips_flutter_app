cmake_minimum_required(VERSION 3.22.1)

project("masokotips")

# Set the C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Support for 16 KB memory page sizes (required for Android 15+)
set(CMAKE_ANDROID_PAGE_SIZE_AGNOSTIC ON)

# Create the main library
add_library(${PROJECT_NAME} SHARED
    "src/main/cpp/main.cpp"
)

# Link libraries
target_link_libraries(${PROJECT_NAME}
    android
    log
)
