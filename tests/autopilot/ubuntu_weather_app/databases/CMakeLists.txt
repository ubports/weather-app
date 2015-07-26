# make the database files visible on qtcreator
file(GLOB PYTHON_TEST_DATABASE_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.ini *.conf)

add_custom_target(ubuntu-weather-app_PYTHONTestDatabaseFiles ALL SOURCES ${PYTHON_TEST_DATABASE_FILES})
