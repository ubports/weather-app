project(com.ubuntu.weather)
cmake_minimum_required(VERSION 2.8.9)
find_program(INTLTOOL_MERGE intltool-merge)
find_program(INTLTOOL_EXTRACT intltool-extract)

find_package(Qt5Core REQUIRED)
find_package(Qt5Qml REQUIRED)
find_package(Qt5Quick REQUIRED)
set(CMAKE_AUTOMOC ON)

# Standard install paths
include(GNUInstallDirs)

option(INSTALL_TESTS "Install the tests on make install" on)
option(CLICK_MODE "Installs to a contained location" on)

set(APP_NAME weather)
set(DESKTOP_FILE "${PROJECT_NAME}_${APP_NAME}.desktop")
set(APP_HARDCODE ubuntu-weather-app)
set(MAIN_QML ubuntu-weather-app.qml)
set(ICON_FILE weather-app@30.png)
set(AUTOPILOT_DIR ubuntu_weather_app)
set(UBUNTU_MANIFEST_PATH "click/manifest.json.in" CACHE INTERNAL "Relative path to the manifest file")

# components PATH
execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
set(QT_IMPORTS_DIR "lib/${ARCH_TRIPLET}")
execute_process(
  COMMAND dpkg-architecture -qDEB_HOST_ARCH
  OUTPUT_VARIABLE CLICK_ARCH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(CLICK_MODE)
    if(NOT DEFINED BZR_SOURCE)
        set(BZR_SOURCE "lp:${APP_HARDCODE}")
        message("-- Setting BZR_SOURCE to ${BZR_SOURCE}")
    endif(NOT DEFINED BZR_SOURCE)
    set(CMAKE_INSTALL_PREFIX /)
    set(CMAKE_INSTALL_BINDIR /)
    set(DATA_DIR /)
    set(ICON ${ICON_FILE})
    set(EXEC "qmlscene $@ ${MAIN_QML}")
    set(DESKTOP_DIR ${DATA_DIR})
else(CLICK_MODE)
    set(DATA_DIR ${CMAKE_INSTALL_DATADIR}/${APP_HARDCODE})
    set(EXEC ${APP_HARDCODE})
    set(ICON ${CMAKE_INSTALL_PREFIX}/${DATA_DIR}/${ICON_FILE})
    configure_file(${APP_HARDCODE}.in
        ${CMAKE_CURRENT_BINARY_DIR}/${APP_HARDCODE})
    install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/${APP_HARDCODE}
        DESTINATION ${CMAKE_INSTALL_BINDIR})
    set(DESKTOP_DIR ${CMAKE_INSTALL_DATADIR}/applications)
endif(CLICK_MODE)

file(GLOB_RECURSE I18N_SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/po
     components/*.qml components/*.js *.qml)
list(APPEND I18N_SRC_FILES ${DESKTOP_FILE}.in.in.h)
list(SORT I18N_SRC_FILES)
message("Found ${I18N_SRC_FILES}")

file(GLOB SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.qml *.js *.png *.js)
install(DIRECTORY components resources DESTINATION ${DATA_DIR})
install(FILES key.js DESTINATION ${DATA_DIR})
install(FILES ${MAIN_QML} ${ICON_FILE} DESTINATION ${DATA_DIR})

configure_file(${DESKTOP_FILE}.in.in ${DESKTOP_FILE}.in)

add_custom_target(${DESKTOP_FILE} ALL
  COMMENT "Merging translations into ${DESKTOP_FILE}"
  COMMAND LC_ALL=C ${INTLTOOL_MERGE} -d -u ${CMAKE_SOURCE_DIR}/po ${DESKTOP_FILE}.in ${DESKTOP_FILE} >/dev/null
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE}
    DESTINATION ${DESKTOP_DIR})

# Tests
enable_testing()

file(GLOB QML_JS_FILES *.qml *.js)
add_custom_target(ubuntu-weather-app_QMlFiles ALL SOURCES ${QML_JS_FILES})

add_subdirectory(click)
add_subdirectory(po)
add_subdirectory(app)
add_subdirectory(backend)

