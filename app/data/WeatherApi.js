.pragma library
/*
 * Copyright (C) 2013 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Raúl Yeguas <neokore@gmail.com>
 *              Martin Borho <martin@borho.net>
 *              Andrew Starr-Bochicchio <a.starr.b@gmail.com>
 */

/**
*  Version of the response data format.
*  Increase this number to force a refresh.
*/
var RESPONSE_DATA_VERSION = 20150404;

/**
* Helper functions
*/
function debug(obj) {
    print(JSON.stringify(obj))
}
//
function calcFahrenheit(celsius) {
        return celsius * 1.8 + 32;
}
//
function calcMph(ms) {
    return ms*2.24;
}
//
function calcInch(mm) {
    return mm/25.4;
}
//
function calcKph(ms) {
    return ms*3.6;
}
//
function convertKphToMph(kph) {
    return kph*0.621;
}
//
function calcWindDir(degrees) {
    var direction =  "?";
    if(degrees >=0 && degrees <= 30){
        direction = "N";
    } else if(degrees >30 && degrees <= 60){
        direction = "NE";
    } else if(degrees >60 && degrees <= 120){
        direction = "E";
    } else if(degrees >120 && degrees <= 150){
        direction = "SE";
    } else if(degrees >150 && degrees <= 210){
        direction = "S";
    } else if(degrees >210 && degrees <= 240){
        direction = "SW";
    } else if(degrees >240 && degrees <= 300){
        direction = "W";
    } else if(degrees >300 && degrees <= 330){
        direction = "NW";
    } else if(degrees >330 && degrees <= 360){
        direction = "N";
    }
    return direction;
}

//
function getLocationTime(tstamp) {
    var locTime = new Date(tstamp);
    return {
        year: locTime.getUTCFullYear(),
        month: locTime.getUTCMonth(),
        date: locTime.getUTCDate(),
        hours: locTime.getUTCHours(),
        minutes: locTime.getUTCMinutes()
    }
}
// Serialize a JavaScript object to URL parameters
// E.g. {param1: value1, param2: value2} to "param1=value&param2=value"
// TODO: it'd be nice to make it work with either passing a single object
// or several at once
function parameterize(obj) {
  var str = [];
  for(var param in obj) {
     str.push(encodeURIComponent(param) + "=" + encodeURIComponent(obj[param]));
  }
  return str.join("&");
}


// Remove anything including and after APPID in the given term
function trimAPIKey(data) {
    var i = data.indexOf("APPID");

    if (i > -1) {
        data = data.substr(0, i);
    }

    return data;
}

var GeoipApi = (function() {
    var _baseUrl = "http://geoip.ubuntu.com/lookup";
    return {
        getLatLong: function(params, apiCaller, onSuccess, onError) {
            var request = { type: "geolookup",url: _baseUrl},
                resultHandler = (function(request, xmlDoc) {
                    var coords = {},
                        childNodes = xmlDoc.childNodes;
                    for(var i=0;i<childNodes.length;i++) {
                        if(childNodes[i].nodeName === "Latitude") {
                            coords.lat = childNodes[i].firstChild.nodeValue;
                        } else if(childNodes[i].nodeName === "Longitude") {
                            coords.lon = childNodes[i].firstChild.nodeValue;
                        }
                    }
                    onSuccess(coords);
                }),
                retryHandler = (function(err) {
                    console.log("geolookup retry of "+err.request.url);
                    apiCaller(request, resultHandler, onError);
                });
            apiCaller(request, resultHandler, retryHandler);
        }
    }
})();

