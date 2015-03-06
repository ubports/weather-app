file(GLOB UI_SETTINGS_QML_JS_FILES *.qml *.js)

add_custom_target(ubuntu-weather-app_ui_settings_QMlFiles ALL SOURCES ${UI_SETTINGS_QML_JS_FILES})

install(FILES ${UI_SETTINGS_QML_JS_FILES} DESTINATION ${UBUNTU-WEATHER_APP_DIR}/ui/settings)
