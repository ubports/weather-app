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

import QtLocation 5.3
import QtPositioning 5.2
import QtQuick 2.4
import Ubuntu.Components 1.3
import "../data/WeatherApi.js" as WeatherApi


Item {
    id: currentLocation

    property string string: "Undefined"

    PositionSource {
        id: currentPosition
        updateInterval: 1000
        active: settings.detectCurrentLocation

        onPositionChanged: {
            var coord = currentPosition.position.coordinate
            if (coord.isValid) {
                geocodeModel.query = coord
                geocodeModel.update()
            }
        }
    }

    Plugin {
        id: osmPlugin
        name: "osm"

        // Set a useragent so that osm can uniquely identify out requests
        PluginParameter {
            name: "osm.useragent"
            value: "ubuntu-weather-app"
        }
    }

    GeocodeModel {
        id: geocodeModel
        autoUpdate: false
        plugin: osmPlugin

        onCountChanged: {
            // Update the currentLocation if one is found and it does not match the stored location
            // if there is a location request from url on startup, we ignore this first a few times when signal is triggerd
            // to avoid view position to current location. It works after requestLocationByUrl was set to undefined
            if (weatherApp.requestLocationByUrl === undefined
                    && count > 0 && currentLocation.string !== geocodeModel.get(0).address.city) {
                search();
            }
        }

        function search() {
            var loc = geocodeModel.get(0)
            currentLocation.string = loc.address.city
            searchForLocation("searchByPoint", loc.coordinate.latitude, loc.coordinate.longitude)
        }
    }

    Connections {
        target: settings
        onDetectCurrentLocationChanged: {
            if (settings.detectCurrentLocation) {
                geocodeModel.search();
            }
        }
    }
}
