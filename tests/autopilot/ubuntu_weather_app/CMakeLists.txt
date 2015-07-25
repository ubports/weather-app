add_subdirectory(databases)
add_subdirectory(files)
add_subdirectory(tests)

# make the emulator files visible on qtcreator
file(GLOB PYTHON_EMULATOR_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.py)

add_custom_target(ubuntu-weather-app_PYTHONEMULATORFiles ALL SOURCES ${PYTHON_EMULATOR_FILES})
