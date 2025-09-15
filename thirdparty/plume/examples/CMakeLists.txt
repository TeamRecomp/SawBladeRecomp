set(CMAKE_CXX_STANDARD 17)

# Enable SDL Vulkan integration
set(SDL_VULKAN_ENABLED ON CACHE BOOL "Enable SDL Vulkan integration" FORCE)

# Find SDL2 (required for examples)
find_package(SDL2 REQUIRED)

# Source files
set(SOURCES
    main.cpp
)

# Create executable
add_executable(plume_example ${SOURCES})

# Link libraries and include directories
target_link_libraries(plume_example PRIVATE plume ${SDL2_LIBRARIES})

# Platform-specific libraries
if(APPLE)
    target_link_libraries(plume_example PRIVATE "-framework Metal -framework QuartzCore -framework CoreGraphics -framework Foundation -framework IOKit")

    set_target_properties(plume_example PROPERTIES
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "-"
        XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS ${CMAKE_CURRENT_SOURCE_DIR}/plume.entitlements
    )
elseif(WIN32)
    target_link_libraries(plume_example PRIVATE d3d12 dxgi)

    # Dependencies that must be next to the DLL if on Windows
    if(EXISTS "${SDL2_BINDIR}/SDL2.dll")
        configure_file("${SDL2_BINDIR}/SDL2.dll" "${CMAKE_BINARY_DIR}/bin/SDL2.dll" COPYONLY)
    endif()
elseif(CMAKE_SYSTEM_NAME MATCHES "Linux")
    find_package(X11 REQUIRED)
    target_include_directories(plume_example PUBLIC ${X11_INCLUDE_DIR} ${X11_Xrandr_INCLUDE_PATH})
    target_link_libraries(plume_example PRIVATE ${X11_LIBRARIES} ${X11_Xrandr_LIB})
endif()

# Include directories
target_include_directories(plume_example PRIVATE
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/examples
    ${SDL2_INCLUDE_DIRS}
    ${CMAKE_BINARY_DIR}  # Include build directory
    ${CMAKE_BINARY_DIR}/shaders  # Include shaders directory
)

# Add tools directory first (needed for shader compilation)
add_subdirectory(tools)

# Include custom ShaderCompilation module
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include(ShaderCompilation)

# Create shaders directory for the examples
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/shaders)

# Set output directory
set_target_properties(plume_example PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Compile shaders
if(APPLE)
    # Metal shaders
    compile_shader(plume_example "${CMAKE_CURRENT_SOURCE_DIR}/shaders/triangle.vert.metal" "vertex" "triangleVert" "VSMain")
    compile_shader(plume_example "${CMAKE_CURRENT_SOURCE_DIR}/shaders/triangle.frag.metal" "fragment" "triangleFrag" "PSMain")
endif()

# Compile HLSL shaders for Vulkan/SPIR-V
compile_shader(plume_example "${CMAKE_CURRENT_SOURCE_DIR}/shaders/triangle.vert.hlsl" "vertex" "triangleVert" "VSMain")
compile_shader(plume_example "${CMAKE_CURRENT_SOURCE_DIR}/shaders/triangle.frag.hlsl" "fragment" "triangleFrag" "PSMain")

# Set up a custom command to copy the shader files to the bin directory
add_custom_target(copy_shaders ALL
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/bin/shaders
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/shaders ${CMAKE_BINARY_DIR}/bin/shaders
    COMMENT "Copying shader files to bin directory"
)
