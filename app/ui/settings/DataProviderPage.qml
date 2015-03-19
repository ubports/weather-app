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
import "../../components"

Page {
    title: i18n.tr("Data Provider")

    ListModel {
        id: dataProviderModel
        ListElement { text: "openweathermap" }
        ListElement { text: "weatherchannel" }
    }

    ExpandableListItem {
        id: dataProviderSetting

        listViewHeight: dataProviderModel.count*units.gu(6) - units.gu(1)
        customModel: dataProviderModel
        headerTitle: i18n.tr("Provider")
        headerSubTitle: settings.service

        customDelegate: ListItem.Standard {
            text: model.text
            onClicked: {
                settings.service = model.text
                refreshData(false, true)
            }

            Icon {
                width: units.gu(2)
                height: width
                name: "ok"
                visible: settings.service === model.text
                anchors.right: parent.right
                anchors.rightMargin: units.gu(2)
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
