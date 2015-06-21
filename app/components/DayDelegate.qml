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
import Ubuntu.Components.ListItems 0.1 as ListItem

ListItem.Standard {
    id: dayDelegate
    height: collapsedHeight

    property int collapsedHeight: units.gu(8)
    property int expandedHeight: collapsedHeight + units.gu(4) + extraInfoColumn.childrenRect.height

    property alias day: dayLabel.text
    property alias image: weatherImage.name
    property alias high: highLabel.text
    property alias low: lowLabel.text

    property alias chanceOfRain: chanceOfRainForecast.chance
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
        },
        State {
            name: "expanded"
            PropertyChanges {
                target: dayDelegate
                height: expandedHeight
            }
            PropertyChanges {
                target: expandedInfo
                opacity: 1
            }
        }
    ]

    transitions: [
        Transition {
            from: "normal"
            to: "expanded"
            SequentialAnimation {
                NumberAnimation {
                    easing.type: Easing.InOutQuad
                    properties: "height"
                }
                NumberAnimation {
                    easing.type: Easing.InOutQuad
                    properties: "opacity"
                }
            }
        },
        Transition {
            from: "expanded"
            to: "normal"
            SequentialAnimation {
                NumberAnimation {
                    easing.type: Easing.InOutQuad
                    properties: "opacity"
                }
                NumberAnimation {
                    easing.type: Easing.InOutQuad
                    properties: "height"
                }
            }
        }
    ]

    onClicked: {
        state = state === "normal" ? "expanded" : "normal"
        locationPages.collapseOtherDelegates(index)
    }

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


        Column {
            id: extraInfoColumn
            anchors {
                centerIn: parent
            }
            spacing: units.gu(2)

            // FIXME: extended-infomation_* aren't actually on device

            // Overview text
            Label {
                id: chanceOfRainForecast
                color: UbuntuColors.coolGrey
                fontSize: "x-large"
                horizontalAlignment: Text.AlignHCenter
                text: i18n.tr("Chance of rain")
                width: parent.width
                visible: false  // FIXME: add overview text eg "Chance of flurries"

                property int chance: 0
            }

            ForecastDetailsDelegate {
                id: windForecast
                forecast: i18n.tr("Winds")
                imageSource: "../graphics/extended-information_wind.svg"
            }

            ForecastDetailsDelegate {
                id: uvIndexForecast
                imageSource: "../graphics/extended-information_uv-level.svg"
                forecast: i18n.tr("UV Index")
            }

            ForecastDetailsDelegate {
                id: pollenForecast
                forecast: i18n.tr("Pollen")
                // FIXME: need icon
            }

            ForecastDetailsDelegate {
                id: humidityForecast
                forecast: i18n.tr("Humidity")
                imageSource: "../graphics/extended-information_humidity.svg"
            }

            ForecastDetailsDelegate {
                id: sunriseForecast
                forecast: i18n.tr("Sunrise")
                // FIXME: need icon
            }

            ForecastDetailsDelegate {
                id: sunsetForecast
                forecast: i18n.tr("Sunset")
                // FIXME: need icon
            }
        }
    }

    Component.onCompleted: {
        locationPages.collapseOtherDelegates.connect(function(otherIndex) {
            if (dayDelegate && typeof index !== "undefined" && otherIndex !== index) {
                state = "normal"
            }
        });
    }
}
