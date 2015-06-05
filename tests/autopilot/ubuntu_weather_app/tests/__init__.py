# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2013, 2014, 2015 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

"""Weather app autopilot tests."""

import os
import os.path
import shutil
import logging

import fixtures
from ubuntu_weather_app import UbuntuWeatherApp

from autopilot import logging as autopilot_logging
from autopilot.testcase import AutopilotTestCase

import ubuntuuitoolkit
from ubuntuuitoolkit import base

logger = logging.getLogger(__name__)


class BaseTestCaseWithPatchedHome(AutopilotTestCase):

    """A common test case class that provides several useful methods for
    ubuntu-weather-app tests.

    """

    working_dir = os.getcwd()
    local_location_dir = os.path.dirname(os.path.dirname(working_dir))
    local_location = local_location_dir + "/app/ubuntu-weather-app.qml"
    installed_location = "/usr/share/ubuntu-weather-app/app/" \
        "ubuntu-weather-app.qml"

    def get_launcher_method_and_type(self):
        if os.path.exists(self.local_location):
            launch = self.launch_test_local
            test_type = 'local'
        elif os.path.exists(self.installed_location):
            launch = self.launch_test_installed
            test_type = 'deb'
        else:
            launch = self.launch_test_click
            test_type = 'click'
        return launch, test_type

    def setUp(self):
        super(BaseTestCaseWithPatchedHome, self).setUp()
        self.launcher, self.test_type = self.get_launcher_method_and_type()
        self.home_dir = self._patch_home()

    @autopilot_logging.log_action(logger.info)
    def launch_test_local(self):
        return self.launch_test_application(
            base.get_qmlscene_launch_command(),
            self.local_location,
            "debug",
            app_type='qt',
            emulator_base=ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase)

    @autopilot_logging.log_action(logger.info)
    def launch_test_installed(self):
        return self.launch_test_application(
            base.get_qmlscene_launch_command(),
            self.installed_location,
            "debug",
            app_type='qt',
            emulator_base=ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase)

    @autopilot_logging.log_action(logger.info)
    def launch_test_click(self):
        return self.launch_click_package(
            "com.ubuntu.weather",
            emulator_base=ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase)

    def _copy_xauthority_file(self, directory):
        """ Copy .Xauthority file to directory, if it exists in /home
        """
        # If running under xvfb, as jenkins does,
        # xsession will fail to start without xauthority file
        # Thus if the Xauthority file is in the home directory
        # make sure we copy it to our temp home directory

        xauth = os.path.expanduser(os.path.join(os.environ.get('HOME'),
                                   '.Xauthority'))
        if os.path.isfile(xauth):
            logger.debug("Copying .Xauthority to %s" % directory)
            shutil.copyfile(
                os.path.expanduser(os.path.join(os.environ.get('HOME'),
                                   '.Xauthority')),
                os.path.join(directory, '.Xauthority'))

    def _patch_home(self):
        """ mock /home for testing purposes to preserve user data
        """

        # if running on non-phablet device,
        # run in temp folder to avoid mucking up home
        # bug 1316746
        # bug 1376423
        if self.test_type is 'click':
            # just use home for now on devices
            temp_dir = os.environ.get('HOME')

            # before each test, remove the app's databases
            local_dir = os.path.join(temp_dir,
                                     '.local/share/com.ubuntu.weather')

            if (os.path.exists(local_dir)):
                shutil.rmtree(local_dir)

            local_dir = os.path.join(temp_dir, '.config/com.ubuntu.weather')

            if (os.path.exists(local_dir)):
                shutil.rmtree(local_dir)
        else:
            temp_dir_fixture = fixtures.TempDir()
            self.useFixture(temp_dir_fixture)
            temp_dir = temp_dir_fixture.path

            # before we set fixture, copy xauthority if needed
            self._copy_xauthority_file(temp_dir)
            self.useFixture(fixtures.EnvironmentVariable('HOME',
                                                         newvalue=temp_dir))

            logger.debug("Patched home to fake home directory %s" % temp_dir)
        return temp_dir


class UbuntuWeatherAppTestCase(BaseTestCaseWithPatchedHome):

    """Base test case that launches the ubuntu-weather-app."""

    def setUp(self):
        super(UbuntuWeatherAppTestCase, self).setUp()
        self.app = UbuntuWeatherApp(self.launcher())
