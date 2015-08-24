# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013, 2014, 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Ubuntu Weather app autopilot tests."""

from __future__ import absolute_import

import logging
from testtools.matchers import NotEquals, Equals


from ubuntu_weather_app.tests import UbuntuWeatherAppTestCaseWithData

logger = logging.getLogger(__name__)


class TestSettingsPage(UbuntuWeatherAppTestCaseWithData):

    """ Tests for the settings page
        setUp opens settings page as all tests start from here """

    def setUp(self):
        super(TestSettingsPage, self).setUp()

        self.home_page = self.app.get_home_page()
        self.home_page.click_settings_button()

    def test_switch_temperature_units(self):
        """ tests switching temperature units in Units page """
        unit_name = "temperatureSetting"

        # checking that the initial unit is  F
        self.assertThat(
            self._get_previous_display_unit(unit_name), Equals("F"))

        previous_unit = self._change_listitem_unit(unit_name)

        day_delegate = self.home_page.get_daydelegate(0, 0)
        self.assertThat(day_delegate.low.endswith(
            previous_unit), Equals(False))
        self.assertThat(day_delegate.high.endswith(
            previous_unit), Equals(False))

    def test_switch_wind_speed_units(self):
        """ tests switching wind speed unit in Units page """
        unit_name = "windSetting"

        # checking that the initial unit is
        self.assertThat(
            self._get_previous_display_unit(unit_name), Equals("mph"))

        previous_unit = self._change_listitem_unit(unit_name)

        day_delegate = self.home_page.get_daydelegate(0, 0)
        wind_unit = day_delegate.wind.split(" ", 1)

        self.assertThat(wind_unit[0].endswith(previous_unit), Equals(False))

    def _change_listitem_unit(self, unit_name):
        """ Common actions to change listitem unit for temperature and wind
            speed tests """
        settings_page = self.app.get_settings_page()
        settings_page.click_settings_page_listitem("Units")

        units_page = settings_page.get_units_page()
        units_page.expand_units_listitem(unit_name)

        previous_unit = units_page.get_expanded_listitem(
            unit_name, "True").title
        units_page.click_not_selected_listitem(unit_name)
        self.assertThat(previous_unit, NotEquals(
            units_page.get_expanded_listitem(unit_name, "True")))

        units_page.click_back()
        settings_page.click_back()
        return previous_unit

    def _get_previous_display_unit(self, unit_name):
        day_delegate = self.home_page.get_daydelegate(0, 0)
        if unit_name == "temperatureSetting":
            low_unit = day_delegate.low[-1:]
            high_unit = day_delegate.high[-1:]
            if low_unit == high_unit:
                return high_unit
        elif unit_name == "windSetting":
            wind_unit = day_delegate.wind.split(" ", 1)[0][-3:]
            return wind_unit
