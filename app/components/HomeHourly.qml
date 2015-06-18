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

ListView {
    id: homeHourly

    clip:true
    height: parent ? parent.height : undefined
    width: parent ? parent.width : undefined
    model: forecasts.length
    orientation: ListView.Horizontal

    onVisibleChanged: {
        if(visible) {
            ListView.model = forecasts.length
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            homeGraphic.visible = true
        }
    }

    delegate: Item {
        id: delegate

        property var hourData: forecasts[index]

        height: parent.height
        width: childrenRect.width

        Column {
            id: hourColumn

            anchors.verticalCenter: parent.verticalCenter
            height: childrenRect.height
            width: units.gu(10)

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                fontSize: "small"
                font.weight: Font.Light
                text: formatTimestamp(hourData.date, 'ddd')+" "+formatTime(hourData.date, 'h:mm')
            }

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                height: units.gu(7)
                width: units.gu(7)

                Icon {
                    anchors {
                        fill: parent
                        margins: units.gu(0.5)
                    }
                    color: UbuntuColors.orange
                    name: (hourData.icon !== undefined && iconMap[hourData.icon] !== undefined) ? iconMap[hourData.icon] : ""
                }
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: units.gu(3)
                font.weight: Font.Light
                text: Math.round(hourData[tempUnits].temp).toString()+settings.tempScale
            }
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            color: UbuntuColors.darkGrey
            height: hourColumn.height
            opacity: 0.2
            visible: index > 0
            width: units.gu(0.1)
        }
    }
}