var GeonamesApi = (function() {
    /**
      provides neccessary methods for requesting and preparing data from Geonames.org
    */
    var _baseUrl = "http://api.geonames.org/";
    var _username = "uweatherdev"
    var _addParams = "&maxRows=25&featureClass=P"
    //
    function _buildSearchResult(request, data) {
        var searchResult = { locations: [], request: request };
        if(data.geonames) {
            data.geonames.forEach(function(r) {
               searchResult.locations.push({
                    name: r.name,
                    coord: {lat: r.lat, lon: r.lng},
                    country: r.countryCode,
                    countryName: r.countryName,
                    timezone: r.timezone,
                    adminName1: r.adminName1,
                    adminName2: r.adminName2,
                    adminName3: r.adminName3,
                    population: r.population,
                    services: {
                        "geonames": r.geonameId
                    }
                });
            })
        }
        return searchResult;
    }
    //
    return {
        //
        search: function(mode, params, apiCaller, onSuccess, onError) {
            var request,
                retryHandler = (function(err) {
                        console.log("search retry of "+err.request.url);
                        apiCaller(request, searchResponseHandler, onError);
                }),
                searchResponseHandler = function(request, data) {
                    onSuccess(_buildSearchResult(request, data));
                };
            if(mode === "point") {
                request = { type: "search",
                            url: _baseUrl+ "findNearbyPlaceNameJSON?style=full&username="+encodeURIComponent(_username)
                            +"&lat="+encodeURIComponent(params.coords.lat)+"&lng="+encodeURIComponent(params.coords.lon)
                            +_addParams}
            } else {
                request = { type: "search",
                            url: _baseUrl+ "searchJSON?style=full&username="+encodeURIComponent(_username)
                                    +"&name_startsWith="+encodeURIComponent(params.name)+_addParams}
            }
            apiCaller(request, searchResponseHandler, retryHandler);
        }
    }

})();

