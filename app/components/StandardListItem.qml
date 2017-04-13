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

ListItem {
    id: listItem

    property alias title: listitemlayout.title
    property alias icon: _icon

    // For autopilot
    readonly property bool iconVisible: icon.visible
    readonly property string titleValue: title.text

    height: listitemlayout.height + divider.height

    ListItemLayout {
        id: listitemlayout

        title.text: ""

        Icon {
            id: _icon
            height: units.gu(2); width: height
            name: "go-next"
            SlotsLayout.position: SlotsLayout.Last
        }
    }
}
