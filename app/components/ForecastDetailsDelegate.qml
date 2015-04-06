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

Row {
    height: icon.height
    spacing: units.gu(2)
    visible: value !== ""

    property alias imageSource: icon.source
    property alias forecast: forecastLabel.text
    property alias value: forecastValue.text
    
    Icon {
        id: icon
        color: "#000"
        height: units.gu(2)
        width: height
    }
    
    Label {
        id: forecastLabel
        elide: Text.ElideRight
        width: units.gu(8)
    }
    
    Label {
        id: forecastValue
        width: units.gu(10)
    }
}
