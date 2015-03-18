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

ListItem.Standard {
    height: units.gu(8)

    // TODO: will expand when clicked to reveal more info

    property alias day: dayLabel.text
    property alias image: weatherImage.name
    property alias high: highLabel.text
    property alias low: lowLabel.text

    // Standard divider is not full width so add a ThinDivider to the bottom
    showDivider: false

    ListItem.ThinDivider {
        anchors {
            bottom: parent.bottom
        }
    }

    Label {
        id: dayLabel
        anchors {
            left: parent.left
            right: weatherImage.left
            rightMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
        }
        elide: Text.ElideRight
        font.weight: Font.Light
        fontSize: "medium"
    }

    Icon {
        id: weatherImage
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        height: units.gu(3)
        width: units.gu(3)
    }

    Label {
        id: lowLabel
        anchors {
            left: weatherImage.right
            right: highLabel.left
            rightMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
        }
        elide: Text.ElideRight
        font.pixelSize: units.gu(2)
        font.weight: Font.Light
        fontSize: "medium"
        height: units.gu(2)
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignTop  // AlignTop appears to align bottom?
    }

    Label {
        id: highLabel
        anchors {
            bottom: lowLabel.bottom
            right: parent.right
        }
        color: UbuntuColors.orange
        elide: Text.ElideRight
        font.pixelSize: units.gu(3)
        font.weight: Font.Normal
        height: units.gu(3)
        verticalAlignment: Text.AlignTop  // AlignTop appears to align bottom?
    }
}
