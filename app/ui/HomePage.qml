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


PageWithBottomEdge {
    // Set to null otherwise the header is shown (but blank) over the top of the listview
    id: locationPage
    flickable: null

    bottomEdgePageSource: Qt.resolvedUrl("LocationsPage.qml")
    bottomEdgeTitle: i18n.tr("Locations")
    tipColor: UbuntuColors.orange
    tipLabelColor: "#FFF"

    /*
      Data properties
    */
    property string name;
    property string conditionText
    property string currentTemp
    property string todayMaxTemp
    property string todayMinTemp
    property string icon
    property string iconName

    property var iconMap: {
        "sun": Qt.resolvedUrl("../graphics/sunny.svg"),
        "moon": Qt.resolvedUrl("../graphics/starry.svg"),
        "cloud_sun": Qt.resolvedUrl("../graphics/partly-cloudy.svg"),
        "cloud_moon": Qt.resolvedUrl("../graphics/cloudy-night.svg"),
        "cloud": Qt.resolvedUrl("../graphics/cloudy.svg"),
        "rain": Qt.resolvedUrl("../graphics/rain.svg"),
        "thunder": Qt.resolvedUrl("../graphics/thunder.svg"),
        "snow_shower": Qt.resolvedUrl("../graphics/snow.svg"),
        "fog": Qt.resolvedUrl("../graphics/fog.svg"),
        "snow_rain": Qt.resolvedUrl("../graphics/snow.svg"),
        "scattered": Qt.resolvedUrl("../graphics/rain.svg"),
        "overcast": Qt.resolvedUrl("../graphics/cloudy.svg")
    }

    property var imageMap: {
        "sun": Qt.resolvedUrl("../graphics/Sunny.png"),
        "moon": Qt.resolvedUrl("../graphics/Starry-Night.png"),
        "cloud_sun": Qt.resolvedUrl("../graphics/Cloudy-Circles.png"),
        "cloud_moon": Qt.resolvedUrl("../graphics/Cloudy-Night.png"),
        "cloud": Qt.resolvedUrl("../graphics/Cloudy.png"),
        "rain": Qt.resolvedUrl("../graphics/Big-Rain.png"),
        "thunder": Qt.resolvedUrl("../graphics/Stormy.png"),
        "snow_shower": Qt.resolvedUrl("../graphics/Cloudy-Snow.png"),
        "fog": Qt.resolvedUrl("../graphics/Fog.png"),
        "snow_rain": Qt.resolvedUrl("../graphics/Cloudy-Snow.png"),
        "scattered": Qt.resolvedUrl("../graphics/Showers.png"),
        "overcast": Qt.resolvedUrl("../graphics/Cloudy.png")
    }

    /*
      Format date object by given format.
    */
    function formatTimestamp(dateData, format) {
        var date = new Date(dateData.year, dateData.month, dateData.date, dateData.hours, dateData.minutes)
        return Qt.formatDate(date, i18n.tr(format))
    }

    /*
      Extracts values from the location weather data and puts them into the appropriate components
      to display them.

      Attention: Data access happens through "weatherApp.locationList[]" by index, since complex
      data in models will lead to type problems.
    */
    function renderData() {
        var index = Math.floor(Math.random()*weatherApp.locationsList.length), // TODO get this value from ListView.currentIndex later!
            data = weatherApp.locationsList[index],
            current = data.data[0].current,
            forecasts = data.data,
            forecastsLength = forecasts.length,
            today = forecasts[0],
            tempUnits = weatherApp.tempUnits,
            tempScale = weatherApp.tempScale;

        // set general location data
        name = data.location.name;

        // set current temps and condition
        iconName = (current.icon) ? current.icon : ""
        icon = imageMap[iconName]
        conditionText = (current.condition.main) ? current.condition.main : current.condition; // difference TWC/OWM
        todayMaxTemp = (today[tempUnits].tempMax) ? Math.round(today[tempUnits].tempMax).toString() + tempScale: "";
        todayMinTemp = Math.round(today[tempUnits].tempMin).toString() + tempScale;
        currentTemp = Math.round(current[tempUnits].temp).toString() + String("°");

        // reset days list
        mainPageWeekdayListView.model.clear()

        // set daily forecasts
        if(forecastsLength > 0) {
            for(var x=1;x<forecastsLength;x++) {
                // print(JSON.stringify(forecasts[x][units]))
                var dayData = {
                    day: formatTimestamp(forecasts[x].date, 'dddd'),
                    low: Math.round(forecasts[x][tempUnits].tempMin).toString() + tempScale,
                    high: (forecasts[x][tempUnits].tempMax !== undefined) ? Math.round(forecasts[x][tempUnits].tempMax).toString() + tempScale : "",
                    image: (forecasts[x].icon !== undefined && iconMap[forecasts[x].icon] !== undefined) ? iconMap[forecasts[x].icon] : ""
                }
                mainPageWeekdayListView.model.append(dayData);
            }
        }
    }

    ListView {
        id: mainPageWeekdayListView
        anchors {
            fill: parent
            margins: units.gu(2)
        }

        header: Column {
            anchors {
                left: parent.left
                right: parent.right
            }
            spacing: units.gu(1)

            HeaderRow {
                locationName: locationPage.name
            }

            HomeGraphic {
                icon: locationPage.icon
            }

            HomeTempInfo {
                description: locationPage.conditionText
                high: locationPage.todayMaxTemp
                low: locationPage.todayMinTemp
                now: locationPage.currentTemp
            }

            ListItem.ThinDivider {

            }
        }
        model: ListModel {}

        delegate: DayDelegate {
            day: model.day
            high: model.high
            image: model.image
            low: model.low
        }
    }
}
