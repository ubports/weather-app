# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013, 2014, 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Ubuntu Weather app autopilot tests."""

from __future__ import absolute_import

import logging
from testtools.matchers import Equals


from ubuntu_weather_app.tests import UbuntuWeatherAppTestCaseWithData

logger = logging.getLogger(__name__)


class TestSettingsPage(UbuntuWeatherAppTestCaseWithData):

    """ Tests for the settings page
        setUp opens settings page as all tests start from here """

    def setUp(self):
        super(TestSettingsPage, self).setUp()

        # Get the home page and selected pane
        self.home_page = self.app.get_home_page()
        self.location_pane = self.home_page.get_selected_location_pane()

        # Get initial wind and temperature settings
        self.day_delegate = self.location_pane.get_day_delegate(0)
        self.initial_wind_unit = self.day_delegate.get_wind_unit()
        self.initial_temperature_unit = self.day_delegate.get_temperature_unit(
        )

        # Open and get the settings page
        self.location_pane.click_settings_button()
        self.settings_page = self.app.get_settings_page()

        # Click the units page
        self.settings_page.click_settings_page_listitem("units")

        # Get the units page
        self.units_page = self.settings_page.get_units_page()

    def test_switch_temperature_units(self):
        """ tests switching temperature units in Units page """

        # Check that the initial unit is F
        self.assertThat(self.initial_temperature_unit, Equals("F"))

        # Change the unit
        changed = self.units_page.change_listitem_unit("temperatureSetting")

        # Check that the new value is not the previously selected
        self.assertThat(changed, Equals(True))

        # Go back to the home page
        self.units_page.click_back()
        self.settings_page.click_back()

        # Reget the home page and selected pane as they have changed
        self.location_pane = self.home_page.get_selected_location_pane()
        self.day_delegate = self.location_pane.get_day_delegate(0)

        # Check that the unit is different to the starting unit
        self.assertThat(self.day_delegate.low.endswith(
            self.initial_temperature_unit), Equals(False))
        self.assertThat(self.day_delegate.high.endswith(
            self.initial_temperature_unit), Equals(False))

    def test_switch_wind_speed_units(self):
        """ tests switching wind speed unit in Units page """

        # Check that the initial unit is mph
        self.assertThat(self.initial_wind_unit, Equals("mph"))

        # Change the unit
        changed = self.units_page.change_listitem_unit("windSetting")

        # Check that the new value is not the previously selected
        self.assertThat(changed, Equals(True))

        # Go back to the home page
        self.units_page.click_back()
        self.settings_page.click_back()

        # Reget the home page and selected pane as they have changed
        self.location_pane = self.home_page.get_selected_location_pane()
        self.day_delegate = self.location_pane.get_day_delegate(0)

        # Check that the unit is different to the starting unit
        self.assertThat(self.day_delegate.get_wind_unit().endswith(
            self.initial_wind_unit), Equals(False))
