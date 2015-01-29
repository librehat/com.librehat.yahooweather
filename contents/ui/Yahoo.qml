/*
 *   Authour: Symeon Huang (librehat) <hzwhuang@gmail.com>
 *   Copyright 2014-2015
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 3 or
 *   (at your option) any later version.
 */

import QtQuick 2.2
import QtQuick.XmlListModel 2.0

Item {
    id: yahoo
    
    property string unitsymbol;
    
    XmlListModel {
        id: yhModel
        query: '/rss/channel'
        
        namespaceDeclarations: "declare namespace yweather='http://xml.weather.yahoo.com/ns/rss/1.0'; declare namespace geo='http://www.w3.org/2003/01/geo/wgs84_pos#';"
        
        XmlRole { name: 'lastbuilddate'; query: 'lastBuildDate/string()' }
        XmlRole { name: 'link'; query: 'link/string()' }
        XmlRole { name: 'city'; query: 'yweather:location/@city/string()' }
        XmlRole { name: 'region'; query: 'yweather:location/@region/string()' }
        XmlRole { name: 'country'; query: 'yweather:location/@country/string()' }
        XmlRole { name: 'unittemp' ; query: 'yweather:units/@temperature/string()' }
        XmlRole { name: 'unitdist' ; query: 'yweather:units/@distance/string()' }
        XmlRole { name: 'unitpressure' ; query: 'yweather:units/@pressure/string()' }
        XmlRole { name: 'unitspeed' ; query: 'yweather:units/@speed/string()' }
        XmlRole { name: 'windchill' ; query: 'yweather:wind/@chill/string()' }
        XmlRole { name: 'winddirection' ; query: 'yweather:wind/@direction/string()' }
        XmlRole { name: 'windspeed' ; query: 'yweather:wind/@speed/string()' }
        XmlRole { name: 'atmospherehumidity' ; query: 'yweather:atmosphere/@humidity/string()' }
        XmlRole { name: 'atmospherevisibility' ; query: 'yweather:atmosphere/@visibility/string()' }
        XmlRole { name: 'atmospherepressure' ; query: 'yweather:atmosphere/@pressure/string()' }
        XmlRole { name: 'atmosphererising' ; query: 'yweather:atmosphere/@rising/string()' }
        XmlRole { name: 'astronomysunrise' ; query: 'yweather:astronomy/@sunrise/string()' }
        XmlRole { name: 'astronomysunset' ; query: 'yweather:astronomy/@sunset/string()' }
        
        XmlRole { name: 'geolat' ; query: 'item/geo:lat/string()' }
        XmlRole { name: 'geolong' ; query: 'item/geo:long/string()' }

        XmlRole { name: 'conditioncode'; query: 'item/yweather:condition/@code/string()' }
        XmlRole { name: 'conditiontemp'; query: 'item/yweather:condition/@temp/string()' }
        
        XmlRole { name: 'todayday' ; query: 'item/yweather:forecast[1]/@day/string()' }
        XmlRole { name: 'todaylow' ; query: 'item/yweather:forecast[1]/@low/string()' }
        XmlRole { name: 'todayhigh' ; query: 'item/yweather:forecast[1]/@high/string()' }
        XmlRole { name: 'todaycode' ; query: 'item/yweather:forecast[1]/@code/string()' }
        XmlRole { name: 'tomorrowday' ; query: 'item/yweather:forecast[2]/@day/string()' }
        XmlRole { name: 'tomorrowlow' ; query: 'item/yweather:forecast[2]/@low/string()' }
        XmlRole { name: 'tomorrowhigh' ; query: 'item/yweather:forecast[2]/@high/string()' }
        XmlRole { name: 'tomorrowcode' ; query: 'item/yweather:forecast[2]/@code/string()' }
        XmlRole { name: 'afterTday' ; query: 'item/yweather:forecast[3]/@day/string()' }
        XmlRole { name: 'afterTlow' ; query: 'item/yweather:forecast[3]/@low/string()' }
        XmlRole { name: 'afterThigh' ; query: 'item/yweather:forecast[3]/@high/string()' }
        XmlRole { name: 'afterTcode' ; query: 'item/yweather:forecast[3]/@code/string()' }
        XmlRole { name: 'fourday' ; query: 'item/yweather:forecast[4]/@day/string()' }
        XmlRole { name: 'fourlow' ; query: 'item/yweather:forecast[4]/@low/string()' }
        XmlRole { name: 'fourhigh' ; query: 'item/yweather:forecast[4]/@high/string()' }
        XmlRole { name: 'fourcode' ; query: 'item/yweather:forecast[4]/@code/string()' }
        XmlRole { name: 'fiveday' ; query: 'item/yweather:forecast[5]/@day/string()' }
        XmlRole { name: 'fivelow' ; query: 'item/yweather:forecast[5]/@low/string()' }
        XmlRole { name: 'fivehigh' ; query: 'item/yweather:forecast[5]/@high/string()' }
        XmlRole { name: 'fivecode' ; query: 'item/yweather:forecast[5]/@code/string()' }
        
        onCountChanged: getweatherinfo();

        onStatusChanged: {// include Errorhandling
            if (status === XmlListModel.Error)   {// sh033
                console.debug("XmlListModel.Error: ", errorString);
                repeatquery.running = true;
            }
        }
    }
    
    // timer for repeat query from sh033
    Timer {
        id: repeatquery
        interval: 10000
        running: false
        repeat: true
        onTriggered: {
            running = false;
            console.debug("Reapeat Query.. ");
            query (mainWindow.m_woeid);
        }
    }
    
    function query(woeid) {
        console.debug("Querying...");
        yhModel.reload();//remove old data
        
        mainWindow.m_isbusy = true;//set BusyIndicator running and shown
        
        if (woeid == "") {
            mainWindow.hasdata = false;
            mainWindow.m_isbusy = false;
            console.debug("WOEID is empty.");
            return;//fail silently
        }
        
        if (mainWindow.m_unitCelsius) {
            unitsymbol = "c";
        }
        else {
            unitsymbol = "f";
        }
        yhModel.source = "http://weather.yahooapis.com/forecastrss?w=" + woeid + "&u=" + unitsymbol;
    }
    
    function getweatherinfo() {
        console.debug("Getting Weather Information...");
        mainWindow.m_isbusy = false;
        
        if (typeof yhModel != "object" || typeof yhModel.get(0) != "object") {
            mainWindow.hasdata = false;
            mainWindow.errstring = i18n("Error 1. Please check your network.");
            console.debug("yhModel or yhModel.get(0) is not an object.")
            return;
        }
        
        mainWindow.m_lastBuildDate = yhModel.get(0).lastbuilddate;
        mainWindow.m_link = yhModel.get(0).link;
        mainWindow.m_city = yhModel.get(0).city;
        mainWindow.m_region = yhModel.get(0).region;
        mainWindow.m_country = yhModel.get(0).country;
        mainWindow.m_unitTemperature = yhModel.get(0).unittemp;
        mainWindow.m_unitDistance = yhModel.get(0).unitdist;
        mainWindow.m_unitPressure = yhModel.get(0).unitpressure;     
        mainWindow.m_windChill = yhModel.get(0).windchill;
        mainWindow.m_windDirection = yhModel.get(0).winddirection;
        mainWindow.m_windSpeed = yhModel.get(0).windspeed;
        if (mainWindow.m_unitms) {
            mainWindow.m_unitSpeed = "m/s";
            mainWindow.m_windSpeed = Math.round(mainWindow.m_windSpeed * 1000 / 3600, 3);
        }
        else {
            mainWindow.m_unitSpeed = "km/h";
        }
        mainWindow.m_atmosphereHumidity = yhModel.get(0).atmospherehumidity;
        mainWindow.m_atmosphereVisibility = yhModel.get(0).atmospherevisibility;
        mainWindow.m_atmospherePressure = yhModel.get(0).atmospherepressure;
        mainWindow.m_atmosphereRising = yhModel.get(0).atmosphererising;
        mainWindow.m_astronomySunrise = yhModel.get(0).astronomysunrise;
        mainWindow.m_astronomySunset = yhModel.get(0).astronomysunset;
        mainWindow.m_geoLat = yhModel.get(0).geolat;
        mainWindow.m_geoLong = yhModel.get(0).geolong;
        mainWindow.m_conditionCode = parseInt(yhModel.get(0).conditioncode);
        mainWindow.m_conditionTemp = parseInt(yhModel.get(0).conditiontemp);
        mainWindow.m_todayDay = getDayLocalisation(yhModel.get(0).todayday);
        mainWindow.m_todayLow = parseInt(yhModel.get(0).todaylow);
        mainWindow.m_todayHigh = parseInt(yhModel.get(0).todayhigh);
        mainWindow.m_todayCode = parseInt(yhModel.get(0).todaycode);
        mainWindow.m_tomorrowDay = getDayLocalisation(yhModel.get(0).tomorrowday);
        mainWindow.m_tomorrowLow = parseInt(yhModel.get(0).tomorrowlow);
        mainWindow.m_tomorrowHigh = parseInt(yhModel.get(0).tomorrowhigh);
        mainWindow.m_tomorrowCode = parseInt(yhModel.get(0).tomorrowcode);
        mainWindow.m_afterTDay = getDayLocalisation(yhModel.get(0).afterTday);
        mainWindow.m_afterTLow = parseInt(yhModel.get(0).afterTlow);
        mainWindow.m_afterTHigh = parseInt(yhModel.get(0).afterThigh);
        mainWindow.m_afterTCode = parseInt(yhModel.get(0).afterTcode);
        mainWindow.m_4Day = getDayLocalisation(yhModel.get(0).fourday);
        mainWindow.m_4Low = parseInt(yhModel.get(0).fourlow);
        mainWindow.m_4High = parseInt(yhModel.get(0).fourhigh);
        mainWindow.m_4Code = parseInt(yhModel.get(0).fourcode);
        mainWindow.m_5Day = getDayLocalisation(yhModel.get(0).fiveday);
        mainWindow.m_5Low = parseInt(yhModel.get(0).fivelow);
        mainWindow.m_5High = parseInt(yhModel.get(0).fivehigh);
        mainWindow.m_5Code = parseInt(yhModel.get(0).fivecode);
        
        if (mainWindow.m_city != "") {
            mainWindow.hasdata = true;
            console.debug("done.");
        }
        else {
            mainWindow.hasdata = false;
            mainWindow.errstring = i18n("Error 2. WOEID may be invalid.");
            console.debug("m_city is empty.");
        }
    }
    
    function getDayLocalisation(daystring) {
        switch (daystring) {
            case "Sun":
                return i18n("Sunday");
            case "Mon":
                return i18n("Monday");
            case "Tue":
                return i18n("Tuesday");
            case "Wed":
                return i18n("Wednesday");
            case "Thu":
                return i18n("Thursday");
            case "Fri":
                return i18n("Friday");
            case "Sat":
                return i18n("Saturday");
        }
    }
}
