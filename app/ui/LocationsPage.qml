/*
 * Copyright (C) 2015, 2017 Canonical Ltd
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
import Ubuntu.Components 1.3
import "../components"
import "../components/HeadState"
import "../components/ListItemActions"


Page {
    id: locationsPage
    objectName: "locationsPage"
    state: locationsListView.state === "multiselectable" ? "selection" : "default"
    states: [
        LocationsHeadState {
            thisPage: locationsPage
        },
        MultiSelectHeadState {
            listview: locationsListView
            removable: true
            thisPage: locationsPage

            onRemoved: storage.removeMultiLocations(selectedIndices.slice());
        }
    ]

    // This is used by the header state (LocationsHeadState) to go back
    signal pop()

    ListModel {
        id: currentLocationModel
    }

    MultiSelectListView {
        id: locationsListView
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            top: locationsPage.header.bottom
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
            height: settings.addedCurrentLocation && settings.detectCurrentLocation ? contentHeight : units.gu(0)
            interactive: false
            model: currentLocationModel
            delegate: WeatherListItem {
                id: currentLocationListItem
                height: currentListItemLayout.height + (divider.visible ? divider.height : 0) + (fakeDivider.visible ? fakeDivider.height : 0)

                onItemClicked: {
                    settings.current = index;

                    // Ensure any selections are closed
                    locationsListView.closeSelection();

                    locationsPage.pop()
                }

                ListItemLayout {
                    id: currentListItemLayout
                    subtitle {
                        elide: Text.ElideRight
                        fontSize: "small"
                        text: name + ", " + (adminName1 == name ? countryName : adminName1)
                    }
                    title {
                        elide: Text.ElideRight
                        fontSize: "medium"
                        text: i18n.tr("Current Location")
                    }

                    Icon {
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                        height: parent.height / 2
                        name: icon
                        SlotsLayout.position: SlotsLayout.Trailing
                        SlotsLayout.overrideVerticalPositioning: true
                        width: height
                    }

                    Label {
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                        color: UbuntuColors.orange
                        elide: Text.ElideRight
                        font {
                            pixelSize: parent.height / 2
                            weight: Font.Light
                        }
                        horizontalAlignment: Text.AlignRight
                        SlotsLayout.position: SlotsLayout.Trailing
                        SlotsLayout.overrideVerticalPositioning: true
                        text: temp + settings.tempScale
                    }
                }

                // Inject extra divider when we are the last as the SDK hides it
                // but we need one as we have another listview directly below
                ListItem {
                    id: fakeDivider
                    anchors {
                        bottom: parent.bottom
                    }
                    divider {
                        visible: true
                    }
                    height: divider.height
                    visible: currentLocationModel.count - 1 == index
                }
            }
        }

        delegate: WeatherListItem {
            id: locationsListItem
            height: listItemLayout.height + (divider.visible ? divider.height : 0)
            leadingActions: ListItemActions {
                actions: [
                    Remove {
                        onTriggered: storage.removeLocation(index)
                    }
                ]
            }
            multiselectable: true
            objectName: "location" + index
            reorderable: true

            onItemClicked: {
                if (settings.addedCurrentLocation && settings.detectCurrentLocation) {
                    settings.current = index + 1;
                } else {
                    settings.current = index;
                }

                locationsPage.pop()
            }

            ListItemLayout {
                id: listItemLayout
                subtitle {
                    elide: Text.ElideRight
                    fontSize: "small"
                    text: adminName1 == name ? countryName : adminName1
                }
                title {
                    elide: Text.ElideRight
                    fontSize: "medium"
                    objectName: "name"
                    text: name
                }

                Icon {
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    height: parent.height / 2
                    name: icon
                    SlotsLayout.position: SlotsLayout.Trailing
                    SlotsLayout.overrideVerticalPositioning: true
                    width: height
                    visible: locationsListView.state === "default"
                }

                Label {
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    color: UbuntuColors.orange
                    elide: Text.ElideRight
                    font {
                        pixelSize: parent.height / 2
                        weight: Font.Light
                    }
                    horizontalAlignment: Text.AlignRight
                    SlotsLayout.position: SlotsLayout.Trailing
                    SlotsLayout.overrideVerticalPositioning: true
                    text: temp + settings.tempScale
                    visible: locationsListView.state === "default"
                }
            }
        }

        onReorder: {
            console.debug("Move: ", from, to);

            storage.moveLocation(from, to);
        }
    }

    LoadingIndicator {
        id: loadingIndicator
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
