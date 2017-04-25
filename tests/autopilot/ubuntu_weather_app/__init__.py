# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013, 2014, 2015, 2017 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""ubuntu-weather-app tests and emulators - top level package."""
from autopilot.introspection import dbus
import logging
from ubuntuuitoolkit import (MainView, QQuickListView, UCListItem,
                             UbuntuUIToolkitCustomProxyObjectBase)

logger = logging.getLogger(__name__)


class UbuntuWeatherAppException(Exception):
    """Exception raised when there's an error in the Weather App."""


def click_object(func):
    """Wrapper which clicks the returned object"""
    def func_wrapper(self, *args, **kwargs):
        item = func(self, *args, **kwargs)
        self.pointing_device.click_object(item)
        return item

    return func_wrapper

#
# Base helpers
#


class UbuntuWeatherApp(object):
    """Autopilot helper object for the Weather application."""

    def __init__(self, app_proxy):
        self.app = app_proxy

        # FIXME: Select by objectName due to it being MainView12 not MainView
        # pad.lv/1350532
        self.main_view = self.app.wait_select_single(objectName="weather")

    def get_add_location_page(self):
        return self.main_view.wait_select_single(
            AddLocationPage, objectName="addLocationPage")

    def get_home_page(self):
        return self.main_view.wait_select_single(
            HomePage, objectName="homePage")

    def get_locations_page(self):
        return self.main_view.wait_select_single(
            LocationsPage, objectName="locationsPage")

    def get_settings_page(self):
        return self.main_view.wait_select_single(SettingsPage, visible=True)


class Page(UbuntuUIToolkitCustomProxyObjectBase):
    """Autopilot helper for Pages."""
    def __init__(self, *args, **kwargs):
        super(Page, self).__init__(*args, **kwargs)

        # Use only objectName due to bug 1350532 as it is MainView12
        self.main_view = self.get_root_instance().select_single(
            objectName="weather")

    @click_object
    def click_back(self):
        return self.wait_select_single(
            "UCAbstractButton", objectName="pagestack_back_action_button",
            visible=True,
        )


#
# Helpers for specific objects
#


class AddLocationPage(Page):
    """Autopilot helper for AddLocationPage."""
    def __init__(self, *args, **kwargs):
        super(AddLocationPage, self).__init__(*args, **kwargs)

    @click_object
    def click_back(self):
        return self.wait_select_single(
            "UCAbstractButton", objectName="pagestack_back_action_button",
            visible=True,
        )

    @click_object
    def click_location(self, index):
        return self.select_single("UCListItem",
                                  objectName="addLocation" + str(index))

    def click_search_action(self):
        return self.wait_select_single(
            "ActionBar", objectName="addLocationTrailingActionBar",
            visible=True,
        ).click_action_button("search")

    def get_results_count(self):
        return self.wait_select_single(
            "QQuickListView", objectName="locationList").count

    def get_search_field(self):
        return self.select_single("TextField", objectName="searchField")

    def is_empty_label_visible(self):
        return self.select_single("UCLabel", objectName="noCity").visible

    def search(self, value):
        self.click_search_action()

        search_field = self.get_search_field()
        search_field.write(value)

        # Wait for model to finish loading
        self.searching.wait_for(False)


class DayDelegate(UbuntuUIToolkitCustomProxyObjectBase):
    @click_object
    def click_self(self):
        return self

    def get_extra_info(self):
        """Expand the delegate and get the extra info"""
        self.click_self()

        return self.wait_select_single(DayDelegateExtraInfo,
                                       objectName="dayDelegateExtraInfo",
                                       visible=True)

    def get_temperature_unit(self):
        # Get last character of the high temperature eg C in 42C
        return self.high[-1:]

    def get_wind_unit(self):
        day_delegate_extra_info = self.get_extra_info()

        # Get the last 3 characters of the wind speed portion of the string.
        # For instance, "kph" in "8kph SW".
        return day_delegate_extra_info.wind.split(" ", 1)[0][-3:]


class DayDelegateExtraInfo(UbuntuUIToolkitCustomProxyObjectBase):
    @property
    def wind(self):
        return self.select_single("ForecastDetailsDelegate",
                                  objectName="windForecast").value


