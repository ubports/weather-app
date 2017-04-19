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
import Ubuntu.Components 1.3

Rectangle {
    id: indicator
    objectName: "processingIndicator"
    height: units.dp(3)
    color: "white"
    opacity: 0
    visible: opacity > 0

    property bool processing: false

    Behavior on opacity {
        UbuntuNumberAnimation { duration: UbuntuAnimation.FastDuration }
    }

    onProcessingChanged: {
        if (processing) delay.start();
        else if (!persist.running) indicator.opacity = 0;
    }

    Timer {
        id: delay
        interval: 200
        onTriggered: if (indicator.processing) {
            persist.restart();
            indicator.opacity = 1;
        }
    }

    Timer {
        id: persist
        interval: 2 * UbuntuAnimation.SleepyDuration - UbuntuAnimation.FastDuration
        onTriggered: if (!indicator.processing) indicator.opacity = 0
    }

    Rectangle {
        id: orange
        anchors { top: parent.top;  bottom: parent.bottom }
        width: parent.width / 4
        color: UbuntuColors.orange

        SequentialAnimation {
            running: indicator.visible
            loops: Animation.Infinite
            XAnimator {
                from: -orange.width / 2
                to: indicator.width - orange.width / 2
                duration: UbuntuAnimation.SleepyDuration
                easing.type: Easing.InOutSine
                target: orange
            }
            XAnimator {
                from: indicator.width - orange.width / 2
                to: -orange.width / 2
                duration: UbuntuAnimation.SleepyDuration
                easing.type: Easing.InOutSine
                target: orange
            }
        }
    }
}