var OpenWeatherMapApi = (function() {
    /**
      provides neccessary methods for requesting and preparing data from OpenWeatherMap.org
    */
    var _baseUrl = "http://api.openweathermap.org/data/2.5/";
    //
    var _serviceName = "openweathermap";
    //
    var _icon_map = {
        "01d": "sun",
        "01n": "moon",
        "02d": "cloud_sun",
        "02n": "cloud_moon",
        "03d": "cloud_sun",
        "03n": "cloud_moon",
        "04d": "cloud",
        "04n": "cloud",
        "09d": "rain",
        "09n": "rain",
        "10d": "rain",
        "10n": "rain",
        "11d": "thunder",
        "11n": "thunder",
        "13d": "snow_shower",
        "13n": "snow_shower",
        "50d": "fog",
        "50n": "fog"
    }    
    //
    function _buildDataPoint(date, data) {
        var result = {
            timestamp: data.dt,
            date: date,
            metric: {
                temp:data.main.temp,
                windSpeed: calcKph(data.wind.speed),
                rain: data.main.rain || ((data.rain) ? data.rain["3h"] : false ) || 0,
                snow: data.main.snow || ((data.snow) ? data.snow["3h"] : false ) || 0
            },
            imperial: {
                temp: calcFahrenheit(data.main.temp),
                windSpeed: calcMph(data.wind.speed),
                rain: calcInch(data.main.rain || ((data.rain) ? data.rain["3h"] : false ) || 0),
                snow: calcInch(data.main.snow || ((data.snow) ? data.snow["3h"] : false ) ||0)
            },
            humidity: data.main.humidity,
            pressure: data.main.pressure,
            windDeg: data.wind.deg,
            windDir: calcWindDir(data.wind.deg),
            icon: _icon_map[data.weather[0].icon],
            condition: data.weather[0].description
        };
        if(data.id !== undefined) {
            result["service"] = _serviceName;
            result["service_id"] =  data.id;
        }
        return result;
    }
    //
    function _buildDayFormat(date, data) {
        var result = {
            date: date,
            timestamp: data.dt,
            metric: {
                tempMin: data.temp.min,
                tempMax: data.temp.max,
                windSpeed: calcKph(data.speed),
                rain: data.rain || 0,
                snow: data.snow || 0
            },
            imperial: {
                tempMin: calcFahrenheit(data.temp.min),
                tempMax: calcFahrenheit(data.temp.max),
                windSpeed: calcMph(data.speed),
                rain: calcInch(data.rain || 0),
                snow: calcInch(data.snow || 0)
            },
            pressure: data.pressure,
            humidity: data.humidity,
            icon: _icon_map[data.weather[0].icon],
            condition: data.weather[0].description,
            windDeg: data.deg,
            windDir: calcWindDir(data.deg),
            hourly: []
        }
        return result;
    }
    //
    function formatResult(data, location) {
        var tmpResult = {},
            result = [],
            day=null,
            offset=(location.timezone && location.timezone.gmtOffset) ? location.timezone.gmtOffset*60*60*1000: 0,
            localNow = getLocationTime(new Date().getTime()+offset),
            todayDate;        
        print("["+location.name+"] "+JSON.stringify(localNow))
        // add openweathermap id for faster responses
        if(location.services && !location.services[_serviceName] && data["current"].id) {
            location.services[_serviceName] = data["current"].id
        }
        //
        data["daily"]["list"].forEach(function(dayData) {
            var date = getLocationTime(((dayData.dt*1000)-1000)+offset), // minus 1 sec to handle +/-12 TZ
                day = date.year+"-"+date.month+"-"+date.date;
            if(!todayDate) {
                if(localNow.year+"-"+localNow.month+"-"+localNow.date > day) {
                    // skip "yesterday"
                    return;
                }
                todayDate = date;
            }
            tmpResult[day] = _buildDayFormat(date, dayData);
        })
        //
        var today = todayDate.year+"-"+todayDate.month+"-"+todayDate.date
        tmpResult[today]["current"] = _buildDataPoint(todayDate, data["current"]);
        if(data["forecast"] !== undefined) {
            data["forecast"]["list"].forEach(function(hourData) {                
                var dateData = getLocationTime((hourData.dt*1000)+offset),
                    day = dateData.year+"-"+dateData.month+"-"+dateData.date;
                if(tmpResult[day]) {
                    tmpResult[day]["hourly"].push(_buildDataPoint(dateData, hourData));
                }
            })
        }
        //
        for(var d in tmpResult) {
            result.push(tmpResult[d]);
        }
        return result;
    }
    //
    function _getUrls(params) {
        var urls = {
                current: "",
                daily: "",
                forecast: ""
            },
            latLongParams = "&lat="+encodeURIComponent(params.location.coord.lat)
                + "&lon="+encodeURIComponent(params.location.coord.lon);
        if(params.location.services && params.location.services[_serviceName]) {
            urls.current = _baseUrl + "weather?units="+params.units+"&id="+params.location.services[_serviceName]+"&lang="+Qt.locale().name.split("_")[0];
            urls.daily = _baseUrl + "forecast/daily?id="+params.location.services[_serviceName]+"&cnt=10&units="+params.units+"&lang="+Qt.locale().name.split("_")[0];
            urls.forecast = _baseUrl + "forecast?id="+params.location.services[_serviceName]+"&units="+params.units+"&lang="+Qt.locale().name.split("_")[0];

        } else if (params.location.coord) {
            urls.current = _baseUrl + "weather?units="+params.units+latLongParams+"&lang="+Qt.locale().name.split("_")[0];
            urls.daily = _baseUrl+"forecast/daily?cnt=10&units="+params.units+latLongParams+"&lang="+Qt.locale().name.split("_")[0];
            urls.forecast = _baseUrl+"forecast?units="+params.units+latLongParams+"&lang="+Qt.locale().name.split("_")[0];
        }
        urls.current += "&APPID="+params.owm_api_key;
        urls.daily += "&APPID="+params.owm_api_key;
        urls.forecast += "&APPID="+params.owm_api_key;

        return urls;
    }
    //
    return {     
        //
        getData: function(params, apiCaller, onSuccess, onError) {
            var urls = _getUrls(params),
                handlerMap = {
                current: { type: "current",url: urls.current},
                daily: { type: "daily",url: urls.daily},
                forecast: { type: "forecast", url: urls.forecast}},
            response = {
                location: params.location,
                db: (params.db) ? params.db : null,
                format: RESPONSE_DATA_VERSION
            },
            respData = {},
            addDataToResponse = (function(request, data) {
                var formattedResult;
                respData[request.type] = data;
                if(respData["current"] !== undefined
                        && respData["forecast"] !== undefined
                            && respData["daily"] !== undefined) {
                    response["data"] = formatResult(respData, params.location)
                    onSuccess(response);
                }
            }),
            onErrorHandler = (function(err) {
                onError(err);
            }),
            retryHandler = (function(err) {
                console.log("retry of "+trimAPIKey(err.request.url));
                var retryFunc = handlerMap[err.request.type];
                apiCaller(retryFunc, addDataToResponse, onErrorHandler);
            });
            //
            apiCaller(handlerMap.current, addDataToResponse, retryHandler);
            apiCaller(handlerMap.forecast, addDataToResponse, retryHandler);
            apiCaller(handlerMap.daily, addDataToResponse, retryHandler);
        }
    }

})();