class HomePage(Page):
    """Autopilot helper for HomePage."""
    def __init__(self, *args, **kwargs):
        super(HomePage, self).__init__(*args, **kwargs)

    def get_location_count(self):
        return self.get_location_pages().count

    def get_location_pages(self):
        return self.wait_select_single(
            "QQuickListView", objectName="locationPages")

    def get_location_pane(self, index):
        return self.wait_select_single(
            LocationPane, objectName="locationPane" + str(index))

    def get_selected_location_index(self):
        return self.get_location_pages().currentIndex

    def get_selected_location_pane(self):
        return self.get_location_pane(self.get_selected_location_index())

    def reveal_bottom_edge_page(self):
        try:
            bottom_edge_hint = self.wait_select_single(
                "UCBottomEdgeHint", visible=True)
            bottom_edge_hint.visible.wait_for(True)
            start_x = (bottom_edge_hint.globalRect.x +
                       (bottom_edge_hint.globalRect.width * 0.5))
            start_y = (bottom_edge_hint.globalRect.y +
                       (bottom_edge_hint.height * 0.5))
            stop_y = start_y - (self.height * 0.7)
            self.pointing_device.drag(start_x, start_y,
                                      start_x, stop_y, rate=2)
            bottom_edge = self.wait_select_single(
                "LocationsPage", objectName="locationsPage")
            bottom_edge.visible.wait_for(True)
        except dbus.StateNotFoundError:
            logger.error('BottomEdge element not found.')
            raise

    def swipe_left(self):

        # Define the start and stop locations of the left swipe
        start_x = (self.globalRect.x +
                   (self.globalRect.width * 0.9))
        stop_x = (self.globalRect.x +
                  (self.globalRect.width * 0.1))
        start_y = stop_y = (self.globalRect.y +
                            (self.globalRect.height * 0.5))
        rate = 5

        self.pointing_device.drag(start_x, start_y, stop_x, stop_y, rate)


class HomeTempInfo(UbuntuUIToolkitCustomProxyObjectBase):
    pass


class LocationPane(QQuickListView):
    @click_object
    def click_day_delegate(self, day):
        return self.get_day_delegate(day)

    @click_object
    def click_home_temp_info(self):
        return self.get_home_temp_info()

    @click_object
    def click_settings_button(self):
        self.swipe_to_top()  # ensure at the top of the flickable

        return self.get_settings_button()

    def get_name(self):
        return self.wait_select_single(
            "UCLabel", objectName='headerLabel').text

    def get_day_delegate(self, day):
        return self.wait_select_single(
            "DayDelegate", objectName="dayDelegate" + str(day))

    def get_home_temp_info(self):
        return self.wait_select_single(
            "HomeTempInfo", objectName="homeTempInfo")

    def get_settings_button(self):
        return self.select_single(
            "UCAbstractButton", objectName="settingsButton")


class LocationsPage(Page):
    """Autopilot helper for LocationsPage."""
    def __init__(self, *args, **kwargs):
        super(LocationsPage, self).__init__(*args, **kwargs)

    def click_add_location_action(self):
        return self.wait_select_single(
            "ActionBar", objectName="locationsTrailingActionBar", visible=True,
        ).click_action_button("addLocation")

    def click_back(self):
        return self.wait_select_single(
            "ActionBar", objectName="locationsLeadingActionBar", visible=True,
        ).click_action_button("back")

    @click_object
    def click_location(self, index):
        return self.get_location(index)

    def get_location(self, index):
        return self.wait_select_single(WeatherListItem,
                                       objectName="location" + str(index))


class MainView(MainView):
    """Autopilot custom proxy object for the MainView."""
    retry_delay = 0.2

    def __init__(self, *args):
        super(MainView, self).__init__(*args)
        self.visible.wait_for(True)


class SettingsPage(Page):
    """Autopilot helper for SettingsPage."""
    @click_object
    def click_settings_page_listitem(self, objectName):
        return self.select_single("UCListItem", objectName=objectName)

    def get_units_page(self):
        return self.main_view.wait_select_single(UnitsPage, visible=True)


class UnitsPage(Page):
    """Autopilot helper for UnitsPage."""
    def change_listitem_unit(self, unit_name):
        """Common actions to change listitem unit and return if it changed"""

        # Expand the listitem as we are already on the units page
        self.expand_units_listitem(unit_name)

        # Get the currently selected value
        previous_unit = self.get_expanded_listitem(
            unit_name, "True"
        ).titleValue

        # Click the non-selected value
        self.click_not_selected_listitem(unit_name)

        # Return True/False if the selection has changed
        return self.get_expanded_listitem(
            unit_name, "True").titleValue != previous_unit

    @click_object
    def click_not_selected_listitem(self, unit_name):
        return self.get_expanded_listitem(unit_name, "False")

    @click_object
    def click_units_listitem(self, listitem):
        return self.select_single("ExpandableListItem", objectName=listitem)

    def expand_units_listitem(self, listitem):
        item = self.click_units_listitem(listitem)
        item.height.wait_for(item.expansionHeight)
        return item

    def get_expanded_listitem(self, listitem, showIcon):
        listitemSetting = self.select_single(
            "ExpandableListItem", objectName=listitem)
        return listitemSetting.select_single(
            "StandardListItem", iconVisible=showIcon)


class WeatherListItem(UCListItem):
    def click_remove_action(self):
        return self.trigger_leading_action("swipeDeleteAction",
                                           self.wait_until_destroyed)

    def get_name(self):
        return self.select_single("UCLabel", objectName="name").text
