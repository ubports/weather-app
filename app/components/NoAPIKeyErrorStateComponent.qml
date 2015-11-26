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
import Ubuntu.Components 1.5
import "../components"


Rectangle {
    color: "white"
    anchors.fill: parent

    SettingsButton {
        anchors {
            right: parent.right
            top: parent.top
        }
    }

    Column {
        anchors {
            centerIn: parent
        }
        spacing: units.gu(4)
        width: parent.width - units.gu(4)

        Label {
            id: networkErrorStateLabel
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            fontSize: "x-large"
            text: i18n.tr("No API Keys Found")
            width: parent.width
            wrapMode: Text.WordWrap
        }

        Label {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            text: i18n.tr("If you are a developer, please see the README file for instructions on how to obtain your own Open Weather Map API key.")
            width: parent.width
            wrapMode: Text.WordWrap
        }
    }
}
