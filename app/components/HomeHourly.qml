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
import QtGraphicalEffects 1.0

Item {
    id: homeHourly

    onVisibleChanged: {
        if(visible) {
            ListView.model = forecasts.length
        }
    }

    ListView {
        id: hourlyForecasts
        width:parent.width
        height:parent.height
        model: forecasts.length
        orientation: ListView.Horizontal
        clip:true
        MouseArea {
            anchors.fill: parent
            onClicked: {
                homeGraphic.visible = true
            }
        }
        delegate: Rectangle {
            width: childrenRect.width
            height: parent.height
            property var hourData: forecasts[index]
            Column {
                id: hourColumn
                width: units.gu(10)
                height: childrenRect.height
                anchors.verticalCenter: parent.verticalCenter
                Label {
                    text: formatTimestamp(hourData.date, 'ddd')+" "+formatTime(hourData.date, 'h:mm')
                    fontSize: "small"
                    font.weight: Font.Light
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Item {
                    width: units.gu(7)
                    height: units.gu(7)
                    anchors.horizontalCenter: parent.horizontalCenter
                    Image {
                        id: iconImage
                        fillMode: Image.PreserveAspectFit
                        anchors.fill: parent
                        source: (hourData.icon !== undefined && iconMap[hourData.icon] !== undefined) ? iconMap[hourData.icon] : ""
                    }
                    ColorOverlay {
                        anchors.fill: iconImage
                        source: iconImage
                        color: UbuntuColors.orange
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                Label {
                    font.pixelSize: units.gu(3)
                    font.weight: Font.Light
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Math.round(hourData[tempUnits].temp).toString()+settings.tempScale
                }

            }
            Rectangle {
                width: units.gu(0.1)
                height: hourColumn.height
                color: UbuntuColors.darkGrey
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
