project(com.ubuntu.weather)
cmake_minimum_required(VERSION 2.8.9)

find_program(INTLTOOL_MERGE intltool-merge)
if(NOT INTLTOOL_MERGE)
    message(FATAL_ERROR "Could not find intltool-merge, please install the intltool package")
endif()
find_program(INTLTOOL_EXTRACT intltool-extract)
if(NOT INTLTOOL_EXTRACT)
    message(FATAL_ERROR "Could not find intltool-extract, please install the intltool package")
endif()

set (UBUNTU_MANIFEST_PATH "manifest.json.in" CACHE INTERNAL "Relative path to the manifest file")
set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fno-permissive -pedantic -Wall -Wextra")

find_package(Qt5Core REQUIRED)
find_package(Qt5Qml REQUIRED)
find_package(Qt5Quick REQUIRED)

# Automatically create moc files
set(CMAKE_AUTOMOC ON)

option(INSTALL_TESTS "Install the tests on make install" on)
option(CLICK_MODE "Build as a click package" on)

# Tests
enable_testing()

# Standard install paths
include(GNUInstallDirs)

set(APP_NAME weather)
set(APP_HARDCODE ubuntu-weather-app)
set(MAIN_QML ${APP_HARDCODE}.qml)
set(DESKTOP_FILE "${APP_HARDCODE}.desktop")
set(ICON weather-app@30.png)
set(AUTOPILOT_DIR ubuntu_weather_app)

# Set install paths
if(CLICK_MODE)
  set(CMAKE_INSTALL_PREFIX "/")
  set(UBUNTU-WEATHER_APP_DIR "${CMAKE_INSTALL_DATADIR}/qml")

  set(QT_IMPORTS_DIR "${CMAKE_INSTALL_LIBDIR}")
  set(EXEC "qmlscene $@ ${UBUNTU-WEATHER_APP_DIR}/${MAIN_QML}")
  set(MODULE_PATH ${QT_IMPORTS_DIR})
  if(NOT BZR_REVNO)
    execute_process(
      COMMAND bzr revno
              OUTPUT_VARIABLE BZR_REVNO
              WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
              OUTPUT_STRIP_TRAILING_WHITESPACE
      )
  endif(NOT BZR_REVNO)
  if(NOT BZR_SOURCE)
    set(BZR_SOURCE "lp:${APP_HARDCODE}/reboot")
    message("-- Setting BZR_SOURCE to ${BZR_SOURCE}")
  endif(NOT BZR_SOURCE)
else(CLICK_MODE)
  set(UBUNTU-WEATHER_APP_DIR "${CMAKE_INSTALL_DATADIR}/ubuntu-weather-app")
  execute_process(
    COMMAND qmake -query QT_INSTALL_QML
            OUTPUT_VARIABLE QT_IMPORTS_DIR
            OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  set(MODULE_PATH ${QT_IMPORTS_DIR}/WeatherApp)
endif(CLICK_MODE)

if(${CLICK_MODE})
  message("-- Configuring manifest.json")

  execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_ARCH
    OUTPUT_VARIABLE CLICK_ARCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  configure_file(${UBUNTU_MANIFEST_PATH} ${CMAKE_CURRENT_BINARY_DIR}/manifest.json)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/manifest.json DESTINATION ${CMAKE_INSTALL_PREFIX})
  install(FILES "${APP_HARDCODE}.apparmor" DESTINATION ${CMAKE_INSTALL_PREFIX})
else(CLICK_MODE)
  set(EXEC "qmlscene $@ -I ${MODULE_PATH}  ${CMAKE_INSTALL_PREFIX}/${UBUNTU-WEATHER_APP_DIR}/${MAIN_QML}")
endif()


file(GLOB_RECURSE I18N_SRC_FILES
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/po
    *.qml *.js)
list(APPEND I18N_SRC_FILES ${DESKTOP_FILE}.in.in.h)
list(SORT I18N_SRC_FILES)

configure_file(${DESKTOP_FILE}.in.in ${DESKTOP_FILE}.in)

add_custom_target(${DESKTOP_FILE} ALL
    COMMENT "Merging translations into ${DESKTOP_FILE}..."
    COMMAND LC_ALL=C ${INTLTOOL_MERGE} -d -u ${CMAKE_SOURCE_DIR}/po ${DESKTOP_FILE}.in ${DESKTOP_FILE}
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE}
        DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)

add_subdirectory(app)
add_subdirectory(backend)
add_subdirectory(po)
add_subdirectory(tests)

# TODO: Add custom target for autopilot and run.

