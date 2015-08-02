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
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../components"
import "../components/ListItemActions"


Page {
    id: locationsPage
    objectName: "locationsPage"
    // Set to null otherwise the first delegate appears +header.height down the page
    flickable: null
    title: i18n.tr("Locations")

    state: locationsListView.state === "multiselectable" ? "selection" : "default"
    states: [
        PageHeadState {
            id: defaultState
            name: "default"
            actions: [
                Action {
                    iconName: "add"
                    onTriggered: mainPageStack.push(Qt.resolvedUrl("AddLocationPage.qml"))
                }
            ]
            PropertyChanges {
                target: locationsPage.head
                actions: defaultState.actions
            }
        },
        MultiSelectHeadState {
            listview: locationsListView
            removable: true
            thisPage: locationsPage

            onRemoved: storage.removeMultiLocations(selectedItems.slice());
        }
    ]

    ListModel {
        id: currentLocationModel
    }

    MultiSelectListView {
        id: locationsListView
        anchors {
            fill: parent
        }
        model: ListModel {
            id: locationsModel
        }
        header: MultiSelectListView {
            id: currentLocationListView
            anchors {
                left: parent.left
                right: parent.right
            }
            height: settings.addedCurrentLocation && settings.detectCurrentLocation ? units.gu(8) : units.gu(0)
            interactive: false
            model: currentLocationModel
            delegate: WeatherListItem {
                id: currentLocationListItem

                onItemClicked: {
                    settings.current = index;
                    pageStack.pop()
                }

                Column {
                    anchors {
                        left: parent.left
                        right: currentWeatherImage.left
                        rightMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }

                    Label {
                        id: currentLocationName

                        anchors {
                            left: parent.left
                            leftMargin: units.gu(2)
                        }

                        elide: Text.ElideRight
                        fontSize: "medium"
                        text: i18n.tr("Current Location")
                    }
                    Label {
                        id: currentLocationName2

                        anchors {
                            left: parent.left
                            leftMargin: units.gu(2)
                        }

                        color: UbuntuColors.lightGrey
                        elide: Text.ElideRight
                        fontSize: "small"
                        font.weight: Font.Light
                        text: name + ", " + (adminName1 == name ? countryName : adminName1)
                    }
                }

                Icon {
                    id: currentWeatherImage
                    anchors {
                        right: parent.right
                        rightMargin: units.gu(14)
                        verticalCenter: parent.verticalCenter
                    }
                    name: icon
                    height: units.gu(3)
                    width: units.gu(3)
                }

                Label {
                    id: currentTemperatureLabel
                    anchors {
                        left: currentWeatherImage.right
                        leftMargin: units.gu(1)
                        right: parent.right
                        rightMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }
                    color: UbuntuColors.orange
                    elide: Text.ElideRight
                    font.pixelSize: units.gu(4)
                    font.weight: Font.Light
                    horizontalAlignment: Text.AlignRight
                    text: temp + settings.tempScale
                }
            }
        }

        delegate: WeatherListItem {
            id: locationsListItem
            leftSideAction: Remove {
                onTriggered: storage.removeLocation(index)
            }
            multiselectable: true
            reorderable: true

            onItemClicked: {
                settings.current = index + 1;

                pageStack.pop()
            }
            onReorder: {
                console.debug("Move: ", from, to);

                storage.moveLocation(from, to);
            }

            ListItem.ThinDivider {
                anchors {
                    top: parent.top
                }
                visible: index == 0
            }

            Item {
                anchors {
                    fill: parent
                    leftMargin: units.gu(2)
                    rightMargin: units.gu(2)
                }

                Column {
                    anchors {
                        left: parent.left
                        right: weatherImage.visible ? weatherImage.left : parent.right
                        rightMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }

                    Label {
                        id: locationName
                        elide: Text.ElideRight
                        fontSize: "medium"
                        text: name
                    }
                    Label {
                        id: locationName2
                        color: UbuntuColors.lightGrey
                        elide: Text.ElideRight
                        fontSize: "small"
                        font.weight: Font.Light
                        text: adminName1 == name ? countryName : adminName1
                    }
                }

                Icon {
                    id: weatherImage
                    anchors {
                        right: parent.right
                        rightMargin: units.gu(12)
                        verticalCenter: parent.verticalCenter
                    }
                    name: icon
                    height: units.gu(3)
                    width: units.gu(3)
                    visible: locationsPage.state === "default"
                }

                Label {
                    id: temperatureLabel
                    anchors {
                        left: weatherImage.right
                        leftMargin: units.gu(1)
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    color: UbuntuColors.orange
                    elide: Text.ElideRight
                    font.pixelSize: units.gu(4)
                    font.weight: Font.Light
                    horizontalAlignment: Text.AlignRight
                    text: temp + settings.tempScale
                    visible: locationsPage.state === "default"
                }
            }

            ListItem.ThinDivider {
                anchors {
                    bottom: parent.bottom
                }
            }
        }
    }

    Loader {
        active: locationsList === null || locationsList.length === 0
        anchors {
            fill: parent
        }
        asynchronous: true
        source: "../components/LocationsPageEmptyStateComponent.qml"
        visible: status === Loader.Ready && active
    }

    function populateLocationsModel() {
        currentLocationModel.clear()
        locationsModel.clear()
        var loc = {}, data = {},
            tempUnits = settings.tempScale === "°C" ? "metric" : "imperial";

        for (var i=0; i < weatherApp.locationsList.length; i++) {
            data = weatherApp.locationsList[i];
            loc = {
                "name": data.location.name,
                "adminName1": data.location.adminName1,
                "areaLabel": data.location.areaLabel,
                "countryName": data.location.countryName,
                "temp": Math.round(data.data[0].current[tempUnits].temp).toString(),
                "icon": iconMap[data.data[0].current.icon]
            }

            if (!settings.addedCurrentLocation || i > 0) {
                locationsModel.append(loc)
            } else {
                currentLocationModel.append(loc)
            }
        }
    }

    Connections {
        target: weatherApp
        onLocationsListChanged: populateLocationsModel()
    }

    Component.onCompleted: populateLocationsModel()
}
