file(GLOB IMAGE_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.png *.svg)

add_custom_target(ubuntu-weather-app_graphics_IMAGEFiles ALL SOURCES ${IMAGE_FILES})

install(FILES ${IMAGE_FILES} DESTINATION ${UBUNTU-WEATHER_APP_DIR}/graphics)
