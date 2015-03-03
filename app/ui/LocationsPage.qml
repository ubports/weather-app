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


Page {
    id: locationsPage
    // Set to null otherwise the first delegate appears +header.height down the page
    flickable: null
    title: i18n.tr("Locations")

    head.actions: [
        Action {
            iconName: "add"
            onTriggered: mainPageStack.push(Qt.resolvedUrl("AddPage.qml"))
        }
    ]

    ListView {
        anchors {
            fill: parent
        }
        model: ListModel {
            id: locationsModel
        }
        delegate: ListItem.Standard {
            text: model.location.name
            onClicked: {
                settings.current = index;
                pageStack.pop()
            }
        }
    }

    function populateLocationsModel() {
        locationsModel.clear()

        for (var i=0; i < weatherApp.locationsList.length; i++) {
            locationsModel.append(weatherApp.locationsList[i])
        }
    }

    Connections {
        target: weatherApp
        onLocationsListChanged: populateLocationsModel()
    }

    Component.onCompleted: populateLocationsModel()
}
