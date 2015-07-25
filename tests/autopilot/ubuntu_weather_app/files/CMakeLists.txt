# make the data files visible on qtcreator
file(GLOB PYTHON_TEST_RESOURCE_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.json)

add_custom_target(ubuntu-weather-app_PYTHONTestResourceFiles ALL SOURCES ${PYTHON_TEST_RESOURCE_FILES})