var WeatherChannelApi = (function() {
    /**
      provides neccessary methods for requesting and preparing data from OpenWeatherMap.org
    */
    var _baseUrl = "http://wxdata.weather.com/wxdata/";
    //
    var _serviceName = "weatherchannel";
    //
    // see http://s.imwx.com/v.20131006.223722/img/wxicon/72/([0-9]+).png
    var _iconMap = {
        "0": "thunder", // ??
        "1": "thunder", // ??
        "2": "thunder", // ??
        "3": "thunder", // ??
        "4": "thunder", //T-Storms
        "5": "snow_rain", //Rain / Snow
        "6": "snow_rain", // ??
        "7": "snow_rain", //Wintry Mix
        "8": "scattered", //Freezing Drizzle
        "9": "scattered", //Drizzle
        "10": "rain", // ??
        "11": "rain", //Showers
        "12": "rain", //Rain
        "13": "snow_shower", // ??
        "14": "snow_shower", //Snow shower/Light snow
        "15": "snow_shower", //
        "16": "snow_shower", //Snow
        "17": "thunder", // Hail??
        "18": "snow_rain", // Rain / Snow ??
        "19": "fog", //Fog ??
        "20": "fog", //Fog
        "21": "fog", //Haze
        "22": "fog", // ??
        "23": "fog", // Wind ??
        "24": "overcast", //Partly Cloudy / Wind
        "25": "overcast", // ??
        "26": "overcast",//Cloudy
        "27": "cloud_moon",//Mostly Cloudy
        "28": "cloud_sun", //Mostly Cloudy
        "29": "cloud_moon", //Partly Cloudy
        "30": "cloud_sun", //Partly Cloudy
        "31": "moon", //Clear
        "32": "sun", //Sunny
        "33": "cloud_moon", //Mostly Clear
        "34": "cloud_sun", //Mostly Sunny
        "35": "snow_rain", // ??
        "36": "sun", //Sunny
        "37": "thunder", //Isolated T-Storms
        "38": "thunder", //Scattered T-Storms
        "39": "scattered", //Scattered Showers
        "40": "rain", // ??
        "41": "snow", //Scattered Snow Showers
        "42": "snow_shower", // ??
        "43": "snow_shower", // ??
        "44": "fog", // ??
        "45": "scattered", // ??
        "46": "snow_shower", //Snow Showers Early
        "47": "thunder" //Isolated T-Storms
    };
    //
    function _buildDataPoint(date, dataObj) {
        var data = dataObj["Observation"] || dataObj,
            result = {
                timestamp: data.date || data.dateTime,
                date: date,
                metric: {
                    temp: data.temp,
                    tempFeels: data.feelsLike,
                    windSpeed: data.wSpeed
                },
                imperial: {
                    temp: calcFahrenheit(data.temp),
                    tempFeels: calcFahrenheit(data.feelsLike),
                    windSpeed: convertKphToMph(data.wSpeed)
                },
                precipType: (data.precip_type !== undefined) ? data.precip_type : null,
                propPrecip: (data.pop !== undefined) ? data.pop : null,
                humidity: data.humid,
                pressure: data.pressure,
                windDeg: data.wDir,
                windDir: data.wDirText,
                icon: _iconMap[(data.wxIcon||data.icon)],
                condition: data.text || data.wDesc,
                uv: data.uv
        };
        if(_iconMap[data.wxIcon||data.icon] === undefined) {
            print("ICON MISSING POINT: "+(data.wxIcon||data.icon)+" "+result.condition)
        }
        return result;
    }
    //
    function _buildDayFormat(date, data, now) {
        var partData = (now > data.validDate || data.day === undefined) ? data.night : data.day,
            result = {
            date: date,
            timestamp: data.validDate,
            metric: {
                tempMin: data.minTemp,
                tempMax: data.maxTemp,
                windSpeed: partData.wSpeed
            },
            imperial: {
                tempMin: calcFahrenheit(data.minTemp),
                tempMax: calcFahrenheit(data.maxTemp !== undefined ? data.maxTemp : data.minTemp),
                windSpeed: convertKphToMph(partData.wSpeed)
            },
            precipType: partData.precip_type,
            propPrecip: partData.pop,
            pressure: null,
            humidity: partData.humid,
            icon: _iconMap[partData.icon],
            condition: partData.phrase,
            windDeg: partData.wDir,
            windDir: partData.wDirText,
            uv: partData.uv,
            hourly: []
        }
        if(_iconMap[partData.icon] === undefined) {
            print("ICON MISSING  DAY: "+partData.icon+" "+result.condition)
        }
        return result;
    }
    //
    function formatResult(combinedData, location) {
        var tmpResult = {}, result = [],
            day=null, todayDate,
            offset=(location.timezone && location.timezone.gmtOffset) ? location.timezone.gmtOffset*60*60*1000: 0,
            now = new Date().getTime(),
            nowMs = parseInt(now/1000),
            localNow = getLocationTime(now+offset),
            data = {
                "location": combinedData[0]["Location"],
                "daily": combinedData[0]["DailyForecasts"],
                "forecast": combinedData[0]["HourlyForecasts"],
                "current": combinedData[0]["StandardObservation"],
                "sunRiseSet": combinedData[0]["SunRiseSet"],
            };
        print("["+location.name+"] "+JSON.stringify(localNow));
        // add openweathermap id for faster responses
        if(location.services && !location.services[_serviceName] && data["location"].key) {
            location.services[_serviceName] = data["location"].key
        }                
        // only 5 days of forecast for TWC
        for(var x=0;x<5;x++) {
            var dayData = data["daily"][x],
                date = getLocationTime(((dayData.validDate*1000)-1000)+offset); // minus 1 sec to handle +/-12 TZ
            var sunRiseSet = data["sunRiseSet"][x];
            day = date.year+"-"+date.month+"-"+date.date;
            if(!todayDate) {
                if(localNow.year+"-"+localNow.month+"-"+localNow.date > day) {
                    // skip "yesterday"
                    continue;
                }
                todayDate = date;
            }
            tmpResult[day] = _buildDayFormat(date, dayData, nowMs);
            var sunrise = new Date(sunRiseSet.rise*1000);
            var sunset = new Date(sunRiseSet.set*1000);
            tmpResult[day].sunrise = sunrise.toLocaleTimeString();
            tmpResult[day].sunset = sunset.toLocaleTimeString();
        }
        //
        if(data["forecast"] !== undefined) {
            data["forecast"].forEach(function(hourData) {
                var dateData = getLocationTime((hourData.dateTime*1000)+offset),
                    day = dateData.year+"-"+dateData.month+"-"+dateData.date;
                if(tmpResult[day]) {
                    tmpResult[day]["hourly"].push(_buildDataPoint(dateData, hourData));
                }
            })
        }
        //
        if(data["current"]) {
            var today = todayDate.year+"-"+todayDate.month+"-"+todayDate.date;
            tmpResult[today]["current"] = _buildDataPoint(todayDate, data["current"]);
            // if the icon is missing, use the first from the hourly forecast
            if(!tmpResult[today]["current"].icon && tmpResult[today]["hourly"] && tmpResult[today]["hourly"].length > 0) {
                tmpResult[today]["current"].icon = tmpResult[today]["hourly"][0].icon;
            }
            // if condition text is missing, use the condition from the first hourly forecast
            if((tmpResult[today]["current"].condition === "-" || tmpResult[today]["current"].condition === undefined)
                && (tmpResult[today]["hourly"] && tmpResult[today]["hourly"].length > 0)) {
                    tmpResult[today]["current"].condition = tmpResult[today]["hourly"][0].condition;
            }
        }
        //
        for(var d in tmpResult) {
            result.push(tmpResult[d]);
        }
        return result;
    }
    //
    function _getUrl(params) {
        var url, serviceId,
            baseParams = {
                key: params.twc_api_key,
                units: (params.units === "metric") ? "m" : "e",
                locale: Qt.locale().name,
                hours: "48",
            },
            commands = {
                "mobileaggregation": "mobile/mobagg/",
            };
        if(params.location.services && params.location.services[_serviceName]) {
            serviceId = encodeURIComponent(params.location.services[_serviceName]);
            url = _baseUrl+commands["mobileaggregation"]+serviceId+".js?"+parameterize(baseParams);
        } else if (params.location.coord) {
            var coord = {lat: params.location.coord.lat, lng: params.location.coord.lon};
            url = _baseUrl+commands["mobileaggregation"]+"get.js?"+parameterize(baseParams)+"&"+
                  parameterize(coord);
        }
        return url;
    }
    //
    return {
        getData: function(params, apiCaller, onSuccess, onError) {
            var url = _getUrl(params),
                handlerMap = {
                    all: { type: "all", url: url}
                },
                response = {
                    location: params.location,
                    db: (params.db) ? params.db : null,
                    format: RESPONSE_DATA_VERSION
                },
                addDataToResponse = (function(request, data) {
                    var formattedResult;
                    response["data"] = formatResult(data, params.location);
                    onSuccess(response);
                }),
                onErrorHandler = (function(err) {
                    onError(err);
                });
            apiCaller(handlerMap.all, addDataToResponse, onErrorHandler);
        }
    }
})();

