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
    property string iconName

    // TODO map iconnames to source image names
    property var iconMap: {
        "moon": "moon.svg"
        // etc pp
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
            today = forecasts[0];

        var tempUnits = settings.tempScale === "C" ? "metric" : "imperial"

        // set general location data
        name = data.location.name;

        // set current temps and condition
        iconName = (current.icon) ? current.icon : ""
        conditionText = (current.condition.main) ? current.condition.main : current.condition; // difference TWC/OWM
        todayMaxTemp = (today[tempUnits].tempMax) ? Math.round(today[tempUnits].tempMax).toString() + settings.tempScale: "";
        todayMinTemp = Math.round(today[tempUnits].tempMin).toString() + settings.tempScale;
        currentTemp = Math.round(current[tempUnits].temp).toString() + String("°");

        // reset days list
        mainPageWeekdayListView.model.clear()

        // set daily forecasts
        if(forecastsLength > 0) {
            for(var x=1;x<forecastsLength;x++) {
                // print(JSON.stringify(forecasts[x][units]))
                var dayData = {
                    day: formatTimestamp(forecasts[x].date, 'dddd'),
                    low: Math.round(forecasts[x][tempUnits].tempMin).toString() + settings.tempScale,
                    high: (forecasts[x][tempUnits].tempMax !== undefined) ? Math.round(forecasts[x][tempUnits].tempMax).toString() + settings.tempScale : "",
                    image: (forecasts[x].icon !== undefined && iconMap[forecasts[x].icon] !== undefined) ? iconMap[forecasts[x].icon] + settings.tempScale : ""
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
                icon: locationPage.iconName
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
            low: model.low
        }
    }
}
