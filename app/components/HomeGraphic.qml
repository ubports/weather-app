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

Item {
    height: units.gu(32)
    width: parent.width

    // TODO: will be on 'rails' (horizontal listview?) to reveal hourly forecast
    Image {
        anchors {
            fill: parent
        }

        Rectangle {
            anchors {
                fill: parent
            }
            color: "#F00"

            Label {
                anchors {
                    centerIn: parent
                }
                text: "IMAGE HERE!"
            }
        }
    }
}

