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

    def test_locations_count_startup(self):
        """ tests that the correct number of locations appear at startup """

        home_page = self.app.get_home_page()

        self.assertThat(home_page.get_location_count, Eventually(Equals(2)))

    def test_show_day_details(self):
        """ tests clicking on a day delegate to expand and contract it"""

        home_page = self.app.get_home_page()

        weekdaycolumn = 0
        day = 0
        day_delegate = home_page.get_daydelegate(weekdaycolumn, day)
        self.assertThat(day_delegate.state, Eventually(Equals("normal")))

        home_page.click_daydelegate(day_delegate)

        # Re-get daydelegate as change in loaders changes tree
        day_delegate = home_page.get_daydelegate(weekdaycolumn, day)

        day_delegate.height.wait_for(day_delegate.expandedHeight)
        self.assertThat(day_delegate.state, Eventually(Equals("expanded")))
        self.assertEqual(day_delegate.height, day_delegate.expandedHeight)
