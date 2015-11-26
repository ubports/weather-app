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
import Ubuntu.Components 1.3
import "../../components"

Page {
    title: i18n.tr("Units")
    property bool bug1341671workaround: true

    flickable: null

    Flickable {
        clip: true
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
            id: windSpeedModel
            Component.onCompleted: initialize()
            function initialize() {
                // TRANSLATORS: The strings are standard measurement units
                // of wind speed in kilometers per hour and are shown in the settings page.
                // Only the abbreviated form of kilometers per hour should be used.
                windSpeedModel.append({"text": i18n.tr("kph"), "value": "kph"})

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
                objectName: "temperatureSetting"

                listViewHeight: temperatureModel.count*units.gu(7) - units.gu(1)
                model: temperatureModel
                text: i18n.tr("Temperature")
                subText: settings.tempScale === "°C" ? i18n.tr("°C")
                                                     : i18n.tr("°F")

                delegate: StandardListItem {
                    title: model.text
                    icon: "ok"
                    showIcon: settings.tempScale === model.value
                    onClicked: {
                        settings.tempScale = model.value
                        refreshData(true)
                    }
                }
            }

            ExpandableListItem {
                id: windSetting
                objectName: "windSetting"

                listViewHeight: windSpeedModel.count*units.gu(7) - units.gu(1)
                model: windSpeedModel
                text: i18n.tr("Wind Speed")
                subText: settings.windUnits === "kph" ? i18n.tr("kph")
                                                      : i18n.tr("mph")

                delegate: StandardListItem {
                    title: model.text
                    icon: "ok"
                    showIcon: settings.windUnits === model.value
                    onClicked: {
                        settings.windUnits = model.value
                        refreshData(true)
                    }
                }
            }
        }
    }
}
