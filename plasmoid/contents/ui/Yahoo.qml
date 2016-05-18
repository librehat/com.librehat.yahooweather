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
    
    property bool hasdata: false // set only by setPlasmoidIconAndTips(has_data)
    property string errstring    // used to display error on widget
    property bool m_isbusy: false
    property bool haveQueried: false
    property bool networkError: false
    property int numRetries: 0
    property int saveReadyState: 0
    property var doc: undefined

    property string m_pubDate;
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
    
    // 10s timer for repeat query from sh033
    Timer {
        id: repeatquery
        interval: 10000
        running: false
        repeat: false 
        onTriggered: {
            console.debug("Repeat Query.. ")
            if (saveReadyState === XMLHttpRequest.OPENED) {
                // timed out in readyState 1 (OPENED); abort the previous
                // query which causes a transitions to state 4 (DONE)
                // Avoids hang in readyState 1 while network down.
                console.debug("doc.abort() called")
                doc.abort()
                numRetries = 4; // immediately make errstring visible
            }
            query()
        }
    }
    
    function query(woeid) {
        console.debug("Querying...")
        
        haveQueried = true;
        m_isbusy = true
        woeid = woeid ? woeid : plasmoid.configuration.woeid
        if (!woeid) {
            setPlasmoidIconAndTips(false, false)
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
        doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            saveReadyState = doc.readyState
            if (doc.readyState === XMLHttpRequest.DONE) {
                repeatquery.stop()
                if (doc.status === 200) {
                    getweatherinfo(doc.responseText)
                    networkError = false;
                    numRetries = 0;
                } else {
                    if (networkError || numRetries > 3) {
                        // don't display error until several retries occur
                        errstring = i18n("Error 1. Please check your network.")
                        setPlasmoidIconAndTips(false)
                        networkError = true;
                    }
                    console.debug("HTTP request failed, trying again.", doc.status)
                    repeatquery.interval = 10000
                    repeatquery.start()
                    numRetries++;
                }
            } else if (doc.readyState === XMLHttpRequest.OPENED) {
                // Start timer to avoid response stuck at readyState of 1 (OPENED)
                // before DONE (4). query() will only be called again if the
                // timer times out (in 50 seconds).  
                repeatquery.start()
                repeatquery.interval = 50000
            } else {
                // readyState is 2 (HEADERS_RECEIVED) or 3 (LOADING).
                // stop/reset timer in case previous readyState was 1 (OPENED)
                repeatquery.stop()
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

        if (!resObj) {
            setPlasmoidIconAndTips(false, false)
            console.error("Cannot parse response")
            return
        }

        if (resObj.error) {
            setPlasmoidIconAndTips(false, false)
            errstring = resObj.error.description
            console.error("Error message from API:", errstring)
            return
        }

        if ((resObj.query.count === 0) || ((resObj.query.count === 1) &&
            (resObj.query.results.channel.description === undefined))) {
            // query.count is zero OR it is 1 but the result not parsable.
            // This usually indicates a bad WOEID was entered. But retry
            // the query up to 30 times in case this is possibly an incomplete
            // or corrupted response.
            if (failedAttempts >= 30) {
                console.debug("query.count =", resObj.query.count)
                setPlasmoidIconAndTips(false, false)
                errstring = i18n("Error 2. WOEID may be invalid.")
                failedAttempts = 0
            } else {
                console.debug("Could be an API issue, try again. Attempts:", failedAttempts)
                failedAttempts += 1
                query()
            }
            return
        } else if (resObj.query.count !== 1) {
            // count is neither 0 or 1 which is immediately invalid; no retry
            console.debug("query.count not 0 or 1")
            setPlasmoidIconAndTips(false, false)
            errstring = i18n("Error 2. WOEID may be invalid.")
            return
        }
        
        // store successful response in case user needs to change units
        // then we can parse the response text without querying again
        m_response = response

        var results = resObj.query.results.channel
        m_pubDate            = fixTime(results.item.pubDate, plasmoid.configuration.timeFormat24)
        m_link               = results.link
        m_city               = results.location.city
        m_region             = results.location.region
        m_country            = results.location.country
        m_windChill          = results.wind.chill
        m_windDirection      = parseWind(results.wind.direction)
        m_windSpeed          = results.wind.speed
        m_atmosphereHumidity     = results.atmosphere.humidity
        m_atmosphereVisibility   = results.atmosphere.visibility
        m_atmospherePressure     = results.atmosphere.pressure
        m_atmosphereRising       = parseRising(results.atmosphere.rising)
        m_astronomySunrise       = fixTime(results.astronomy.sunrise, plasmoid.configuration.timeFormat24)
        m_astronomySunset        = fixTime(results.astronomy.sunset, plasmoid.configuration.timeFormat24)
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
        
        if (plasmoid.configuration.inhg) {
            m_atmospherePressure = mbarToIn(m_atmospherePressure)
            m_unitPressure = "inHg"
        } else if (plasmoid.configuration.atm) {
            m_atmospherePressure = mbarToAtm(m_atmospherePressure)
            m_unitPressure = "atm"
        } else if (plasmoid.configuration.hpa) {
            m_unitPressure = "hPa"
        } else {
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
                "tempHi": high + "°" + m_unitTemperature,
                "tempLo": low  + "°" + m_unitTemperature,
                "icon": determineIcon(parseInt(forecasts[i].code))
            })
        }
        console.debug(forecasts.length, "days forecast")

        setPlasmoidIconAndTips(true, false)
        failedAttempts = 0
    }

    // used to parse stored response again (refresh units)
    function reparse() {
        if (m_response) {
            getweatherinfo(m_response)
        }
    }

    // Call this to set tray icon and tool tips determined by bool
    // parameter assigned to hasdata. hasdata only set by this function.
    // This replaces the 1s timer that polled for hasdata when m_isbusy 
    // and serves the same purpose (but with fewer timing issues). 
    // Note: icon and tool tips set here only relevant to compact 
    // representation (widget installed to tray).
    //
    function setPlasmoidIconAndTips(has_data, is_busy) {
        if(!has_data) {
            plasmoid.icon = "weather-none-available"
            plasmoid.toolTipMainText = i18n("Click tray icon")
            plasmoid.toolTipSubText = i18n("for error details")
        } 
        else {
            plasmoid.icon = m_conditionIcon
            plasmoid.toolTipMainText = m_city + " " + m_conditionTemp + "°" + m_unitTemperature
            plasmoid.toolTipSubText = m_conditionDesc
        }
        hasdata = has_data 
        if (!(is_busy == undefined)) {
            m_isbusy = is_busy
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
        if (d === null || d === undefined) {
            return undefined;
        }

        if (typeof d !== "number") {
            d = parseFloat(d)
        }

        if (d < 0) {
            return " "
        } else if (d < 11.25) {
            return "↓"
        } else if (d < 33.75) {
            return "↙"
        } else if (d < 56.25) {
            return "↙"
        } else if (d < 78.75) {
            return "↙"
        } else if (d < 101.25) {
            return "←"
        } else if (d < 123.75) {
            return "↖"
        } else if (d < 146.25) {
            return "↖"
        } else if (d < 168.75) {
            return "↖"
        } else if (d < 191.25) {
            return "↑"
        } else if (d < 213.75) {
            return "↗"
        } else if (d < 236.25) {
            return "↗"
        } else if (d < 258.75) {
            return "↗"
        } else if (d < 281.25) {
            return "→"
        } else if (d < 303.75) {
            return "↘"
        } else if (d < 326.25) {
            return "↘"
        } else if (d < 348.75) {
            return "↘"
        } else if (d < 360) {
            return "↓"
        } else if (d == 990) {
            return "⥀"
        } else {
            return " "
        }
    }
    
    function parseRising(r) {
        if (r === null || r === undefined) {
            return undefined;
        }

        if (typeof r !== "number") {
            r = parseInt(r)
        }
        
        switch (r) {
            case 0:
                return "→";//steady
            case 1:
                return "↑";//rising
            case 2:
                return "↓";//falling
            default:
                return "";
        }
    }

    // Insert missing leading 0 on minutes if necessary.
    // E.g., if s = "8:7 pm" change to "8:07 pm"
    // In addition, if convert24 is true, change "8:07 pm" 
    // to "20:07" or 3:07 am to "03:07", etc.
    function fixTime(s, convert24) {
        if (typeof s !== "string")
            return undefined

        var hour_colon
        var len = s.length;
        var colonIndex = s.indexOf(":")
        if (colonIndex == -1) {
            return undefined // call when not a time string!
        }
        // see if 2nd (leading) minute digit is missing (i.e., it's not a number)
        var min_digit2 = s.slice(colonIndex+2, colonIndex+3)
        if (isNaN(parseInt(min_digit2))) {
            // 2nd minute digit is missing, append leading '0'
            hour_colon = s.slice(0, colonIndex+1)
            var min_am_or_pm = s.slice(colonIndex+1, len)
            s = hour_colon + "0" + min_am_or_pm
        }

        if (convert24) {
            hour_colon = s.slice(0, colonIndex+1)
            len = s.length
            var min_am_or_pm = s.slice(colonIndex+1, len)
            var amIndex = min_am_or_pm.search(/am/i)
            var hour
            if ((amIndex == 2) || (amIndex == 3)) {
                // AM is located next to minute or separated by 1 space. 
                // Avoid removing possible "AM" in the trailing time zone characters,
                // so remove only the first "am" or "AM" from string
                min_am_or_pm = min_am_or_pm.replace(/am|am /i, "")
                // add leading 0 to hour if not already present
                if (colonIndex == 1) {
                    // hour is a single digit (this is sunrise or sunset)
                    hour_colon = "0" + hour_colon
                } else { 
                    // possibly more than a single hour digit in a time field.
                    var leading_digit = hour_colon.slice(colonIndex-2, colonIndex-1)
                    if (leading_digit == " ") {
                        // leading hour digit is blank, change it to "0"
                        hour_colon = hour_colon.slice(0, colonIndex-1) + "0" +
                                     hour_colon.slice(colonIndex-1)
                    } else {
                        // both hour digits are a number. If hour is 12 AM,
                        // change to 00.
                        if ((leading_digit == "1") && (hour_colon.slice(colonIndex-1, colonIndex) == "2")) {
                            hour_colon = hour_colon.substr(0, colonIndex-2) + "00" +
                                         hour_colon.slice(colonIndex)
                        }
                    }
                }
            } else {
                // must be PM
                // remove first "pm" or "PM" from string
                min_am_or_pm = min_am_or_pm.replace(/pm|pm /i, "")
                // find hour and add 12, but not when 12 pm 
                if (colonIndex <= 2) {
                    // this fixes-up sunrise and sunset times.
                    // decode hours from index 0.
                    hour = parseInt(hour_colon.slice(0, colonIndex))
                    if (hour != 12)
                        hour += 12
                    hour_colon = hour + ":"
                } else {
                    // this fixes-up the pubDate time substring.
                    // decode exactly 2 before colon.
                    hour = parseInt(hour_colon.slice(colonIndex-2, colonIndex))
                    if (hour != 12)
                        hour += 12
                    var leadingText = hour_colon.slice(0, colonIndex-2)
                    if (leadingText.charAt(-1 + leadingText.length) != " ") {
                        // leadingText does not end in blank so append a space
                        // char to separate hour from leadingText.
                        leadingText += " ";
                    }
                    hour_colon = leadingText + hour + ":" 
                }
            }
            // reassemble modified string
            s = hour_colon + min_am_or_pm
        }
        return s
    }

    // convert fahrenheit to celsius
    function fahrenheitToCelsius(f) {
        if (f === null || f === undefined) {
            return undefined
        }
        if (typeof f !== "number") {
            f = parseInt(f)
        }
        var c = (f - 32) * 5 / 9
        return c.toFixed(0)
    }

    // convert km/h to m/s
    function kmhToMs(m) {
        if (m === null || m === undefined) {
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
        if (m === null || m === undefined) {
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
        if (m === null || m === undefined) {
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
        if (m === null || m === undefined) {
            return undefined
        }
        if (typeof m !== "number") {
            m = parseFloat(m)
        }
        var k = m / 1013.25
        return k.toFixed(2)
    }
}

