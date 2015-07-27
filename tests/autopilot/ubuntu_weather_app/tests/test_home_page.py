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


class TestHomePage(UbuntuWeatherAppTestCaseWithData):

    def setUp(self):
        super(TestHomePage, self).setUp()

    def test_add_location(self):
        """ tests adding a location via header action and selecting via
            searching for the location """

        # Get the start count of the homepage
        home_page = self.app.get_home_page()
        start_count = home_page.get_location_count()

        # Open the locations page from bottom edge
        home_page.reveal_bottom_edge_page()

        locations_page = self.app.get_locations_page()
        locations_page.visible.wait_for(True)

        # Select the add header action and get the add locations page
        locations_page.click_add_location_action()

        add_location_page = self.app.get_add_location_page()
        add_location_page.visible.wait_for(True)

        # Perform search
        add_location_page.search("Paris")

        # Select the location
        add_location_page.click_location(0)

        # Check locations page is now visible and go back
        self.assertThat(locations_page.visible, Eventually(Equals(True)))
        locations_page.click_back()

        # Check that the location was added
        self.assertThat(home_page.get_location_count,
                        Eventually(Equals(start_count + 1)))

        # Check homepage is now visible
        self.assertThat(home_page.visible, Eventually(Equals(True)))

    def test_locations_count_startup(self):
        """ tests that the correct number of locations appear at startup """

        home_page = self.app.get_home_page()

        self.assertThat(home_page.get_location_count, Eventually(Equals(2)))
