file(GLOB LISTITEMACTIONS_QML_JS_FILES *.qml *.js)

add_custom_target(ubuntu-weather-app_listitemactions_QMlFiles ALL SOURCES ${LISTITEMACTIONS_QML_JS_FILES})

install(FILES ${LISTITEMACTIONS_QML_JS_FILES} DESTINATION ${UBUNTU-WEATHER_APP_DIR}/components/ListItemActions)
