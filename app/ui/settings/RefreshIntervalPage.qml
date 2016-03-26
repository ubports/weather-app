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

Page {
    id: refreshIntervalPage

    header: PageHeader {
        title: i18n.tr("Refresh Interval")
    }

    ListModel {
        id: refreshModel
        Component.onCompleted: initialize()
        function initialize() {
            refreshModel.append({"interval": 600, "text": i18n.tr("%1 minute", "%1 minutes", 10).arg(10)})
            refreshModel.append({"interval": 900, "text": i18n.tr("%1 minute", "%1 minutes", 15).arg(15)})
            refreshModel.append({"interval": 1800, "text": i18n.tr("%1 minute", "%1 minutes", 30).arg(30)})
            refreshModel.append({"interval": 3600, "text": i18n.tr("%1 minute", "%1 minutes", 60).arg(60)})
        }
    }

    ExpandableListItem {
        id: dataProviderSetting

        anchors.top: refreshIntervalPage.header.bottom
        listViewHeight: refreshModel.count*units.gu(7) - units.gu(1)
        model: refreshModel
        title.text: i18n.tr("Interval")
        subText.text: i18n.tr("%1 minute", "%1 minutes", Math.floor(settings.refreshInterval / 60).toString()).arg(Math.floor(settings.refreshInterval / 60).toString())

        delegate: StandardListItem {
            title.text: model.text
            icon.name: "ok"
            icon.visible: settings.refreshInterval === model.interval
            onClicked: {
                settings.refreshInterval = model.interval
                refreshData(false, true)
            }
        }
    }
}
