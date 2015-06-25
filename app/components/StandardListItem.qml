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
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.2

ListItem {
    id: listItem

    property alias title: _title.text
    property alias icon: _icon.name
    property alias showIcon: _icon.visible

    RowLayout {
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: units.gu(2) }
        height: _icon.height
        spacing: units.gu(2)
        
        Label {
            id: _title
            anchors.verticalCenter: _icon.verticalCenter
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
        
        Icon {
            id: _icon
            height: units.gu(2); width: height
            name: "go-next"
        }
    }
}
