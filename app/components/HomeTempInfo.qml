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

Item {
    id: homeTempInfoItem
    anchors {
        left: parent.left
        right: parent.right
    }
    clip: true
    height: collapsedHeight
    objectName: "homeTempInfo"
    state: "normal"
    states: [
        State {
            name: "normal"
            PropertyChanges {
                target: homeTempInfoItem
                height: collapsedHeight
            }
            PropertyChanges {
                target: expandedInfo
                opacity: 0
            }
        },
        State {
            name: "expanded"
            PropertyChanges {
                target: homeTempInfoItem
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
                ScriptAction {
                    script: expandedInfo.active = true
                }
                NumberAnimation {
                    easing.type: Easing.InOutQuad
                    properties: "height,opacity"
                }
            }
        },
        Transition {
            from: "expanded"
            to: "normal"
            SequentialAnimation {
                NumberAnimation {
                    easing.type: Easing.InOutQuad
                    properties: "height,opacity"
                }
                ScriptAction {
                    script: expandedInfo.active = false
                }
            }
        }
    ]

    property int collapsedHeight: units.gu(12)
    property int expandedHeight: collapsedHeight + units.gu(4) + (expandedInfo.item ? expandedInfo.item.height : 0)

    property var modelData

    property alias now: nowLabel.text

    Column {
        id: labelColumn
        anchors {
            left: parent.left
            right: parent.right
        }
        spacing: units.gu(1)

        Label {
            font.weight: Font.Light
            fontSize: "small"
            text: i18n.tr("Today")
        }

        Label {
            id: descriptionLabel
            font.capitalization: Font.Capitalize
            font.weight: Font.Normal
            fontSize: "large"
            text: modelData.condition
        }

        Row {
            spacing: units.gu(2)

            Label {
                id: nowLabel
                color: UbuntuColors.orange
                font.pixelSize: units.gu(8)
                font.weight: Font.Light
                height: units.gu(8)
                verticalAlignment: Text.AlignBottom  // AlignBottom seems to put it at the top?
            }

            Column {
                Label {
                    id: lowLabel
                    font.weight: Font.Light
                    fontSize: "medium"
                    text: modelData.low
                }

                Label {
                    id: highLabel
                    font.weight: Font.Light
                    fontSize: "medium"
                    text: modelData.high
                }
            }
        }
    }

    Loader {
        id: expandedInfo
        active: false
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
            top: labelColumn.bottom
            topMargin: units.gu(2)
        }
        asynchronous: true
        opacity: 0
        source: "DayDelegateExtraInfo.qml"

        property var modelData: todayData || ({})
    }

    MouseArea {
        anchors {
            fill: parent
        }
        onClicked: parent.state = parent.state === "normal" ? "expanded" : "normal"
    }

    Behavior on height {
        NumberAnimation {
            easing.type: Easing.InOutQuad
        }
    }
}

