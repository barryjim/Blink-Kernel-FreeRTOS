# Define minimal required version of CMake.
cmake_minimum_required(VERSION "3.25")

# Project definition
project(
	blink_kernel_freertos_s3
	VERSION 1.0
	LANGUAGES C CXX ASM
)

# Include the definition of the slc_blink_kernel_freertos_s3 target,
# which contains the content of the SLC project
include(blink_kernel_freertos_s3.cmake)

add_executable(blink_kernel_freertos_s3
    # Add additional sources here
)

target_include_directories(blink_kernel_freertos_s3 PUBLIC
    # Add additional include paths here
)

target_compile_definitions(blink_kernel_freertos_s3 PUBLIC
    # Add additional macros here
)

target_compile_options(blink_kernel_freertos_s3 PUBLIC
    # Set additional compiler flags here
)

target_link_options(blink_kernel_freertos_s3 PUBLIC
    # Set additional linker flags here
)

# Link with the content defined in the SLC project
target_link_libraries(blink_kernel_freertos_s3 PRIVATE
    slc
)

# Include managed project content if available
include(blink_kernel_freertos_s3_project.cmake OPTIONAL RESULT_VARIABLE managed_project)
if(managed_project)
    message(STATUS "Using managed project content from ${managed_project}")
endif()

# Force the gcc linker command
set_target_properties(blink_kernel_freertos_s3 PROPERTIES LINKER_LANGUAGE C)

# Create .bin, .hex and .s37 artifacts after building the project
add_custom_command(TARGET blink_kernel_freertos_s3
    POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} ${OBJCOPY_SREC_CMD} "$<TARGET_FILE:blink_kernel_freertos_s3>" "$<TARGET_FILE_DIR:blink_kernel_freertos_s3>/$<TARGET_FILE_BASE_NAME:blink_kernel_freertos_s3>.s37"
    COMMAND ${CMAKE_OBJCOPY} ${OBJCOPY_IHEX_CMD} "$<TARGET_FILE:blink_kernel_freertos_s3>" "$<TARGET_FILE_DIR:blink_kernel_freertos_s3>/$<TARGET_FILE_BASE_NAME:blink_kernel_freertos_s3>.hex"
    COMMAND ${CMAKE_OBJCOPY} ${OBJCOPY_BIN_CMD}  "$<TARGET_FILE:blink_kernel_freertos_s3>" "$<TARGET_FILE_DIR:blink_kernel_freertos_s3>/$<TARGET_FILE_BASE_NAME:blink_kernel_freertos_s3>.bin" 
)

# Run post-build pipeline to perform additional post-processing
if(post_build_command)
add_custom_command(TARGET blink_kernel_freertos_s3
    POST_BUILD
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/..
    COMMAND ${post_build_command}
)
endif()