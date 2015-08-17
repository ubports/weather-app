# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013, 2014, 2015 Canonical
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


class TestAddLocationPage(UbuntuWeatherAppTestCaseWithData):

    """ Tests for the add locations page
        setUp jumps to add to locations page as all tests start from here """

    def setUp(self):
        super(TestAddLocationPage, self).setUp()

        # Get the start count of the homepage
        self.home_page = self.app.get_home_page()
        self.start_count = self.home_page.get_location_count()

        # Open the locations page from bottom edge
        self.home_page.reveal_bottom_edge_page()

        self.locations_page = self.app.get_locations_page()
        self.locations_page.visible.wait_for(True)

        # Select the add header action and get the add locations page
        self.locations_page.click_add_location_action()

        # Get the add locations page
        self.add_location_page = self.app.get_add_location_page()
        self.add_location_page.visible.wait_for(True)

    def test_add_location_via_cache(self):
        """ tests adding a location via cached location list """

        # Select the location
        self.add_location_page.click_location(0)

        # Check locations page is now visible
        self.assertThat(self.locations_page.visible, Eventually(Equals(True)))

        # Get the list item of the added location
        list_item = self.locations_page.get_location(self.start_count)

        # Check that the name is correct
        self.assertThat(list_item.get_name(), Equals("Amsterdam"))

        # Go back to the homepage
        self.locations_page.click_back()

        # Check homepage is now visible
        self.assertThat(self.home_page.visible, Eventually(Equals(True)))

        # Check that the location was added
        self.assertThat(self.home_page.get_location_count,
                        Eventually(Equals(self.start_count + 1)))

    def test_add_location_via_search(self):
        """ tests adding a location via searching for the location """

        location_name = "Paris"

        # Perform search
        self.add_location_page.search(location_name)

        # Select the location
        self.add_location_page.click_location(0)

        # Check locations page is now visible
        self.assertThat(self.locations_page.visible, Eventually(Equals(True)))

        # Get the list item of the added location
        list_item = self.locations_page.get_location(self.start_count)

        # Check that the name is correct
        self.assertThat(list_item.get_name(), Equals(location_name))

        # Go back to the homepage
        self.locations_page.click_back()

        # Check homepage is now visible
        self.assertThat(self.home_page.visible, Eventually(Equals(True)))

        # Check that the location was added
        self.assertThat(self.home_page.get_location_count,
                        Eventually(Equals(self.start_count + 1)))

    def test_cancel_add_location(self):
        """ tests tapping the back button in the add location page """

        # Go back to the locations page
        self.add_location_page.click_back()

        # Go back to the homepage
        self.locations_page.click_back()

        # Check homepage is now visible
        self.assertThat(self.home_page.visible, Eventually(Equals(True)))

        # Check that the location count did not change
        self.assertThat(self.home_page.get_location_count,
                        Eventually(Equals(self.start_count)))

    def test_location_not_found(self):
        """ tests empty search results for new location """

        location_name = "UbuntuCity"

        # Check that the empty search results label is not visible
        self.assertThat(self.add_location_page.is_empty_label_visible(),
                        Equals(False))

        # Check that the number of results is not zero
        self.assertThat(self.add_location_page.get_results_count(),
                        NotEquals(0))

        # Perform search
        self.add_location_page.search(location_name)

        # Check that the empty search results label is visible
        self.assertThat(self.add_location_page.is_empty_label_visible(),
                        Eventually(Equals(True)))

        # Check that the number of results is zero
        self.assertThat(self.add_location_page.get_results_count(), Equals(0))
