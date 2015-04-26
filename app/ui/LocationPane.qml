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

import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../components"

Item {
    id: locationItem
    /*
      Data properties
    */
    property string name
    property string conditionText
    property string currentTemp
    property string todayMaxTemp
    property string todayMinTemp
    property string icon
    property string iconName

    Component.onCompleted: renderData(index)

    width: locationPage.width
    height: childrenRect.height
    anchors.fill: parent.fill

    function emptyIfUndefined(variable, append) {
        if (append === undefined) {
            append = ""
        }

        return variable === undefined ? "" : variable + append
    }

    /*
      Calculates the height of all location data components, to set the Flickable.contentHeight right.
    */
    function setFlickableContentHeight() {
        var contentHeightGu = (homeTempInfo.height+homeGraphic.height
                               +(weekdayColumn.height*mainPageWeekdayListView.model.count))/units.gridUnit;
        locationFlickable.contentHeight = units.gu(contentHeightGu+25);
    }

    /*
      Extracts values from the location weather data and puts them into the appropriate components
      to display them.

      Attention: Data access happens through "weatherApp.locationList[]" by index, since complex
      data in models will lead to type problems.
    */
    function renderData(index) {
        var data = weatherApp.locationsList[index],
                current = data.data[0].current,
                forecasts = data.data,
                forecastsLength = forecasts.length,
                today = forecasts[0],
                hourlyForecasts = [];

        var tempUnits = settings.tempScale === "°C" ? "metric" : "imperial"

        // set general location data
        name = data.location.name;

        // set current temps and condition
        iconName = (current.icon) ? current.icon : "";
        icon = (imageMap[iconName] !== undefined) ? imageMap[iconName] : "";
        conditionText = (current.condition !== undefined) ? current.condition : "";
        todayMaxTemp = (today[tempUnits].tempMax !== undefined) ? Math.round(today[tempUnits].tempMax).toString() + settings.tempScale: "";
        todayMinTemp = Math.round(today[tempUnits].tempMin).toString() + settings.tempScale;
        currentTemp = Math.round(current[tempUnits].temp).toString() + String("°");

        // reset days list
        mainPageWeekdayListView.model.clear()

        // set daily forecasts
        if(forecastsLength > 0) {
            for(var x=0;x<forecastsLength;x++) {
                // collect hourly forecasts if available
                if(forecasts[x].hourly !== undefined && forecasts[x].hourly.length > 0) {
                    hourlyForecasts = hourlyForecasts.concat(forecasts[x].hourly)
                }
                if(x === 0) {
                    // skip todays daydata
                    continue;
                }

                // set daydata
                var dayData = {
                    day: formatTimestamp(forecasts[x].date, 'dddd'),
                    low: Math.round(forecasts[x][tempUnits].tempMin).toString() + settings.tempScale,
                    high: (forecasts[x][tempUnits].tempMax !== undefined) ? Math.round(forecasts[x][tempUnits].tempMax).toString() + settings.tempScale : "",
                    image: (forecasts[x].icon !== undefined && iconMap[forecasts[x].icon] !== undefined) ? iconMap[forecasts[x].icon] : "",
                    chanceOfRain: forecasts[x].propPrecip === undefined ? -1 : forecasts[x].propPrecip,
                    humidity: emptyIfUndefined(forecasts[x].humidity, "%"),
                    uvIndex: emptyIfUndefined(forecasts[x].uv),
                    wind: forecasts[x][tempUnits].windSpeed === undefined || forecasts[x].windDir === undefined
                                ? "" : Math.round(forecasts[x][tempUnits].windSpeed) + settings.windUnits + " " + forecasts[x].windDir
                }
                mainPageWeekdayListView.model.append(dayData);
            }
        }        
        setFlickableContentHeight();

        // set data for hourly forecasts
        if(hourlyForecasts.length > 0) {
            homeHourlyLoader.forecasts = hourlyForecasts;
            homeHourlyLoader.tempUnits = tempUnits;
        }
    }

    Column {
        id: locationTop

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: units.gu(2)
        }
        spacing: units.gu(1)

        HeaderRow {
            id: headerRow
            locationName: locationItem.name
        }

        HomeGraphic {
            id: homeGraphic
            icon: locationItem.icon
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    homeGraphic.visible = false;
                }
            }
        }

        Loader {
            id: homeHourlyLoader
            active: !homeGraphic.visible
            asynchronous: true
            height: units.gu(32)
            source: "../components/HomeHourly.qml"
            visible: active
            width: parent.width

            property var forecasts: []
            property string tempUnits: ""
        }

        HomeTempInfo {
            id: homeTempInfo
            description: conditionText
            high: locationItem.todayMaxTemp
            low: locationItem.todayMinTemp
            now: locationItem.currentTemp
        }

        ListItem.ThinDivider {}
    }
    Column {
        id: weekdayColumn
        width: parent.width
        height: childrenRect.height
        anchors {
            top: locationTop.bottom
            left: parent.left
            right: parent.right
            margins: units.gu(2)
        }
        Repeater {
            id: mainPageWeekdayListView
            model: ListModel{}
            DayDelegate {
                flickable: locationFlickable

                day: model.day
                high: model.high
                image: model.image
                low: model.low

                chanceOfRain: model.chanceOfRain
                humidity: model.humidity
                // TODO: extra from API
                //pollen: model.pollen
                //sunrise: model.sunrise
                //sunset: model.sunset
                wind: model.wind
                uvIndex: model.uvIndex
            }
        }
    }
}
