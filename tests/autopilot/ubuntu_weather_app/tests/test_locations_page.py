# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013, 2014, 2015, 2017 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Ubuntu Weather app autopilot tests."""

from __future__ import absolute_import

import logging
from autopilot.matchers import Eventually
from testtools.matchers import Equals
from testtools.matchers import NotEquals


from ubuntu_weather_app.tests import UbuntuWeatherAppTestCaseWithData

logger = logging.getLogger(__name__)


class TestLocationsPage(UbuntuWeatherAppTestCaseWithData):

    """ Tests for the locations page
        setUp jumps to locations page as all tests start from here """

    def setUp(self):
        super(TestLocationsPage, self).setUp()

        # Get the start count of the homepage
        self.home_page = self.app.get_home_page()
        self.start_count = self.home_page.get_location_count()

        # Open the locations page from bottom edge
        self.home_page.reveal_bottom_edge_page()

        self.locations_page = self.app.get_locations_page()
        self.locations_page.visible.wait_for(True)

    def test_removing_location_via_list_item_action(self):
        """ tests removing a location via the list item action """

        # Get the list item of the first location
        list_item = self.locations_page.get_location(0)

        # Check that the first location is London
        self.assertThat(list_item.get_name(), Equals("London"))

        # Remove the location via the list item action
        list_item.click_remove_action()

        # Check that the location was removed
        self.assertThat(self.home_page.get_location_count,
                        Eventually(Equals(self.start_count - 1)))

        # Get the list item of the first location
        list_item = self.locations_page.get_location(0)

        # Check that the first location is not London
        self.assertThat(list_item.get_name(), NotEquals("London"))

        # Go back to the homepage
        self.locations_page.click_back()

        # Check homepage is now visible
        self.assertThat(self.home_page.visible, Eventually(Equals(True)))

    def test_changing_location(self):
        """ tests changing the selected location """

        # Get the current index for the selected location
        current_index = self.home_page.get_selected_location_index()

        # Set the index of the location to be selected
        new_index = current_index + 1

        # Select the list item of the second location
        self.locations_page.click_location(new_index)

        # Check that the selected location is now the intended location
        self.assertThat(self.home_page.get_selected_location_index(),
                        Eventually(Equals(new_index)))

        # Check homepage is now visible
        self.assertThat(self.home_page.visible, Eventually(Equals(True)))
