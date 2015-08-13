# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013, 2014, 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""ubuntu-weather-app tests and emulators - top level package."""
from autopilot.introspection import dbus
import logging
from ubuntuuitoolkit import MainView, UbuntuUIToolkitCustomProxyObjectBase

logger = logging.getLogger(__name__)


class UbuntuWeatherAppException(Exception):
    """Exception raised when there's an error in the Weather App."""


def click_object(func):
    """Wrapper which clicks the returned object"""
    def func_wrapper(self, *args, **kwargs):
        return self.pointing_device.click_object(func(self, *args, **kwargs))

    return func_wrapper


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


class Page(UbuntuUIToolkitCustomProxyObjectBase):
    """Autopilot helper for Pages."""
    def __init__(self, *args, **kwargs):
        super(Page, self).__init__(*args, **kwargs)

        # Use only objectName due to bug 1350532 as it is MainView12
        self.main_view = self.get_root_instance().select_single(
            objectName="weather")

    def click_back(self):
        return self.main_view.get_header().click_back_button()


class PageWithBottomEdge(Page):
    """
    An emulator class that makes it easy to interact with the bottom edge
    swipe page
    """
    def __init__(self, *args, **kwargs):
        super(PageWithBottomEdge, self).__init__(*args, **kwargs)

    def reveal_bottom_edge_page(self):
        """Bring the bottom edge page to the screen"""
        self.bottomEdgePageLoaded.wait_for(True)

        try:
            action_item = self.wait_select_single(objectName='bottomEdgeTip')
            action_item.visible.wait_for(True)
            start_x = (action_item.globalRect.x +
                       (action_item.globalRect.width * 0.5))
            start_y = (action_item.globalRect.y +
                       (action_item.height * 0.5))
            stop_y = start_y - (self.height * 0.7)
            self.pointing_device.drag(start_x, start_y,
                                      start_x, stop_y, rate=2)
            self.isReady.wait_for(True)
        except dbus.StateNotFoundError:
            logger.error('BottomEdge element not found.')
            raise


class AddLocationPage(Page):
    """Autopilot helper for AddLocationPage."""
    def __init__(self, *args, **kwargs):
        super(AddLocationPage, self).__init__(*args, **kwargs)

    @click_object
    def click_location(self, index):
        return self.select_single("UCListItem",
                                  objectName="addLocation" + str(index))

    def click_search_action(self):
        self.main_view.get_header().click_action_button("search")

    def get_search_field(self):
        header = self.main_view.get_header()

        return header.select_single("TextField", objectName="searchField")

    def search(self, value):
        self.click_search_action()

        search_field = self.get_search_field()
        search_field.write(value)

        # Wait for model to finish loading
        self.searching.wait_for(False)


class HomePage(PageWithBottomEdge):
    """Autopilot helper for HomePage."""
    def __init__(self, *args, **kwargs):
        super(HomePage, self).__init__(*args, **kwargs)

    def get_location_pages(self):
        return self.wait_select_single(
            "QQuickListView", objectName="locationPages")

    def get_location_count(self):
        return self.get_location_pages().count

    def get_selected_location_index(self):
        return self.get_location_pages().currentIndex

    def get_daydelegate(self, weekdaycolumn, day):
        weekdaycolumn = self.wait_select_single(
            "QQuickColumn", objectName="weekdayColumn" + str(weekdaycolumn))
        return weekdaycolumn.wait_select_single(
            "DayDelegate", objectName="dayDelegate" + str(day))

    @click_object
    def click_daydelegate(self, day_delegate):
        return day_delegate


class LocationsPage(Page):
    """Autopilot helper for LocationsPage."""
    def __init__(self, *args, **kwargs):
        super(LocationsPage, self).__init__(*args, **kwargs)

    def click_add_location_action(self):
        self.main_view.get_header().click_action_button("addLocation")

    @click_object
    def click_location(self, index):
        return self.get_location(index)

    def get_location(self, index):
        return self.select_single(WeatherListItem,
                                  objectName="location" + str(index))


class MainView(MainView):
    """Autopilot custom proxy object for the MainView."""
    retry_delay = 0.2

    def __init__(self, *args):
        super(MainView, self).__init__(*args)
        self.visible.wait_for(True)


class WeatherListItem(UbuntuUIToolkitCustomProxyObjectBase):
    def get_name(self):
        return self.select_single("Label", objectName="name").text

    @click_object
    def select_remove(self):
        return self.select_single(objectName="swipeDeleteAction")

    def swipe_and_select_remove(self):
        x, y, width, height = self.globalRect
        start_x = x + (width * 0.2)
        stop_x = x + (width * 0.8)
        start_y = stop_y = y + (height // 2)

        self.pointing_device.drag(start_x, start_y, stop_x, stop_y)

        self.select_remove()
