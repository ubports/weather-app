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
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 1.0
import "../components"
import "../data/CitiesList.js" as Cities
import "../data/WeatherApi.js" as WeatherApi

Page {
    id: addLocationPage
    objectName: "addLocationPage"
    title: i18n.tr("Select a city")
    visible: false

    /*
      Flickable is set to null to stop page header from hiding since the fast
      scroll component hides top anchor margin is incorrect.
    */
    flickable: null

    state: "default"
    states: [
        PageHeadState {
            name: "default"
            head: addLocationPage.head
            backAction: Action {
                iconName: "back"
                text: i18n.tr("Back")
                onTriggered: mainPageStack.pop()
            }
            actions: [
                Action {
                    iconName: "search"
                    text: i18n.tr("City")
                    onTriggered: {
                        addLocationPage.state = "search"
                        searchComponentLoader.sourceComponent = searchComponent
                        searchComponentLoader.item.forceActiveFocus()
                    }
                }
            ]
        },

        PageHeadState {
            name: "search"
            head: addLocationPage.head
            backAction: Action {
                iconName: "back"
                text: i18n.tr("Back")
                onTriggered: {
                    locationList.forceActiveFocus()
                    searchComponentLoader.item.text = ""
                    addLocationPage.state = "default"
                    searchComponentLoader.sourceComponent = undefined
                }
            }

            contents: Loader {
                id: searchComponentLoader
                anchors {
                    left: parent ? parent.left : undefined
                    right: parent ? parent.right : undefined
                    rightMargin: units.gu(2)
                }
            }
        }
    ]

    Component {
        id: searchComponent
        TextField {
            id: searchField
            objectName: "searchField"

            inputMethodHints: Qt.ImhNoPredictiveText
            placeholderText: i18n.tr("Search city")
            hasClearButton: true

            onTextChanged: {
                if (text.trim() === "") {
                    loadEmpty()
                } else {
                    loadFromProvider(text)
                }
            }
        }
    }

    // Builds a area label for the location, depending on the uniqueness of name, adminName1 and country
     function buildAreaLabel(loc, a1Counts) {
         var label = "";
         label += ((loc.adminName1) ? loc.adminName1.replace(/ Region$/,''):"");
         if (loc.adminName2 && a1Counts[loc.name+loc.adminName1] > 1) {
             // even name and adminName1 are multiple, add adminName2
             label += ", "+loc.adminName2;
         }
         label += ((label !== "") ? ", " : "") + loc.countryName
         return label;
     }

     function appendCities(list) {
         var a1Counts = {};
         // count occurrences of name+adminName1 and name+country
         list.forEach(function(loc) {
             a1Counts[loc.name+loc.adminName1] = (!a1Counts[loc.name+loc.adminName1]) ? 1 : a1Counts[loc.name+loc.adminName1]+1;
         });
         // add locations to listmodel
         list.forEach(function(loc) {
             loc.areaLabel = buildAreaLabel(loc, a1Counts)
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
        id: locationList

        clip: true
        currentIndex: -1
        anchors.fill: parent
        anchors.rightMargin: fastScroll.showing ? fastScroll.width - units.gu(1)
                                                : 0

        function getSectionText(index) {
            return citiesModel.get(index).name.substring(0,1)
        }

        onFlickStarted: {
            forceActiveFocus()
        }

        section.property: "name"
        section.criteria: ViewSection.FirstCharacter
        section.labelPositioning: ViewSection.InlineLabels

        section.delegate: ListItem.Header {
            text: section
        }

        model: ListModel {
            id: citiesModel

            property bool loading: true
            property bool httpError: false

            onRowsAboutToBeInserted: loading = false
        }

        delegate: ListItem.Empty {
            showDivider: false
            Column {
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                    rightMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                Label {
                    color: UbuntuColors.darkGrey
                    elide: Text.ElideRight
                    fontSize: "medium"
                    text: name
                }

                Label {
                    color: UbuntuColors.lightGrey
                    elide: Text.ElideRight
                    fontSize: "xx-small"
                    text: areaLabel
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

        Behavior on anchors.rightMargin {
            UbuntuNumberAnimation {}
        }
    }

    FastScroll {
        id: fastScroll

        listView: locationList

        enabled: (locationList.contentHeight > (locationList.height * 2)) &&
                 (locationList.height >= minimumHeight)

        anchors {
            top: locationList.top
            topMargin: units.gu(1.5)
            bottom: locationList.bottom
            right: parent.right
        }
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