var WeatherApi = (function(_services) {
    /**
      proxy for requesting weather apis, the passed _services are providing the respective api endpoints
      and formatters to build a uniform response object
    */
    function _getService(name) {
        if(_services[name] !== undefined) {
            return _services[name];
        }
        return _services["weatherchannel"];
    }
    //
    function _sendRequest(request, onSuccess, onError) {
        var xmlHttp = new XMLHttpRequest();
        if (xmlHttp) {
            console.log("Sent request URL: " + trimAPIKey(request.url));
            xmlHttp.open('GET', request.url, true);
            xmlHttp.onreadystatechange = function () {
                try {
                    if (xmlHttp.readyState == 4) {
                        if(xmlHttp.status === 200) {
                            if(xmlHttp.responseXML) {
                                onSuccess(request, xmlHttp.responseXML.documentElement);
                            } else {
                                var json = JSON.parse(xmlHttp.responseText);
                                onSuccess(request,json);
                            }
                        } else {
                            onError({
                                msg: "wrong response http code, got "+xmlHttp.status,
                                request: request
                            });
                        }
                    }
                } catch (e) {
                    print("Exception: "+e)
                    onError({msg: "wrong response data format", request: request});
                }
            };
            xmlHttp.send(null);
        }
    }
    //
    return  {
        //
        geoLookup: function(params, onSuccess, onError) {
            var service = _getService('geoip'),
                geoNameService = _getService('geonames'),
                lookupHandler = function(data) {
                    print("Geolookup: "+JSON.stringify(data))
                    geoNameService.search("point", {coords:data}, _sendRequest, onSuccess, onError);
                };
            service.getLatLong(params, _sendRequest, lookupHandler, onError)
        },
        //
        search: function(mode, params, onSuccess, onError) {
            var service = _getService('geonames');
            service.search(mode, params, _sendRequest, onSuccess, onError);
        },
        //
        getLocationData: function(params, onSuccess, onError) {
            var service = _getService(params.service);
            service.getData(params, _sendRequest, onSuccess, onError);
        },
    }
})({
    "openweathermap": OpenWeatherMapApi,
    "weatherchannel": WeatherChannelApi,
    "geonames": GeonamesApi,
    "geoip": GeoipApi
});

