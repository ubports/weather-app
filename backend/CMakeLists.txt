include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
)

set(
    timeZone_SRCS
    TimeZone/timezone.cpp
    TimeZone/timezone_plugin.cpp
)

#add_library(TimeZoneBackend MODULE
#    ${timeZone_SRCS}
#)
#set_target_properties(TimeZoneBackend PROPERTIES
#         LIBRARY_OUTPUT_DIRECTORY TimeZone)

#qt5_use_modules(TimeZoneBackend Gui Qml Quick)

# Copy qmldir file to build dir for running in QtCreator
#add_custom_target(TimeZoneBackend-qmldir ALL
#    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/TimeZone/qmldir ${CMAKE_CURRENT_BINARY_DIR}/TimeZone
#    DEPENDS ${QML_JS_FILES}
#)

# Install plugin file
#install(TARGETS TimeZoneBackend DESTINATION ${QT_IMPORTS_DIR}/qt5/qml/UbuntuWeather/TimeZone/)
#install(FILES TimeZone/qmldir DESTINATION ${QT_IMPORTS_DIR}/qt5/qml/UbuntuWeather/TimeZone/)
