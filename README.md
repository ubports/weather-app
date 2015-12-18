ReadMe - Ubuntu Weather App
===========================
Ubuntu Weather App is the official weather app for Ubuntu Touch. We follow an open
source model where the code is available to anyone to branch and hack on. The
ubuntu weather app follows a test driven development (TDD) where tests are
written in parallel to feature implementation to help spot regressions easier.

API
===
The OpenWeatherMap service requires an API key. 
Visit [Open Weather](http://openweathermap.org/appid) to obtain a personal key.
Click [here](http://openweathermap.org/faq#error401) for more details.
Place the key between the quotation marks for the "owmKey" variable in app/data/keys.js

**Do not commit branches with the key in place as a centrally managed key is injected at build time.**

Dependencies
============
**DEPENDENCIES ARE NEEDED TO BE INSTALLED TO BUILD AND RUN THE APP**.

A complete list of dependencies for the project can be found in ubuntu-weather-app/debian/control

The following essential packages are also required to develop this app:
* [ubuntu-sdk](http://developer.ubuntu.com/start)
* intltool   - run  `sudo apt-get install intltool` 

Useful Links
============
Here are some useful links with regards to the Weather App development.

* [Home Page](https://developer.ubuntu.com/en/community/core-apps/weather/)
* [Weather App Wiki](https://wiki.ubuntu.com/Touch/CoreApps/Weather)
* [Designs](https://docs.google.com/presentation/d/1tXcyMBvJAYvwFvUAmTTYzmBP2NFQgbG_Gy8e2gv91kU/edit#slide=id.p)
* [Project page](https://launchpad.net/ubuntu-weather-app) 
