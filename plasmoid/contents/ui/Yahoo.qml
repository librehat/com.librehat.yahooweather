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

    //<item>/<geo:lat> and <geo:long>
    property string m_geoLat
    property string m_geoLong

    //<yweather:condition>
    property int m_conditionCode
    property int m_conditionTemp

    //<yweather:forecast>
    property string m_todayDay
    property int m_todayLow
    property int m_todayHigh
    property int m_todayCode
    property string m_tomorrowDay
    property int m_tomorrowLow
    property int m_tomorrowHigh
    property int m_tomorrowCode
    property string m_afterTDay
    property int m_afterTLow
    property int m_afterTHigh
    property int m_afterTCode
    //today is day 1
    property string m_4Day
    property int m_4Low
    property int m_4High
    property int m_4Code
    property string m_5Day
    property int m_5Low
    property int m_5High
    property int m_5Code

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
        
        var source = "http://query.yahooapis.com/v1/public/yql?q=select * from weather.forecast where woeid='" + woeid + "' and u='" + unitsymbol + "'&format=json"
        console.debug("Source changed to", source)
        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                getweatherinfo(doc.responseText)
            }
        }
        doc.open("GET", source, true)
        doc.send()
    }
    
    function getweatherinfo(response) {
        console.debug("Getting Weather Information...")
        if (!response) {
            console.debug("response is empty.")
            return
        }
        
        var resObj = JSON.parse(response)
        m_isbusy = false
        
        console.debug(response)
        
        if (resObj.error) {
            hasdata = false
            errstring = resOjb.error.description
            return
        }
        
        if (!resObj.query) {
            hasdata = false
            errstring = i18n("Error 1. Please check your network.")
            console.debug("query is not a property of response object")
            repeatquery.running = true
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
        
        var results = resObj.query.results.channel
        
        m_lastBuildDate      = results.lastBuildDate
        m_link               = results.link
        m_city               = results.location.city
        m_region             = results.location.region
        m_country            = results.location.country
        m_unitTemperature    = results.units.temperature
        m_unitDistance       = results.units.distance
        m_unitPressure       = results.units.pressure
        m_windChill          = results.wind.chill
        m_windDirection      = results.wind.direction
        m_windSpeed          = results.wind.speed
        if (plasmoid.configuration.ms) {
            m_unitSpeed      = "m/s"
            m_windSpeed      = Math.round(m_windSpeed * 1000 / 3600, 3)
        } else {
            m_unitSpeed      = "km/h"
        }
        m_atmosphereHumidity     = results.atmosphere.humidity
        m_atmosphereVisibility   = results.atmosphere.visibility
        m_atmospherePressure     = results.atmosphere.pressure
        m_atmosphereRising       = results.atmosphere.rising
        m_astronomySunrise       = results.astronomy.sunrise
        m_astronomySunset        = results.astronomy.sunset
        m_geoLat                 = results.item.lat
        m_geoLong                = results.item.long
        m_conditionCode = parseInt(results.item.condition.code)
        m_conditionTemp = parseInt(results.item.condition.temp)
        
        var forecasts = results.item.forecast
        m_todayDay      = parseDay(forecasts[0].day)
        m_todayLow      = parseInt(forecasts[0].low)
        m_todayHigh     = parseInt(forecasts[0].high)
        m_todayCode     = parseInt(forecasts[0].code)
        m_tomorrowDay   = parseDay(forecasts[1].day)
        m_tomorrowLow   = parseInt(forecasts[1].low)
        m_tomorrowHigh  = parseInt(forecasts[1].high)
        m_tomorrowCode  = parseInt(forecasts[1].code)
        m_afterTDay     = parseDay(forecasts[2].day)
        m_afterTLow     = parseInt(forecasts[2].low)
        m_afterTHigh    = parseInt(forecasts[2].high)
        m_afterTCode    = parseInt(forecasts[2].code)
        m_4Day          = parseDay(forecasts[3].day)
        m_4Low          = parseInt(forecasts[3].low)
        m_4High         = parseInt(forecasts[3].high)
        m_4Code         = parseInt(forecasts[3].code)
        m_5Day          = parseDay(forecasts[4].day)
        m_5Low          = parseInt(forecasts[4].low)
        m_5High         = parseInt(forecasts[4].high)
        m_5Code         = parseInt(forecasts[4].code)
        
        hasdata = true
        failedAttempts = 0
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
}
