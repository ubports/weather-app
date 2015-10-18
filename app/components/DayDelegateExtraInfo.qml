/*
 * Copyright (C) 2015 Canonical Ltd
 *
 * This file is part of Ubuntu Weather App
 *
 * Ubuntu Weather App is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Ubuntu Weather App is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.2


Column {
    id: extraInfoColumn
    anchors {
        centerIn: parent
    }
    objectName: "dayDelegateExtraInfo"
    spacing: units.gu(2)

    // Hack for autopilot otherwise DayDelegateExtraInfo appears as Column
    // due to bug 1341671 it is required that there is a property so that
    // qml doesn't optimise using the parent type
    property bool bug1341671workaround: true

    // FIXME: extended-infomation_* aren't actually on device

    // Overview text
    Label {
        id: conditionForecast
        color: UbuntuColors.coolGrey
        font.capitalization: Font.Capitalize
        fontSize: "x-large"
        horizontalAlignment: Text.AlignHCenter
        text: modelData.condition
        width: parent.width
        visible: text !== ""
    }

    ForecastDetailsDelegate {
        id: chanceOfRainForecast
        forecast: i18n.tr("Chance of rain")
        imageSource: "../graphics/extended-information_chance-of-rain.svg"
        value: modelData.chanceOfRain
    }

    ForecastDetailsDelegate {
        id: windForecast
        forecast: i18n.tr("Winds")
        imageSource: "../graphics/extended-information_wind.svg"
        objectName: "windForecast"
        value: modelData.wind
    }

    ForecastDetailsDelegate {
        id: uvIndexForecast
        imageSource: "../graphics/extended-information_uv-level.svg"
        forecast: i18n.tr("UV Index")
        value: modelData.uvIndex
    }

    ForecastDetailsDelegate {
        id: pollenForecast
        forecast: i18n.tr("Pollen")
        // FIXME: need icon
        //value: modelData.pollen  // TODO: extra from API
    }

    ForecastDetailsDelegate {
        id: humidityForecast
        forecast: i18n.tr("Humidity")
        imageSource: "../graphics/extended-information_humidity.svg"
        value: modelData.humidity
    }

    ForecastDetailsDelegate {
        id: sunriseForecast
        forecast: i18n.tr("Sunrise")
        imageSource: "../graphics/extended-information_sunrise.svg"
        value: modelData.sunrise
    }

    ForecastDetailsDelegate {
        id: sunsetForecast
        forecast: i18n.tr("Sunset")
        imageSource: "../graphics/extended-information_sunset.svg"
        value: modelData.sunset
    }
}
