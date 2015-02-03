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


Page {
    // Set to null otherwise the header is shown (but blank) over the top of the listview
    flickable: null

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
                locationName: "Hackney"  // TODO: non static
            }

            HomeGraphic {

            }

            HomeTempInfo {
                description: i18n.tr("Rainy & windy")  // TODO: non static
                high: "13°C"
                low: "10°C"
                now: "13°"  // TODO: non static
            }

            ListItem.ThinDivider {

            }
        }
        model: ListModel {  // TODO: non static
            ListElement {
                day: "Saturday"
                low: 12
                high: 15
            }
            ListElement {
                day: "Sunday"
                low: 14
                high: 18
            }
            ListElement {
                day: "Monday"
                low: 10
                high: 11
            }
            ListElement {
                day: "Tuesday"
                low: -7
                high: 0
            }
        }
        delegate: DayDelegate {
            day: model.day
            high: model.high + "°C"  // TODO: non static
            low: model.low + "°C"
        }
    }
}
