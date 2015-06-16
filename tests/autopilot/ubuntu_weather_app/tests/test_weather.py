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


from ubuntu_weather_app.tests import UbuntuWeatherAppTestCase

logger = logging.getLogger(__name__)


class TestMainWindow(UbuntuWeatherAppTestCase):

    def setUp(self):
        super(TestMainWindow, self).setUp()

    def test_add_location_button(self):
        """ tests that the add location page is shown after the Add Location
            button is clicked """

        self.app.click_add_location_button()

        add_location_page = self.app.get_add_location_page()

        self.assertThat(add_location_page.visible, Eventually(Equals(True)))
