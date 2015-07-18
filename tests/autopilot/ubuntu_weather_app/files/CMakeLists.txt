# make the emulator files visible on qtcreator
file(GLOB PYTHON_EMULATOR_TEST_RESOURCE_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.json)

add_custom_target(ubuntu-weather-app_PYTHONEMULATORTestResourceFiles ALL SOURCES ${PYTHON_EMULATOR_TEST_RESOURCE_FILES})
