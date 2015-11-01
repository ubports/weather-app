if(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")
  file(GLOB QML_JS_FILES *.qml *.js)
  add_custom_target(ubuntu-weather-app_QMlFiles ALL SOURCES ${QML_JS_FILES})
endif(NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_CURRENT_BINARY_DIR}")


add_subdirectory(components)
add_subdirectory(data)
add_subdirectory(graphics)
add_subdirectory(ui)

