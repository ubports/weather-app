/*
 * Copyright (C) 2015-2016 Canonical Ltd
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

Page {
    id: settingsPage

    header: PageHeader {
        title: i18n.tr("Settings")
    }

    property bool bug1341671workaround: true

    Column {
        id: settingsColumn

        anchors {
            top: settingsPage.header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        ListItem {
            objectName: "units"

            ListItemLayout {
                title.text: i18n.tr("Units")
                ProgressionSlot{}
            }
            onClicked: mainPageStack.push(Qt.resolvedUrl("settings/UnitsPage.qml"))
        }

        ListItem {
            ListItemLayout {
                title.text: i18n.tr("Data Provider")
                ProgressionSlot{}
            }
            onClicked: mainPageStack.push(Qt.resolvedUrl("settings/DataProviderPage.qml"))
        }

        ListItem {
            ListItemLayout {
                title.text: i18n.tr("Refresh Interval")
                ProgressionSlot{}
            }
            onClicked: mainPageStack.push(Qt.resolvedUrl("settings/RefreshIntervalPage.qml"))
        }

        ListItem {
            ListItemLayout {
                title.text: i18n.tr("Location")
                ProgressionSlot{}
            }
            onClicked: mainPageStack.push(Qt.resolvedUrl("settings/LocationPage.qml"))
        }
    }
}
