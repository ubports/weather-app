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

        self.home_page = self.app.get_home_page()
        self.locations_page = self.app.get_locations_page()

    def test_locations_count_startup(self):
        """ tests that the correct number of locations appear at startup """

        self.assertThat(self.home_page.get_location_count,
                        Eventually(Equals(2)))

    def test_show_day_details(self):
        """ tests clicking on a day delegate to expand and contract it"""

        day = 0

        # Get the first day delegate in the selected pane
        location_pane = self.home_page.get_selected_location_pane()
        day_delegate = location_pane.get_day_delegate(day)

        # Check that the extra info is not shown
        self.assertThat(day_delegate.state, Eventually(Equals("normal")))

        # Click the delegate to show the extra info
        location_pane.click_day_delegate(day)

        # Re-get daydelegate as change in loaders changes tree
        day_delegate = location_pane.get_day_delegate(day)

        # Wait for the height of the delegate to grow
        # Re-get the delegate in the wait as the expandedHeight changes
        day_delegate.height.wait_for(
            location_pane.get_day_delegate(day).expandedHeight)

        # Check that the state and height of the delegate have changed
        self.assertThat(day_delegate.state, Eventually(Equals("expanded")))
        self.assertEqual(day_delegate.height, day_delegate.expandedHeight)

    def test_show_today_details(self):
        """tests clicking on the today info to expand and contract it"""

        # Get the HomeTempInfo component from the selected pane
        location_pane = self.home_page.get_selected_location_pane()
        home_temp_info = location_pane.get_home_temp_info()

        # Check that the extra info is not shown
        self.assertThat(home_temp_info.state, Eventually(Equals("normal")))

        # Click the HomeTempInfo to show the extra info
        location_pane.click_home_temp_info()

        # Re-get HomeTempInfo as change in loaders changes tree
        home_temp_info = location_pane.get_home_temp_info()

        # Wait for the height of the HomeTempInfo to grow
        # Re-get the home temp info in the wait as the expandedHeight changes
        home_temp_info.height.wait_for(
            location_pane.get_home_temp_info().expandedHeight)

        # Check that the state and height of the HomeTempInfo have changed
        self.assertThat(home_temp_info.state, Eventually(Equals("expanded")))
        self.assertEqual(home_temp_info.height, home_temp_info.expandedHeight)

    def test_swiping_locations(self):
        """tests swiping between the location tabs"""

        # Define the start and stop locations of the left swipe
        start_x = (self.home_page.globalRect.x +
                   (self.home_page.globalRect.width * 0.9))
        stop_x = (self.home_page.globalRect.x +
                  (self.home_page.globalRect.width * 0.1))
        start_y = stop_y = (self.home_page.globalRect.y +
                            (self.home_page.globalRect.height * 0.5))
        rate = 5

        # Get the current index for the selected location
        # initial_index = self.home_page.get_selected_location_index()

        # Set the index of the location to be selected
        # new_index = initial_index + 1

        # Swipe to the left to switch Location tabs
        self.home_page.swipe(start_x, start_y, stop_x, stop_y, rate)

        # Check that the selected location is now the intended location
        self.assertThat(self.home_page.get_selected_location_index(),
                        Eventually(Equals(1)))
        self.assertThat(
                            self.locations_page.get_location(1).get_name(),
                            Equals('Washington'))

        # Reassign values of the swipe locations to swipe to the right
        start_x = (self.home_page.globalRect.x +
                   (self.home_page.globalRect.width * 0.1))
        stop_x = (self.home_page.globalRect.x +
                  (self.home_page.globalRect.width * 0.9))

        # Swipe to the right
        self.home_page.swipe(start_x, start_y, stop_x, stop_y, rate)

        # Check that the selected location is now the intended location
        self.assertThat(self.home_page.get_selected_location_index(),
                        Eventually(Equals(0)))
        self.assertThat(
                            self.locations_page.get_location(0).get_name(),
                            Equals('London'))
