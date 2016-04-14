/*
*   Authour: Symeon Huang (librehat) <hzwhuang@gmail.com>
*   Copyright 2014-2016
*
*   This program is free software; you can redistribute it and/or modify
*   it under the terms of the GNU Library General Public License as
*   published by the Free Software Foundation; either version 3 or
*   (at your option) any later version.
*/

import QtQuick 2.2

Item {
    id: yahoo
    
    property bool hasdata: false
    //used to display error on widget
    property string errstring
    property bool m_isbusy: false

    property string m_lastBuildDate
    property string m_link
    property string m_city
    property string m_region
    property string m_country
    property string m_unitTemperature
    property string m_unitDistance
    property string m_unitPressure
    property string m_unitSpeed
    property string m_windChill
    property string m_windDirection
    property string m_windSpeed
    property string m_atmosphereHumidity
    property string m_atmosphereVisibility
    property string m_atmospherePressure
    property string m_atmosphereRising
    property string m_astronomySunrise
    property string m_astronomySunset

    property string m_geoLat
    property string m_geoLong

    property string m_conditionIcon
    property string m_conditionDesc
    property int m_conditionTemp
    property alias dataModel: forecastModel
    
    // don't use m_response outside this file!
    property string m_response

    Forecast {
        id: forecastModel
    }
    
    property string unitsymbol
    
    property int failedAttempts: 0
    
    // timer for repeat query from sh033
    Timer {
        id: repeatquery
        interval: 10000
        running: false
        repeat: true
        onTriggered: {
            running = false
            console.debug("Reapeat Query.. ")
            query()
        }
    }
    
    function query(woeid) {
        console.debug("Querying...")
        
        m_isbusy = true
        woeid = woeid ? woeid : plasmoid.configuration.woeid
        if (!woeid) {
            hasdata = false
            m_isbusy = false
            errstring = i18n("Error 3. WOEID is not specified.")
            console.debug("WOEID is empty.")
            return//fail silently
        }
        
        if (plasmoid.configuration.celsius) {
            unitsymbol = "c"
        } else {
            unitsymbol = "f"
        }
        
        var source = "http://query.yahooapis.com/v1/public/yql?q=select * from weather.forecast where woeid='" + woeid + "' and u='f'&format=json"
        console.debug("Source changed to", source)
        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                if (doc.status === 200) {
                    getweatherinfo(doc.responseText)
                } else {
                    errstring = i18n("Error 1. Please check your network.")
                    console.debug("HTTP request failed, try again.")
                    repeatquery.running = true
                }
            }
        }
        doc.open("GET", source, true)
        doc.send()
    }
    
    function getweatherinfo(response) {
        console.debug("getweatherinfo() is called. Getting Weather Information...")
        if (!response) {
            console.error("Unexpected: response is empty.")
            return
        }

        var resObj = JSON.parse(response)
        m_isbusy = false

        if (!resObj) {
            hasdata = false
            console.error("Cannot parse response")
            return
        }

        if (resObj.error) {
            hasdata = false
            errstring = resOjb.error.description
            return
        }

        if (resObj.query.count !== 1) {
            console.debug("Query count:", resObj.query.count)
            if (resObj.query.count === 0) {
                if (failedAttempts >= 30) {
                    hasdata = false
                    errstring = i18n("Error 2. WOEID may be invalid.")
                } else {
                    console.debug("Could be an API issue, try again. Attempts:", failedAttempts)
                    failedAttempts += 1
                    query()
                }
            } else {
                hasdata = false
                errstring = i18n("Error 2. WOEID may be invalid.")
            }
            return
        }
        
        // store successful response in case user needs to change units
        // then we can parse the response text without querying again
        m_response = response

        var results = resObj.query.results.channel
        
        m_lastBuildDate      = results.lastBuildDate
        m_link               = results.link
        m_city               = results.location.city
        m_region             = results.location.region
        m_country            = results.location.country
        m_unitDistance       = results.units.distance
        m_unitPressure       = results.units.pressure
        m_windChill          = results.wind.chill
        m_windDirection      = parseWind(results.wind.direction)
        m_windSpeed          = results.wind.speed
        m_atmosphereHumidity     = results.atmosphere.humidity
        m_atmosphereVisibility   = results.atmosphere.visibility
        m_atmospherePressure     = results.atmosphere.pressure
        m_atmosphereRising       = results.atmosphere.rising
        m_astronomySunrise       = results.astronomy.sunrise
        m_astronomySunset        = results.astronomy.sunset
        m_geoLat                 = results.item.lat
        m_geoLong                = results.item.long
        
        m_conditionIcon = determineIcon(parseInt(results.item.condition.code))
        m_conditionDesc = getDescription(parseInt(results.item.condition.code))
        m_conditionTemp = parseInt(results.item.condition.temp)
        
        // Unit conversions
        if (plasmoid.configuration.celsius) {
            m_unitTemperature = "C"
            m_windChill = fahrenheitToCelsius(m_windChill)
            m_conditionTemp = fahrenheitToCelsius(m_conditionTemp)
        } else {
            m_unitTemperature = "F"
        }
        if (plasmoid.configuration.ms) {
            m_unitSpeed = "m/s"
            m_windSpeed = kmhToMs(m_windSpeed)
        } else if (plasmoid.configuration.mph) {
            m_unitSpeed = "mph"
            m_windSpeed = kmToMi(m_windSpeed)
        } else {
            m_unitSpeed = "km/h"
        }
        if (plasmoid.configuration.mi) {
            m_atmosphereVisibility = kmToMi(m_atmosphereVisibility)
            m_unitDistance = "mi"
        } else {
            m_unitDistance = "km"
        }
        if (plasmoid.configuration.in) {
            m_atmospherePressure = mbarToIn(m_atmospherePressure)
            m_unitPressure = "inHg"
        } if (plasmoid.configuration.atm) {
            m_atmospherePressure = mbarToAtm(m_atmospherePressure)
            m_unitPressure = "atm"
        } else if (plasmoid.configuration.hpa) {
            m_unitPressure = "hPa"
        } else if (plasmoid.configuration.mbr) {
            m_unitPressure = "mbar"
        }

        var forecasts = results.item.forecast
        forecastModel.clear()
        for (var i = 0; i < forecasts.length; ++i) {
            var low = forecasts[i].low
            var high = forecasts[i].high
            if (plasmoid.configuration.celsius) {
                low = fahrenheitToCelsius(low)
                high = fahrenheitToCelsius(high)
            }

            forecastModel.append({
                "day": parseDay(forecasts[i].day),
                "temp": low + "~" + high + "°" + m_unitTemperature,
                "icon": determineIcon(parseInt(forecasts[i].code))
            })
        }
        console.debug(forecasts.length, "days forecast")

        hasdata = true
        failedAttempts = 0
    }

    // used to parse stored response again (refresh units)
    function reparse() {
        if (m_response) {
            getweatherinfo(m_response)
        }
    }

    function parseDay(daystring) {
        switch (daystring) {
            case "Sun":
                return i18n("Sunday")
            case "Mon":
                return i18n("Monday")
            case "Tue":
                return i18n("Tuesday")
            case "Wed":
                return i18n("Wednesday")
            case "Thu":
                return i18n("Thursday")
            case "Fri":
                return i18n("Friday")
            case "Sat":
                return i18n("Saturday")
        }
    }
    
    function determineIcon(code) {
        if (code <= 4) {
            return "weather-storm"
        }
        else if (code <= 6) {
            return "weather-snow-rain"
        }
        else if (code == 7 ) {
            return "weather-snow-scattered"
        }
        else if (code == 8 || code == 10) {
            return "weather-freezing-rain"
        }
        else if (code == 9) {
            return "weather-showers-scattered"
        }
        else if (code <= 12) {
            return "weather-showers"
        }
        else if (code <= 16) {
            return "weather-snow"
        }
        else if (code == 17) {
            return "weather-hail"
        }
        else if (code == 18) {//sleet
            return "weather-snow-scattered"
        }
        else if (code <= 22) {
            return "weather-mist"
        }
        else if (code <= 24) {//windy
            return "weather-clouds"
        }
        else if (code == 25) {//cold
            return "weather-freezing-rain"
        }
        else if (code == 26) {//cloudy
            return "weather-clouds"
        }
        else if (code <= 28) {
            return "weather-many-clouds"
        }
        else if (code == 29) {
            return "weather-few-clouds-night"
        }
        else if (code == 30) {
            return "weather-few-clouds"
        }
        else if (code == 31 || code == 33) {
            return "weather-clear-night"
        }
        else if (code == 32 || code == 34 || code ==36) {
            return "weather-clear"
        }
        else if (code == 35) {
            return "weather-hail"
        }
        else if (code <= 40) {
            return "weather-storm"
        }
        else if (code == 41 || code == 43) {
            return "weather-snow"
        }
        else if (code == 42 || code == 46) {
            return "weather-snow-rain"
        }
        else if (code == 44) {
            return "weather-few-clouds"
        }
        else if (code == 45 || code == 47) {
            return "weather-storm"
        }
        else {
            return "weather-none-available"
        }
    }
    
    function getDescription(conCode) {
        //according to http://developer.yahoo.com/weather/#codes
        switch (conCode) {
            case 0:
                return i18n("Tornado")
            case 1:
                return i18n("Tropical Storm")
            case 2:
                return i18n("Hurricane")
            case 3:
                return i18n("Severe Thunderstorms")
            case 4:
                return i18n("Thunderstorms")
            case 5:
                return i18n("Mixed Rain and Snow")
            case 6:
                return i18n("Mixed Rain and Sleet")
            case 7:
                return i18n("Mixed Snow and Sleet")
            case 8:
                return i18n("Freezing Drizzle")
            case 9:
                return i18n("Drizzle")
            case 10:
                return i18n("Freezing Rain")
            case 11://has same descr with 12
            case 12:
                return i18n("Showers")
            case 13:
                return i18n("Snow Flurries")
            case 14:
                return i18n("Light Snow Showers")
            case 15:
                return i18n("Blowing Snow")
            case 16:
                return i18n("Snow")
            case 17:
                return i18n("Hail")
            case 18:
                return i18n("Sleet")
            case 19:
                return i18n("Dust")
            case 20:
                return i18n("Foggy")
            case 21:
                return i18n("Haze")
            case 22:
                return i18n("Smoky")
            case 23:
                return i18n("Blustery")
            case 24:
                return i18n("Windy")
            case 25:
                return i18n("Cold")
            case 26:
                return i18n("Cloudy")
            case 27:
                return i18n("Mostly Cloudy (Night)")
            case 28:
                return i18n("Mostly Cloudy (Day)")
            case 29:
                return i18n("Partly Cloudy (Night)")
            case 30:
                return i18n("Partly Cloudy (Day)")
            case 31:
                return i18n("Clear (Night)")
            case 32:
                return i18n("Sunny")
            case 33:
                return i18n("Fair (Night)")
            case 34:
                return i18n("Fair (Day)")
            case 35:
                return i18n("Mixed Rain and Hail")
            case 36:
                return i18n("Hot")
            case 37:
                return i18n("Isolated Thunderstorms")
            case 38://same with 39
            case 39:
                return i18n("Scattered Thunderstorms")
            case 40:
                return i18n("Scattered Showers")
            case 41://same with 43
            case 43:
                return i18n("Heavy Snow")
            case 42:
                return i18n("Scattered Snow Showers")
            case 44:
                return i18n("Partly Cloudy")
            case 45:
                return i18n("Thundershowers")
            case 46:
                return i18n("Snow Showers")
            case 47:
                return i18n("Isolated Thundershowers")
            default://code 3200
                return i18n("Not Available")
        }
    }

    function parseWind(d) {
        if (d == 0) {
            return " "
        } else if (0 <= d && d < 11.25) {
            return "⭡ N"
        } else if (11.25 <= d && d < 33.75) {
            return "⭎ NNE"
        } else if (33.75 <= d && d < 56.25) {
            return "⭧ NE"
        } else if (56.25 <= d && d < 78.75) {
            return "⭧ ENE"
        } else if (78.75 <= d && d < 101.25) {
            return "⭢ E"
        } else if (101.25 <= d && d < 123.75) {
            return "⭨ ESE"
        } else if (123.75 <= d && d < 146.25) {
            return "⭨ SE"
        } else if (146.25 <= d && d < 168.75) {
            return "⭏ SSE"
        } else if (168.75 <= d && d < 191.25) {
            return "⭣ S"
        } else if (191.25 <= d && d < 213.75) {
            return "⭩ SSW"
        } else if (213.75 <= d && d < 236.25) {
            return "⭩ SW"
        } else if (236.25 <= d && d < 258.75) {
            return "⭩ WSW"
        } else if (258.75 <= d && d < 281.25) {
            return "⭠ W"
        } else if (281.25 <= d && d < 303.75) {
            return "⭦ WNW"
        } else if (303.75 <= d && d < 326.25) {
            return "⭦ NW"
        } else if (326.25 <= d && d < 348.75) {
            return "⭦ NNW"
        } else if (348.75 <= d && d < 360) {
            return "⭡ N"
        } else if (d == 990) {
            return "⥀"
        } else {
            return " "
        }
    }

    // convert fahrenheit to celsius
    function fahrenheitToCelsius(f) {
        if (!f) {
            return undefined
        }
        if (typeof f !== "number") {
            f = parseFloat(f)
        }
        var c = (f - 32) * 5 / 9
        return c.toFixed(0)
    }

    // convert km/h to m/s
    function kmhToMs(m) {
        if (!m) {
            return undefined
        }
        if (typeof m !== "number") {
            m = parseFloat(m)
        }
        var k = m / 3.6
        return k.toFixed(2)
    }

    // convert kilometre to mile
    function kmToMi(m) {
        if (!m) {
            return undefined
        }
        if (typeof m !== "number") {
            m = parseFloat(m)
        }
        var k = m / 1.609344
        return k.toFixed(2)
    }
    
    // convert mbar to inch of mercury
    function mbarToIn(m) {
        if (!m) {
            return undefined
        }
        if (typeof m !== "number") {
            m = parseFloat(m)
        }
        var k = m / 33.8638867
        return k.toFixed(2)
    }
    
    // convert mbar to atmosphere
    function mbarToAtm(m) {
        if (!m) {
            return undefined
        }
        if (typeof m !== "number") {
            m = parseFloat(m)
        }
        var k = m / 1013.25
        return k.toFixed(0)
    }
}

