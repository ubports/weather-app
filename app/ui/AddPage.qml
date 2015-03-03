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
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 1.0
import "../components"
import "../data/CitiesList.js" as Cities
import "../data/WeatherApi.js" as WeatherApi

Page {
    id: addPage
    title: i18n.tr("Add city")

    head.contents: TextField {
        id: searchField
        anchors {
           left: parent ? parent.left : undefined
           right: parent ? parent.right : undefined
           rightMargin: units.gu(2)
        }
        hasClearButton: true
        inputMethodHints: Qt.ImhNoPredictiveText
        placeholderText: i18n.tr("Search city")

        onTextChanged: {
            if (text.trim() === "") {
                loadEmpty()
            } else {
                loadFromProvider(text)
            }
        }

        onVisibleChanged: {
           if (visible) {
               forceActiveFocus()
           }
        }
    }

    function appendCities(list) {
        list.forEach(function(loc) {
            citiesModel.append(loc);
        })
    }

    function clearModelForLoading() {
        citiesModel.clear()
        citiesModel.loading = true
        citiesModel.httpError = false
    }

    function loadEmpty() {
        clearModelForLoading()

        appendCities(Cities.preList)

        citiesModel.loading = false
    }

    function loadFromProvider(search) {
        clearModelForLoading()

        WeatherApi.sendRequest({
            action: "searchByName",
            params: {
                name: search,
                units: "metric"
            }
        }, searchResponseHandler)
    }

    function searchResponseHandler(msgObject) {
        if (!msgObject.error) {
            appendCities(msgObject.result.locations)
        } else {
            citiesModel.httpError = true
        }

        citiesModel.loading = false
    }

    ListView {
        id: addLocationView
        anchors {
            fill: parent
        }
        model: ListModel {
            id: citiesModel

            property bool loading: true
            property bool httpError: false

            onRowsAboutToBeInserted: loading = false
        }
        delegate: ListItem.Empty {
            Column {
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }
                spacing: units.gu(0.5)

                Label {
                    color: UbuntuColors.darkGrey
                    elide: Text.ElideRight
                    fontSize: "medium"
                    text: model.name
                }

                Label {
                    color: UbuntuColors.lightGrey
                    elide: Text.ElideRight
                    fontSize: "small"
                    text: model.countryName
                }
            }

            onClicked: {
                if (storage.addLocation(citiesModel.get(index))) {
                    mainPageStack.pop()
                } else {
                    PopupUtils.open(locationExistsComponent, addPage)
                }
            }
        }

        Component.onCompleted: loadEmpty()
    }

    ActivityIndicator {
        anchors {
            centerIn: parent
        }
        running: visible
        visible: citiesModel.loading
    }

    Label {
        id: noCity
        anchors {
            centerIn: parent
        }
        text: i18n.tr("No city found")
        visible: citiesModel.count === 0 && !citiesModel.loading
    }

    Label {
        id: httpFail
        anchors {
            left: parent.left
            margins: units.gu(1)
            right: parent.right
            top: noCity.bottom
        }
        horizontalAlignment: Text.AlignHCenter
        text: i18n.tr("Couldn't load weather data, please try later again!")
        visible: citiesModel.httpError
        wrapMode: Text.WordWrap
    }

    Component {
        id: locationExistsComponent

        Dialog {
            id: locationExists
            title: i18n.tr("Location already added.")

            Button {
                text: i18n.tr("OK")
                onClicked: PopupUtils.close(locationExists)
            }
        }
    }

}
