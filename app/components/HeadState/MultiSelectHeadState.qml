/*
 * Copyright (C) 2015, 2017
 *      Andrew Hayzen <ahayzen@gmail.com>
 *      Victor Thompson <victor.thompson@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3


State {
    id: selectionState
    name: "selection"

    property PageHeader thisHeader: PageHeader {
        flickable: thisPage.flickable
        leadingActionBar {
            actions: [
                Action {
                    text: i18n.tr("Cancel selection")
                    iconName: "back"
                    onTriggered: listview.closeSelection()
                }
            ]
        }
        title: i18n.tr("Locations")
        trailingActionBar {
            actions: [
                Action {
                    iconName: "select"
                    text: i18n.tr("Select All")
                    onTriggered: {
                        if (listview.getSelectedIndices().length === listview.model.count) {
                            listview.clearSelection()
                        } else {
                            listview.selectAll()
                        }
                    }
                },
                Action {
                    enabled: listview.getSelectedIndices().length > 0
                    iconName: "delete"
                    text: i18n.tr("Delete")
                    visible: removable

                    onTriggered: {
                        removed(listview.getSelectedIndices())

                        listview.closeSelection()
                    }
                }

            ]
        }
        visible: thisPage.state === "selection"
    }

    property ListView listview
    property bool removable: false
    property Page thisPage

    signal removed(var selectedIndices)

    PropertyChanges {
        target: thisPage
        header: thisHeader
    }
}
