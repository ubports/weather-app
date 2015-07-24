# make the database files visible on qtcreator
file(GLOB PYTHON_EMULATOR_TEST_DATABASE_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.ini)

add_custom_target(ubuntu-weather-app_PYTHONEMULATORTestDatabaseFiles ALL SOURCES ${PYTHON_EMULATOR_TEST_DATABASE_FILES})
