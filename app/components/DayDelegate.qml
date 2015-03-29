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

ListItem.Standard {
    id: dayDelegate
    height: collapsedHeight

    // TODO: will expand when clicked to reveal more info

    property Flickable flickable
    property int collapsedHeight: units.gu(8)
    property int expandedHeight: units.gu(12) + extraInfoColumn.childrenRect.height

    property alias day: dayLabel.text
    property alias image: weatherImage.name
    property alias high: highLabel.text
    property alias low: lowLabel.text

    property alias chanceOfRain: chanceOfRainForecast.value
    property alias humidity: humidityForecast.value
    property alias pollen: pollenForecast.value
    property alias sunrise: sunriseForecast.value
    property alias sunset: sunsetForecast.value
    property alias wind: windForecast.value
    property alias uvIndex: uvIndexForecast.value

    // Standard divider is not full width so add a ThinDivider to the bottom
    showDivider: false

    state: "normal"
    states: [
        State {
            name: "normal"
            PropertyChanges {
                target: dayDelegate
                height: collapsedHeight
            }
            StateChangeScript {
                script: flickable.contentHeight -= expandedHeight - collapsedHeight
            }
        },
        State {
            name: "expanded"
            PropertyChanges {
                target: dayDelegate
                height: expandedHeight
            }
            StateChangeScript {
                script: flickable.contentHeight += expandedHeight - collapsedHeight
            }
            PropertyChanges {
                target: expandedInfo
                opacity: 1
            }
        }
    ]

    transitions: [
        Transition {
            NumberAnimation {
                easing.type: Easing.InOutQuad
                properties: "height, opacity"
            }
        }
    ]

    onClicked: state = state === "normal" ? "expanded" : "normal"

    ListItem.ThinDivider {
        anchors {
            bottom: parent.bottom
        }
    }

    Label {
        id: dayLabel
        anchors {
            left: parent.left
            right: weatherImage.left
            rightMargin: units.gu(1)
            top: parent.top
            topMargin: (collapsedHeight - dayLabel.height) / 2
        }
        elide: Text.ElideRight
        font.weight: Font.Light
        fontSize: "medium"
    }

    Icon {
        id: weatherImage
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: dayLabel.verticalCenter
        }
        height: units.gu(3)
        width: units.gu(3)
    }

    Label {
        id: lowLabel
        anchors {
            left: weatherImage.right
            right: highLabel.left
            rightMargin: units.gu(1)
            verticalCenter: dayLabel.verticalCenter
        }
        elide: Text.ElideRight
        font.pixelSize: units.gu(2)
        font.weight: Font.Light
        fontSize: "medium"
        height: units.gu(2)
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignTop  // AlignTop appears to align bottom?
    }

    Label {
        id: highLabel
        anchors {
            bottom: lowLabel.bottom
            right: parent.right
        }
        color: UbuntuColors.orange
        elide: Text.ElideRight
        font.pixelSize: units.gu(3)
        font.weight: Font.Normal
        height: units.gu(3)
        verticalAlignment: Text.AlignTop  // AlignTop appears to align bottom?
    }

    Item {
        id: expandedInfo
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            top: dayLabel.bottom
            topMargin: units.gu(2)
        }
        opacity: 0
        visible: opacity !== 0

        // TODO: add overview text eg "Chance of flurries"

        Column {
            id: extraInfoColumn
            anchors {
                centerIn: parent
            }
            spacing: units.gu(2)

            ForecastDetailsDelegate {
                id: chanceOfRainForecast
                forecast: i18n.tr("Chance of rain")
            }

            ForecastDetailsDelegate {
                id: windForecast
                forecast: i18n.tr("Winds")
            }

            ForecastDetailsDelegate {
                id: uvIndexForecast
                forecast: i18n.tr("UV Index")
            }

            ForecastDetailsDelegate {
                id: pollenForecast
                forecast: i18n.tr("Pollen")
            }

            ForecastDetailsDelegate {
                id: humidityForecast
                forecast: i18n.tr("Humidity")
            }

            ForecastDetailsDelegate {
                id: sunriseForecast
                forecast: i18n.tr("Sunrise")
            }

            ForecastDetailsDelegate {
                id: sunsetForecast
                forecast: i18n.tr("Sunset")
            }
        }
    }
}
