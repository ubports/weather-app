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
import Qt.labs.settings 1.0
import Ubuntu.Components 1.3
import "components"
import "data" as Data
import "data/WeatherApi.js" as WeatherApi
import "data/keys.js" as Keys
import "ui"

MainView {
    id: weatherApp

    objectName: "weather"

    applicationName: "com.ubuntu.weather"

    automaticOrientation: false

    width: units.gu(40)
    height: units.gu(70)

    backgroundColor: "#F5F5F5"

    anchorToKeyboard: true

    signal listItemSwiping(int i)

    /*
      List of locations and their data, accessible through index
    */
    property var locationsList: []    

    /*
      Index of Location before a refresh, to go back after
    */
    property int indexAtRefresh: -1

    /*
      Is the app loading?
    */
    property bool loading: false

    /*
      Indicates of the last API call resulted in a network error
    */
    property bool networkError: false

    /*
      Indicates of the location info requested from Url
    */
    property var requestLocationByUrl;

    /*
      (re)load the pages on completion
    */
    Component.onCompleted: {
        var url = args.defaultArgument.at(0)
        var argus = parseArguments(url);

        mainPageStack.push(Qt.resolvedUrl("ui/HomePage.qml"), {"hourlyVisible": argus.hourlyVisible})

        storage.getLocations(fillPages);
        if (argus.city && argus.lat && argus.lng) {
            if (positionViewAtCity(argus.city) === -1) {
                searchForLocation("searchByUrl", argus.lat, argus.lng)
            }
        } else {
            refreshData();
        }
    }

    /*
      Handle response data from data backend. Checks if a location
      was updated and has to be stored again.
    */
    function responseDataHandler(messageObject) {
         if(!messageObject.error) {
             if(messageObject.action === "updateData") {
                 messageObject.result.forEach(function(loc) {
                     // replace location data in cache with refreshed values
                     if(loc["save"] === true) {
                         storage.updateLocation(loc.db.id, loc);
                     }
                 });
                 //print(JSON.stringify(messageObject.result));
                 fillPages(messageObject.result);

                 //1.Re-position current display index at requested location index
                 //2.Prevent index changed after reorder when geoChanged is triggered on startup
                 if (requestLocationByUrl) {
                     for (var i = 0; i < locationsList.length; i++) {
                         var loc = locationsList[i].location;
                         if (requestLocationByUrl !== undefined && loc.services.geonames !== undefined &&
                                 requestLocationByUrl.services.geonames === loc.services.geonames) {
                             settings.current = i;
                             requestLocationByUrl = undefined
                             break;
                         }
                     }
                 }
             }
         } else {
             console.log(messageObject.error.msg+" / "+messageObject.error.request.url)
         }

         networkError = messageObject.error !== undefined
     }

    /* Fill the location pages with their data. */
    function fillPages(locations) {
        locationsList = []
        locationsList = locations;

        // Loading is complete
        // Either directly from cached entries being passed here
        //  - storage.getLocations(fillPages);
        // or after updateData has occurred
        //  - fillPages(messageObject.result) from responseDataHandler
        loading = false;
    }

    /*
      Refresh data, either directly from storage or by checking against
      API instead.
    */
    function refreshData(from_storage, force_refresh) {
        from_storage = from_storage || false
        force_refresh = force_refresh || false
        loading = true
        if(from_storage === true && force_refresh !== true) {
            storage.getLocations(fillPages);
        } else {
            storage.getLocations(function(locations) {
                WeatherApi.sendRequest({
                    action:  "updateData",
                    params: {
                        locations: locations,
                        force: force_refresh,
                        service: settings.service,
                        twc_api_key: Keys.twcKey,
                        owm_api_key: Keys.owmKey,
                        interval: settings.refreshInterval
                    }
                }, responseDataHandler)
            });
        }
    }

    /*
      parse arguments retrieved from url. The url format can be as following:
      weather://?display=hourly&city=London&lat=51.50853&lng=-0.12574
    */
    function parseArguments(url) {
        var arguments = url.substring(url.lastIndexOf('?') + 1).split('&');

        var hourlyVisible = false;
        var city, lat, lng;
        var index = 0;
        while(index < arguments.length) {
            var params = arguments[index].split('=');
            if (params[0] === "display")
                hourlyVisible = params[1] === "hourly" ?  true: false;
            if (params[0] === "lng")
                lng = params[1];
            if (params[0] === "lat")
                lat = params[1];
            if (params[0] === "city")
                city = params[1];

            index++;
        }

        return {"hourlyVisible": hourlyVisible, "city": city, "lat":  lat, "lng" : lng}
    }

    /*
      Positions the view that with the specified cityName,
      return pos index of the city if it can be found in locationlist
      and return -1 if city is not found in locationlist.
      NOTE: potential minor issue: cities with the same name in different countries
    */
    function positionViewAtCity(cityName) {
        var index = -1;

        for (var i = 0; i < locationsList.length; i++) {
            var loc = locationsList[i].location;
            if (cityName === loc.name) {
                settings.current =  i;
                index  = i;
                break;
            }
        }

        return index;
    }

    function searchForLocation(action, lat, lon) {
        WeatherApi.sendRequest({
            action: action,
            params: {
                coords: {
                    lat: lat,
                    lon: lon
                }
            }
        }, searchResponseHandler)
    }

    function searchResponseHandler(msgObject) {
        if (!msgObject.error ) {
            console.log("Loc to add:", JSON.stringify(msgObject.result.locations[0]))
            if (msgObject.action === "searchByUrl") {
                requestLocationByUrl = msgObject.result.locations[0];
                storage.addLocation(requestLocationByUrl)
            } else if (settings.detectCurrentLocation) {
                storage.updateCurrentLocation(msgObject.result.locations[0])
            }
        }
    }

    Arguments {
        id: args;

        defaultArgument.help: i18n.tr("One arguments for weather app: --display, --city, --lat, --lng They will be managed by system. See the source for a full comment about them");
        defaultArgument.valueNames: ["URL"]

        /* ARGUMENTS on startup
          *
          * Display hourly view when startup. This enable us to navigate weather app from weather scope
          * Keyword: display
          * Value: hourly or default
          *
          * Location information. This enable us to navigate relevant city weather view with geo information specified
          * please pass all three basic geo parameters together when requesting specific city weather
          * Keyword: city
          * Value: city name
          *
          * Keyword: lat
          * Value:  latitude of city
          *
          * Keyword: lng
          * Value:  longitude of city
          */

        Argument {
            name: "display"
            required: false
            valueNames: ["DISPLAY"]
        }

        Argument {
            name: "city"
            required: false
            valueNames: ["CITY"]
        }

        Argument {
            name: "lat"
            required: false
            valueNames: ["LATITUDE"]
        }

        Argument {
            name: "lng"
            required: false
            valueNames: ["LONGITUDE"]
        }
    }

    Connections {
        target: UriHandler
        onOpened: {
            var argus = parseArguments(uris[0]);
            if (argus.city && argus.lat && argus.lng) {
                while (mainPageStack.depth > 1) {
                    mainPageStack.pop()
                }

                if (positionViewAtCity(argus.city) === -1) {
                    searchForLocation("searchByUrl", argus.lat, argus.lng)
                }
            }
        }
    }

    CurrentLocation {
        id: currentLocation
    }

    Settings {
        id: settings
        category: "weatherSettings"
        /*
          Index of the current locationList of locations and their data, accessible through index
        */
        property int current: 0

        property bool detectCurrentLocation: true
        property int refreshInterval: 1800
        property string precipUnits
        property string service
        property string tempScale
        property string units
        property string windUnits

        property bool addedCurrentLocation: false
        property bool migrated: false

        onDetectCurrentLocationChanged: {
            if (!detectCurrentLocation) {
                if (addedCurrentLocation) {
                    storage.removeLocation(-1);  // indexes are increased by 1
                    addedCurrentLocation = false;
                }

                refreshData();
            }
        }

        Component.onCompleted: {
            if (units === "") {  // No settings so load defaults
                console.debug("No settings, using defaults")
                var metric = Qt.locale().measurementSystem === Locale.MetricSystem

                precipUnits = metric ? "mm" : "in"
                service = "weatherchannel"
                tempScale = "°" + (metric ? "C" : "F")
                units = metric ? "metric" : "imperial"
                windUnits = metric ? "kph" : "mph"
            }

            if (Keys.twcKey === "") {  // No API key for TWC, so use OWM
                service = "openweathermap"
            }
        }
    }

    Data.Storage {
        id: storage

        // Add or replace the current locaiton to the storage and refresh the
        // locationList
        function updateCurrentLocation(location) {
            if (!settings.addedCurrentLocation || locationsList == null || locationsList.length == 0) {
                storage.insertLocationAtStart({location: location});
                settings.addedCurrentLocation = true;
            } else {
                storage.updateLocation(locationsList[0].db.id, {location: location});
            }

            refreshData(false, true);
        }

        // Add the location to the storage and refresh the locationList
        // Return true if a location is added
        function addLocation(location) {
            var exists = checkLocationExists(location)

            if(!exists) {
                if(location.dbId === undefined || location.dbId === 0) {
                    storage.insertLocation({location: location});
                }
            }
            refreshData();

            return !exists;
        }

        // Return true if the location given is already in the locationsList, and is not the same
        // as the current location.
        function checkLocationExists(location) {
            var exists = false;

            for (var i=0; !exists && i < locationsList.length; i++) {
                var loc = locationsList[i].location;

                if (loc.services.geonames && (loc.services.geonames === location.services.geonames) && !(settings.addedCurrentLocation && i === 0)) {
                    exists = true;
                }
            }

            return exists;
        }

        function moveLocation(from, to) {
            // Indexes are offset by 1 to account for current location
            if (settings.addedCurrentLocation) {
                from += 1
                to += 1
            }

            // Update settings to respect new changes
            if (from === settings.current) {
                settings.current = to;
            } else if (from < settings.current && to >= settings.current) {
                settings.current -= 1;
            } else if (from > settings.current && to <= settings.current) {
                settings.current += 1;
            }

            storage.reorder(locationsList[from].db.id, locationsList[to].db.id);

            refreshData(true, false);
        }

        // Remove a location from the list
        function removeLocation(index) {
            // Indexes are offset by 1 to account for current location
            if (settings.addedCurrentLocation) {
                index += 1
            }

            if (settings.current >= index) {  // Update settings to respect new changes
                settings.current -= settings.current;
            }

            storage.clearLocation(locationsList[index].db.id);

            refreshData(true, false);
        }

        function removeMultiLocations(indexes) {
            var i;

            // Sort the item indexes as loops below assume *numeric* sort
            indexes.sort(function(a,b) { return a - b })

            for (i=0; i < indexes.length; i++) {
                if (settings.current >= indexes[i] + 1) {  // Update settings to respect new changes
                    settings.current -= settings.current;
                }
            }

            // Get location db ids to remove
            var locations = []

            for (i=0; i < indexes.length; i++) {
                if (settings.addedCurrentLocation) {
                    locations.push(locationsList[indexes[i] + 1].db.id)
                } else {
                    locations.push(locationsList[indexes[i]].db.id)
                }
            }

            storage.clearMultiLocation(locations);

            refreshData(true, false);
        }
    }

    PageStack {
        id: mainPageStack
    }
}
