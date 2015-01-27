file(GLOB DATA_QML_JS_FILES *.qml *.js)

add_custom_target(ubuntu-weather-app_data_QMlFiles ALL SOURCES ${DATA_QML_JS_FILES})

install(FILES ${DATA_QML_JS_FILES} DESTINATION ${UBUNTU-WEATHER_APP_DIR}/data)
