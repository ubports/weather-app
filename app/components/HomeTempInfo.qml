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


Column {
    anchors {
        left: parent.left
        right: parent.right
    }
    spacing: units.gu(1)

    property alias description: descriptionLabel.text
    property alias high: highLabel.text
    property alias low: lowLabel.text
    property alias now: nowLabel.text

    Label {
        font.weight: Font.Light
        fontSize: "small"
        text: i18n.tr("Today")
    }

    Label {
        id: descriptionLabel
        font.weight: Font.Normal
        fontSize: "large"
    }

    Row {
        spacing: units.gu(2)

        Label {
            id: nowLabel
            color: UbuntuColors.orange
            font.pixelSize: units.gu(8)
            font.weight: Font.Light
            height: units.gu(8)
            verticalAlignment: Text.AlignBottom  // AlignBottom seems to put it at the top?
        }

        Column {
            Label {
                id: lowLabel
                font.weight: Font.Light
                fontSize: "medium"
            }

            Label {
                id: highLabel
                font.weight: Font.Light
                fontSize: "medium"
            }
        }
    }
}
