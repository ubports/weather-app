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
import "../../components"
import "../../data/keys.js" as Keys

Page {
    id: dataProviderPage

    header: PageHeader {
        title: i18n.tr("Data Provider")
    }

    ListModel {
        id: dataProviderModel
        ListElement { text: "OpenWeatherMap" }
    }

    ExpandableListItem {
        id: dataProviderSetting

        anchors.top: dataProviderPage.header.bottom
        listViewHeight: dataProviderModel.count*units.gu(7) - units.gu(1)
        model: dataProviderModel
        title.text: i18n.tr("Provider")
        subText.text: settings.service === "weatherchannel" ? "The Weather Channel" : "OpenWeatherMap"

        delegate: StandardListItem {
            title.text: model.text
            icon.name: "ok"
            icon.visible: dataProviderSetting.subText.text === model.text
            onClicked: {
                if (model.text === "The Weather Channel") {
                    settings.service = "weatherchannel"
                } else {
                    settings.service = "openweathermap"
                }
                refreshData(false, true)
            }
        }
    }

    Component.onCompleted: {
        // If the key file for TWC is not blank, add the service to the model
        if (Keys.twcKey !== "") {
            dataProviderModel.append({ text: "The Weather Channel" })
        }
    }
}
