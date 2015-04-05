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
import "../../components"

Page {
    title: i18n.tr("Units")

    flickable: null

    Flickable {
        anchors.fill: parent
        height: parent.height
        contentHeight: unitsColumn.childrenRect.height

        ListModel {
            id: temperatureModel
            Component.onCompleted: initialize()
            function initialize() {
                // TRANSLATORS: The strings are standard measurement units
                // of temperature in Celcius and are shown in the settings page.
                // Only the abbreviated form of Celcius should be used.
                temperatureModel.append({"text": i18n.tr("°C"), "value": "°C"})

                // TRANSLATORS: The strings are standard measurement units
                // of temperature in Fahrenheit and are shown in the settings page.
                // Only the abbreviated form of Fahrenheit should be used.
                temperatureModel.append({"text": i18n.tr("°F"), "value": "°F"})
            }
        }

        ListModel {
            id: precipationModel
            Component.onCompleted: initialize()
            function initialize() {
                // TRANSLATORS: The strings are standard measurement units
                // of precipitation in millimeters and are shown in the settings page.
                // Only the abbreviated form of millimeters should be used.
                precipationModel.append({"text": i18n.tr("mm"), "value": "mm"})

                // TRANSLATORS: The strings are standard measurement units
                // of precipitation in inches and are shown in the settings page.
                // Only the abbreviated form of inches should be used.
                precipationModel.append({"text": i18n.tr("in"), "value": "in"})
            }
        }

        ListModel {
            id: windSpeedModel
            Component.onCompleted: initialize()
            function initialize() {
                // TRANSLATORS: The strings are standard measurement units
                // of wind speed in kilometers per hour and are shown in the settings page.
                // Only the abbreviated form of kilometers per hour should be used.
                windSpeedModel.append({"text": i18n.tr("kmh"), "value": "kmh"})

                // TRANSLATORS: The strings are standard measurement units
                // of wind speed in miles per hour and are shown in the settings page.
                // Only the abbreviated form of miles per hour should be used.
                windSpeedModel.append({"text": i18n.tr("mph"), "value": "mph"})
            }
        }

        Column {
            id: unitsColumn
            anchors.fill: parent

            ExpandableListItem {
                id: temperatureSetting

                listViewHeight: temperatureModel.count*units.gu(6) - units.gu(0.5)
                model: temperatureModel
                text: i18n.tr("Temperature")
                subText: settings.tempScale === "°C" ? i18n.tr("°C")
                                                     : i18n.tr("°F")

                delegate: ListItem.Standard {
                    text: model.text
                    onClicked: {
                        settings.tempScale = model.value
                        refreshData(true)
                    }

                    Icon {
                        width: units.gu(2)
                        height: width
                        name: "ok"
                        visible: settings.tempScale === model.value
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(2)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            ExpandableListItem {
                id: precipationSetting

                listViewHeight: precipationModel.count*units.gu(6) - units.gu(0.5)
                model: precipationModel
                text: i18n.tr("Precipitation")
                subText: settings.precipUnits === "mm" ? i18n.tr("mm")
                                                       : i18n.tr("in")

                delegate: ListItem.Standard {
                    text: model.text
                    onClicked: {
                        settings.precipUnits = model.value
                        refreshData(true)
                    }

                    Icon {
                        width: units.gu(2)
                        height: width
                        name: "ok"
                        visible: settings.precipUnits === model.value
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(2)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            ExpandableListItem {
                id: windSetting

                listViewHeight: windSpeedModel.count*units.gu(6) - units.gu(0.5)
                model: windSpeedModel
                text: i18n.tr("Wind Speed")
                subText: settings.windUnits === "kmh" ? i18n.tr("kmh")
                                                      : i18n.tr("mph")

                delegate: ListItem.Standard {
                    text: model.text
                    onClicked: {
                        settings.windUnits = model.value
                        refreshData(true)
                    }

                    Icon {
                        width: units.gu(2)
                        height: width
                        name: "ok"
                        visible: settings.windUnits === model.value
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(2)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
