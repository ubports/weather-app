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

    def test_home_page_start(self):
        """ tests that the home page is shown on startup"""

        home_page = self.app.get_home_page()

        self.assertThat(home_page.visible, Eventually(Equals(True)))
