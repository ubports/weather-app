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

Rectangle {
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
                today = forecasts[0];

        var tempUnits = settings.tempScale === "°C" ? "metric" : "imperial"

        // set general location data
        name = data.location.name;

        // set current temps and condition
        iconName = (current.icon) ? current.icon : ""
        icon = imageMap[iconName]
        conditionText = (current.condition.main) ? current.condition.main : current.condition; // difference TWC/OWM
        todayMaxTemp = (today[tempUnits].tempMax !== undefined) ? Math.round(today[tempUnits].tempMax).toString() + settings.tempScale: "";
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
                    image: (forecasts[x].icon !== undefined && iconMap[forecasts[x].icon] !== undefined) ? iconMap[forecasts[x].icon] : ""
                }
                mainPageWeekdayListView.model.append(dayData);
            }
        }        
        setFlickableContentHeight();
    }

    Column {
        id: locationTop
        anchors {
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
                day: model.day
                high: model.high
                image: model.image
                low: model.low
            }
        }
    }
}
