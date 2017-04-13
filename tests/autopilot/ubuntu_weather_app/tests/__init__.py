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
import sqlite3
import time
import logging

import fixtures
from ubuntu_weather_app import UbuntuWeatherApp
import ubuntu_weather_app

from autopilot import logging as autopilot_logging
from autopilot.matchers import Eventually
from testtools.matchers import Equals
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
            app_type='qt',
            emulator_base=ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase)

    @autopilot_logging.log_action(logger.info)
    def launch_test_installed(self):
        return self.launch_test_application(
            base.get_qmlscene_launch_command(),
            self.installed_location,
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
            # NOTE: path seems to be .local/share/QtProject/com.ubuntu.weather
            # now not .local/share/com.ubuntu.weather
            local_dir = os.path.join(
                temp_dir, '.local/share/QtProject/com.ubuntu.weather'
            )

            if (os.path.exists(local_dir)):
                shutil.rmtree(local_dir)

            # NOTE: path seems to be .config/QtProject/com.ubuntu.weather.conf
            # now not .config/com.ubuntu.weather/com.ubuntu.weather.conf
            local_path = os.path.join(
                temp_dir, '.config/QtProject/com.ubuntu.weather.conf'
            )

            if (os.path.exists(local_path)):
                os.remove(local_path)
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


class DatabaseMixin(object):

    """
    Helper functions for dealing with sqlite databases
    """

    def _execute_sql(self, statement):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        logger.debug("Executing sql")
        logger.debug(statement)
        cursor.execute(statement)
        conn.commit()
        conn.close()

    def add_locations_to_database(self, limit=None):
        locations = self.get_locations_data()
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        logger.debug("Adding locations to database")

        for loc_data in locations:
            db_exec = "INSERT INTO Locations(date, data) VALUES('{}', '{}')"
            cursor.execute(db_exec.format(
                int(time.time() * 1000), loc_data))
            conn.commit()

        conn.close()

    def clean_db(self):
        logger.debug("Removing existing database at %s" % self.db_dir)

        try:
            shutil.rmtree(self.db_dir)
        except OSError:
            logger.debug("Could not remove existing database")
            pass

    def create_blank_db(self):
        self.clean_db()

        # create blank db
        logger.debug("Creating blank db on filesystem %s" % self.db_dir)

        if not os.path.exists(self.app_dir):
            os.makedirs(self.app_dir)

        shutil.copytree(self.database_tmpl_dir, self.db_dir)

        self.assertThat(
            lambda: os.path.exists(self.db_path),
            Eventually(Equals(True)))

        # this needs to stay in sync with Storage.qml enties
        logger.debug("Creating locations and settings tables")
        self._execute_sql("CREATE TABLE IF NOT EXISTS Locations(id INTEGER "
                          "PRIMARY KEY AUTOINCREMENT, data TEXT, date TEXT)")

        self._execute_sql("CREATE TABLE IF NOT EXISTS settings(key TEXT "
                          "UNIQUE, value TEXT)")

    def get_locations_data(self):
        result = []
        json_files = [self.json_path + '/1.json', self.json_path + '/2.json']

        for path in json_files:
            with open(path) as fh:
                json_str = fh.read()
                result.append(json_str.strip())
                fh.close()

        return result

    def load_database_vars(self):
        # NOTE: path seems to be .local/share/QtProject/com.ubuntu.weather
        # now not .local/share/com.ubuntu.weather
        self.app_dir = os.path.join(
            os.environ.get('HOME'),
            ".local/share/QtProject/com.ubuntu.weather")
        self.database_tmpl_dir = os.path.join(
            os.path.dirname(ubuntu_weather_app.__file__),
            'databases')
        self.db_dir = os.path.join(self.app_dir, 'Databases')
        self.db_file = "34e1e542f2f083ff18f537b07a380071.sqlite"
        self.db_path = os.path.join(self.db_dir, self.db_file)

        self.json_path = os.path.abspath(
            os.path.join(os.path.dirname(__file__), '..', 'files'))


class LegacyDatabaseMixin(DatabaseMixin):
    def load_database_vars(self):
        # NOTE: path seems to be .local/share/QtProject/com.ubuntu.weather
        # now not .local/share/com.ubuntu.weather
        self.app_dir = os.path.join(
            os.environ.get('HOME'),
            ".local/share/QtProject/com.ubuntu.weather")
        self.database_tmpl_dir = os.path.join(
            os.path.dirname(ubuntu_weather_app.__file__),
            'databases', 'legacy')
        self.db_dir = os.path.join(self.app_dir, 'Databases')
        self.db_file = "34e1e542f2f083ff18f537b07a380071.sqlite"
        self.db_path = os.path.join(self.db_dir, self.db_file)

        self.json_path = os.path.abspath(
            os.path.join(os.path.dirname(__file__), '..', 'files', 'legacy'))


class SettingsMixin(object):

    """
    Helper functions for dealing with the settings file
    """

    def _create_settings_base(self, path):
        if not os.path.exists(self.settings_dir):
            os.makedirs(self.settings_dir)

        shutil.copyfile(path, self.settings_filepath)

        self.assertThat(
            lambda: os.path.exists(self.settings_filepath),
            Eventually(Equals(True)))

    def create_settings_for_migration(self):
        logger.debug("Creating settings with for migration")

        self._create_settings_base(self.settings_for_migration)

    def create_settings_with_location_added(self):
        logger.debug("Creating settings with location added")

        self._create_settings_base(self.settings_location_added)

    def load_settings_vars(self):
        self.db_dir = os.path.abspath(
            os.path.join(os.path.dirname(__file__), '..', 'databases'))
        # NOTE: path seems to be .config/QtProject/com.ubuntu.weather.conf
        # now not .config/com.ubuntu.weather/com.ubuntu.weather.conf
        self.settings_dir = os.path.join(
            os.environ.get('HOME'),
            ".config/QtProject")
        self.settings_filepath = os.path.join(self.settings_dir,
                                              'com.ubuntu.weather.conf')
        self.settings_location_added = os.path.join(self.db_dir,
                                                    "location_added.conf")
        self.settings_for_migration = os.path.join(self.db_dir,
                                                   "for_migration.conf")


class UbuntuWeatherAppTestCase(BaseTestCaseWithPatchedHome, DatabaseMixin,
                               SettingsMixin):

    """Base test case that launches the ubuntu-weather-app."""

    def setUp(self):
        super(UbuntuWeatherAppTestCase, self).setUp()

        self.load_database_vars()
        self.create_blank_db()

        self.load_settings_vars()
        self.create_settings_with_location_added()

        self.app = UbuntuWeatherApp(self.launcher())


class UbuntuWeatherAppTestCaseWithData(BaseTestCaseWithPatchedHome,
                                       DatabaseMixin,
                                       SettingsMixin):

    """Base test case that launches the ubuntu-weather-app with data."""

    def setUp(self):
        super(UbuntuWeatherAppTestCaseWithData, self).setUp()

        self.load_database_vars()
        self.create_blank_db()

        self.load_settings_vars()
        self.create_settings_with_location_added()

        logger.debug("Adding fake data to new database")
        self.add_locations_to_database()

        self.app = UbuntuWeatherApp(self.launcher())


class UbuntuWeatherAppTestCaseWithLegacyData(BaseTestCaseWithPatchedHome,
                                             LegacyDatabaseMixin,
                                             SettingsMixin):

    """Base test case that launches the ubuntu-weather-app with legacy data."""

    def setUp(self):
        super(UbuntuWeatherAppTestCaseWithLegacyData, self).setUp()

        self.load_database_vars()
        self.create_blank_db()

        self.load_settings_vars()
        self.create_settings_for_migration()

        logger.debug("Adding fake data to new database")
        self.add_locations_to_database()

        self.app = UbuntuWeatherApp(self.launcher())
