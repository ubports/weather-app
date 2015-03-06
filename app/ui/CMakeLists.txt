add_subdirectory(settings)

file(GLOB UI_QML_JS_FILES *.qml *.js)

add_custom_target(ubuntu-weather-app_ui_QMlFiles ALL SOURCES ${UI_QML_JS_FILES})

install(FILES ${UI_QML_JS_FILES} DESTINATION ${UBUNTU-WEATHER_APP_DIR}/ui)