var sendRequest = function(message, responseCallback) {
    // handles the response data
    var finished = function(result) {
        // print result to get data for test json files
        // print(JSON.stringify(result));
        //WorkerScript.sendMessage({
        responseCallback({
            action: message.action,
            result: result
        })
    }
    // handles errors
    var onError = function(err) {
        console.log(JSON.stringify(err, null, true));
        //WorkerScript.sendMessage({ 'error': err})
        responseCallback({ 'error': err})
    }
    // keep order of locations, sort results
    var sortDataResults = function(locA, locB) {
        return locA.db.id - locB.db.id;
    }
    // perform the api calls
    if(message.action === "searchByName") {
        WeatherApi.search("name", message.params, finished, onError);
    } else if(message.action === "searchByPoint") {
        WeatherApi.search("point", message.params, finished, onError);
    } else if(message.action === "getGeoIp") {
        WeatherApi.geoLookup(message.params, finished, onError);
    } else if(message.action === "updateData") {
        var locLength = message.params.locations.length,
            locUpdated = 0,
            result = [],
            now = new Date().getTime();
        if(locLength > 0) {
            message.params.locations.forEach(function(loc) {
                var updatedHnd = function (newData, cached) {
                        locUpdated += 1;
                        if(cached === true) {
                            newData["save"] = false;
                        } else {
                            newData["save"] = true;
                            newData["updated"] =  new Date().getTime();
                        }
                        result.push(newData);
                        if(locUpdated === locLength) {
                            result.sort(sortDataResults);
                            finished(result);
                        }
                    },
                    params = {
                        location:loc.location,
                        db: loc.db,
                        units: 'metric',
                        service: message.params.service,
                        twc_api_key: message.params.twc_api_key,
                        owm_api_key: message.params.owm_api_key,
                        interval: message.params.interval
                    },
                    secsFromLastFetch = (now-loc.updated)/1000;
                if( message.params.force===true || loc.format !== RESPONSE_DATA_VERSION || secsFromLastFetch > params.interval){
                    // data older than 30min, location is new or data format is deprecated
                    WeatherApi.getLocationData(params, updatedHnd, onError);
                } else {
                    console.log("["+loc.location.name+"] returning cached data, time from last fetch: "+secsFromLastFetch)
                    updatedHnd(loc, true);
                }
            })
        } else {
            finished(result);
        }
    }
}
