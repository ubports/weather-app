file(GLOB COMPONENTS_QML_JS_FILES *.qml *.js)
add_custom_target(ubuntu-weather-app_components_QMlFiles ALL SOURCES ${COMPONENTS_QML_JS_FILES})
