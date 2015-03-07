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


Page {
    title: i18n.tr("Refresh Interval")

    Flickable {
        anchors {
            fill: parent
        }
        height: parent.height
        contentHeight: unitsColumn.childrenRect.height

        Column {
            id: unitsColumn
            anchors {
                fill: parent
            }

            ListItem.ItemSelector {
                delegate: OptionSelectorDelegate {
                    text: Math.floor(modelData / 60).toString() + " " + i18n.tr("minutes")
                }
                expanded: true
                model: [600, 900, 1800, 3600]
                selectedIndex: model.indexOf(settings.refreshInterval)
                text: i18n.tr("Interval")

                onDelegateClicked: {
                    settings.refreshInterval = model[index]
                    refreshData(false, true)
                }
            }
        }
    }
}
