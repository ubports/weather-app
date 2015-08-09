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


class TestSettingsPage(UbuntuWeatherAppTestCaseWithData):

    """ Tests for the add locations page
        setUp jumps to add to locations page as all tests start from here """

    def setUp(self):
        super(TestSettingsPage, self).setUp()

    def test_switch_temperature_units(self):
        home_page = self.app.get_home_page()
        settings_page = home_page.click_settings_button()
        units_page = settings_page.get_units_page()
        previous_temperature_unit = units_page.get_temperature_unit()
        units_page.change_temperature_unit()

        self.assertThat(day_delegate.state, Eventually(Equals("expanded")))

