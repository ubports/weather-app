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
from testtools.matchers import NotEquals, Equals


from ubuntu_weather_app.tests import UbuntuWeatherAppTestCaseWithData

logger = logging.getLogger(__name__)


class TestSettingsPage(UbuntuWeatherAppTestCaseWithData):

    """ Tests for the add locations page
        setUp jumps to add to locations page as all tests start from here """

    def setUp(self):
        super(TestSettingsPage, self).setUp()

        home_page = self.app.get_home_page()
        home_page.click_settings_button()

    def test_switch_temperature_units(self):
        settings_page = self.app.get_settings_page()
        settings_page.click_settings_page_listitem("Units")

        units_page = settings_page.get_units_page()
        units_page.expand_temperature_setting()

        previous_unit = units_page.get_selected_temperature_unit()
        units_page.change_temperature_unit()
        self.assertThat(previous_unit, Eventually(NotEquals(
            units_page.get_selected_temperature_unit())))

        units_page.click_back()
        settings_page.click_back()

        day_delegate = self.app.get_home_page().get_daydelegate(0, 0)
        self.assertThat(day_delegate.low.endswith(
            previous_unit), Equals(False))
        self.assertThat(day_delegate.high.endswith(
            previous_unit), Equals(False))
