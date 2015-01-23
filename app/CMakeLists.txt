file(GLOB COMPONENTS_QML_JS_FILES *.qml *.js)
add_custom_target(ubuntu-weather-app_app_QMlFiles ALL SOURCES ${COMPONENTS_QML_JS_FILES})
add_subdirectory(components)
add_subdirectory(tests)
