# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013, 2014, 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Ubuntu Weather app autopilot tests."""

from __future__ import absolute_import

from autopilot.matchers import Eventually
from testtools.matchers import Equals


from ubuntu_weather_app.tests import UbuntuWeatherAppTestCaseWithLegacyData


class TestMigration(UbuntuWeatherAppTestCaseWithLegacyData):

    def setUp(self):
        super(TestMigration, self).setUp()

    def test_locations_count_startup(self):
        """ tests that the correct number of migrated locations appear """

        home_page = self.app.get_home_page()

        # Check that the count is the same as expected
        self.assertThat(home_page.get_location_count, Eventually(Equals(2)))

    def test_locations_page(self):
        """ tests that the correct locations are in the list """

        # Open the locations page from bottom edge
        home_page = self.app.get_home_page()
        home_page.reveal_bottom_edge_page()

        locations_page = self.app.get_locations_page()
        locations_page.visible.wait_for(True)

        # Check that the locations are correct
        self.assertThat(locations_page.get_location(0).get_name,
                        Eventually(Equals("Hamburg")))
        self.assertThat(locations_page.get_location(1).get_name,
                        Eventually(Equals("London")))

    # TODO: once units test land add tests for testing migrated settings
