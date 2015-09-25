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


AbstractButton {
    id: settingsButton
    objectName: "settingsButton"
    height: width
    width: units.gu(4)

    onClicked: mainPageStack.push(Qt.resolvedUrl("../ui/SettingsPage.qml"))

    Rectangle {
        anchors.fill: parent
        color: Theme.palette.selected.background
        visible: parent.pressed
    }

    Icon {
        anchors.centerIn: parent
        color: UbuntuColors.darkGrey
        height: width
        name: "settings"
        width: units.gu(2.5)
    }
}
