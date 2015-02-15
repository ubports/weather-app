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
import "../components"


PageWithBottomEdge {
    // Set to null otherwise the header is shown (but blank) over the top of the listview
    id: locationPage
    flickable: null

    bottomEdgePageSource: Qt.resolvedUrl("LocationsPage.qml")
    bottomEdgeTitle: i18n.tr("Locations")
    tipColor: UbuntuColors.orange
    tipLabelColor: "#FFF"

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
      Flickable to scroll the location vertically.
      The respective contentHeight gets calculated after the Location is filled with data.
    */
    Flickable {
        id:locationFlickable
        width:parent.width
        height: parent.height
        contentWidth: parent.width

        /*
          ListView for locations with snap-scrolling horizontally.
        */
        ListView {
            id: locationPages
            anchors.fill: parent
            width:parent.width
            height:childrenRect.height
            contentWidth: parent.width
            contentHeight: childrenRect.height
            model: weatherApp.locationsList.length
            // TODO with snapMode, currentIndex is not properly set and setting currentIndex fails
            //snapMode: ListView.SnapOneItem
            orientation: ListView.Horizontal
            currentIndex: weatherApp.current
            highlightMoveDuration: 150
            highlightRangeMode: ListView.StrictlyEnforceRange
            onCurrentIndexChanged: {
                print("CI: "+currentIndex)
            }
            delegate: LocationPane {}
        }
    }
}
