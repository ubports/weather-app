add_subdirectory(HeadState)
add_subdirectory(ListItemActions)

file(GLOB COMPONENTS_QML_JS_FILES *.qml *.js)

add_custom_target(ubuntu-weather-app_components_QMlFiles ALL SOURCES ${COMPONENTS_QML_JS_FILES})

install(FILES ${COMPONENTS_QML_JS_FILES} DESTINATION ${UBUNTU-WEATHER_APP_DIR}/components)
