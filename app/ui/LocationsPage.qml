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
import "../components/ListItemActions"


Page {
    id: locationsPage
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

            onRemoved: storage.removeMultiLocations(selectedItems.slice())
        }
    ]

    MultiSelectListView {
        id: locationsListView
        anchors {
            fill: parent
        }
        model: ListModel {
            id: locationsModel
        }
        delegate: WeatherListItem {
            id: locationsListItem
            leftSideAction: Remove {
                onTriggered: storage.removeLocation(index)
            }
            multiselectable: true
            reorderable: true

            onItemClicked: {
                settings.current = index;
                pageStack.pop()
            }
            onReorder: {
                console.debug("Move: ", from, to);

                storage.moveLocation(from, to);
            }

            Item {
                anchors {
                    fill: parent
                    leftMargin: units.gu(2)
                    rightMargin: units.gu(2)
                }

                Label {
                    id: locationName
                    anchors {
                        left: parent.left
                        right: weatherImage.visible ? weatherImage.left : parent.right
                        rightMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }
                    elide: Text.ElideRight
                    text: name
                }

                Icon {
                    id: weatherImage
                    anchors.centerIn: parent
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

    function populateLocationsModel() {
        locationsModel.clear()
        var loc = {}, data = {},
            tempUnits = settings.tempScale === "°C" ? "metric" : "imperial";
        locationsModel.append({ "name": currentLocation.string, "temp": "0", "icon": "weather-clear-symbolic" })
        for (var i=0; i < weatherApp.locationsList.length; i++) {
            data = weatherApp.locationsList[i];
            loc = {
                "name": data.location.name,
                "temp": Math.round(data.data[0].current[tempUnits].temp).toString(),
                "icon": iconMap[data.data[0].current.icon]
            }
            locationsModel.append(loc)
        }
    }

    Connections {
        target: weatherApp
        onLocationsListChanged: populateLocationsModel()
    }

    Component.onCompleted: populateLocationsModel()
}
