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
import "components"
import "data" as Data
import "data/WeatherApi.js" as WeatherApi
import "data/key.js" as Key
import "ui"

MainView {
    id: weatherApp

    objectName: "weather"

    applicationName: "com.ubuntu.weather"

    automaticOrientation: false

    width: units.gu(40)
    height: units.gu(70)

    backgroundColor: "#F5F5F5"

    useDeprecatedToolbar: false
    anchorToKeyboard: true

    Component.onCompleted: {
        storage.getLocations(function(locations) {
            WeatherApi.sendRequest({
                action: "updateData",
                params: {
                    locations:locations,
                    force:false,
                    service: "weatherchannel",
                    api_key: Key.twcKey
                }
            }, responseDataHandler)
        })
    }

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
                 //buildTabs(messageObject.result);
             }
         } else {
             console.log(messageObject.error.msg+" / "+messageObject.error.request.url)
             // TODO error handling
         }
     }

    Data.Storage {
        id: storage
    }

    PageStack {
        id: mainPageStack

        HomePage {
            id: homePage
        }

        Component.onCompleted: mainPageStack.push(homePage)
    }
}
