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
                temperatureModel.append({"text": i18n.tr("°C")})
                temperatureModel.append({"text": i18n.tr("°F")})
            }
        }

        ListModel {
            id: precipationModel
            Component.onCompleted: initialize()
            function initialize() {
                precipationModel.append({"text": i18n.tr("mm")})
                precipationModel.append({"text": i18n.tr("in")})
            }
        }

        ListModel {
            id: windSpeeModel
            Component.onCompleted: initialize()
            function initialize() {
                windSpeeModel.append({"text": i18n.tr("kmh")})
                windSpeeModel.append({"text": i18n.tr("mph")})
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
                subText: settings.tempScale

                delegate: ListItem.Standard {
                    text: model.text
                    onClicked: {
                        settings.tempScale = model.text
                        refreshData(true)
                    }

                    Icon {
                        width: units.gu(2)
                        height: width
                        name: "ok"
                        visible: settings.tempScale === model.text
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
                subText: settings.precipUnits

                delegate: ListItem.Standard {
                    text: model.text
                    onClicked: {
                        settings.precipUnits = model.text
                        refreshData(true)
                    }

                    Icon {
                        width: units.gu(2)
                        height: width
                        name: "ok"
                        visible: settings.precipUnits === model.text
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(2)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            ExpandableListItem {
                id: windSetting

                listViewHeight: windSpeeModel.count*units.gu(6) - units.gu(0.5)
                model: windSpeeModel
                text: i18n.tr("Wind Speed")
                subText: settings.windUnits

                delegate: ListItem.Standard {
                    text: model.text
                    onClicked: {
                        settings.windUnits = model.text
                        refreshData(true)
                    }

                    Icon {
                        width: units.gu(2)
                        height: width
                        name: "ok"
                        visible: settings.windUnits === model.text
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(2)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
