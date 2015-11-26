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
import "../components"


Item {
    anchors {
        fill: parent
        margins: units.gu(2)
    }

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
            id: emptyStateLabel
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            horizontalAlignment: Text.AlignHCenter
            text: settings.detectCurrentLoaction
                  ? i18n.tr("Searching for current location...")
                  : i18n.tr("Cannot determine your location")
            width: parent.width
            wrapMode: Text.WordWrap
        }

        Label {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            horizontalAlignment: Text.AlignHCenter
            text: i18n.tr("Manually add a location by swiping up from the bottom of the display")
            width: parent.width
            wrapMode: Text.WordWrap
        }
    }
}
