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

        # Check locations page is now visible and go back
        self.assertThat(self.locations_page.visible, Eventually(Equals(True)))
        self.locations_page.click_back()

        # Check that the location was added
        self.assertThat(self.home_page.get_location_count,
                        Eventually(Equals(self.start_count + 1)))

        # Check homepage is now visible
        self.assertThat(self.home_page.visible, Eventually(Equals(True)))

    def test_add_location_via_search(self):
        """ tests adding a location via searching for the location """

        # Perform search
        self.add_location_page.search("Paris")

        # Select the location
        self.add_location_page.click_location(0)

        # Check locations page is now visible and go back
        self.assertThat(self.locations_page.visible, Eventually(Equals(True)))
        self.locations_page.click_back()

        # Check that the location was added
        self.assertThat(self.home_page.get_location_count,
                        Eventually(Equals(self.start_count + 1)))

        # Check homepage is now visible
        self.assertThat(self.home_page.visible, Eventually(Equals(True)))
