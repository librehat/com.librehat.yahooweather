/*
 *   Author: Symeon Huang (librehat) <hzwhuang@gmail.com>
 *   Copyright 2016
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 3 or
 *   (at your option) any later version.
 */

import QtQuick 2.2
import QtQuick.Layouts 1.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents 

Item {
    Layout.minimumWidth: units.gridUnit * 17
    Layout.minimumHeight: units.gridUnit * 24
    clip: true

    //Yahoo.qml implements the API and stores relevant data
    Yahoo {
        id: backend
    }
    
    property alias hasdata: backend.hasdata
    property alias errstring: backend.errstring
    property alias m_isbusy: backend.m_isbusy

    property alias m_lastBuildDate: backend.m_lastBuildDate
    property alias m_link: backend.m_link
    property alias m_city: backend.m_city
    property alias m_region: backend.m_region
    property alias m_country: backend.m_country
    property alias m_unitTemperature: backend.m_unitTemperature
    property alias m_unitDistance: backend.m_unitDistance
    property alias m_unitPressure: backend.m_unitPressure
    property alias m_unitSpeed: backend.m_unitSpeed
    property alias m_windChill: backend.m_windChill
    property alias m_windDirection: backend.m_windDirection
    property alias m_windSpeed: backend.m_windSpeed
    property alias m_atmosphereHumidity: backend.m_atmosphereHumidity
    property alias m_atmosphereVisibility: backend.m_atmosphereVisibility
    property alias m_atmospherePressure: backend.m_atmospherePressure
    property alias m_atmosphereRising: backend.m_atmosphereRising
    property alias m_astronomySunrise: backend.m_astronomySunrise
    property alias m_astronomySunset: backend.m_astronomySunset

    //<item>/<geo:lat> and <geo:long>
    property alias m_geoLat: backend.m_geoLat
    property alias m_geoLong: backend.m_geoLong

    //<yweather:condition>
    property alias m_conditionCode: backend.m_conditionCode
    property alias m_conditionTemp: backend.m_conditionTemp

    //<yweather:forecast>
    property alias m_todayDay: backend.m_todayDay
    property alias m_todayLow: backend.m_todayLow
    property alias m_todayHigh: backend.m_todayHigh
    property alias m_todayCode: backend.m_todayCode
    property alias m_tomorrowDay: backend.m_tomorrowDay
    property alias m_tomorrowLow: backend.m_tomorrowLow
    property alias m_tomorrowHigh: backend.m_tomorrowHigh
    property alias m_tomorrowCode: backend.m_tomorrowCode
    property alias m_afterTDay: backend.m_afterTDay
    property alias m_afterTLow: backend.m_afterTLow
    property alias m_afterTHigh: backend.m_afterTHigh
    property alias m_afterTCode: backend.m_afterTCode
    property alias m_4Day: backend.m_4Day
    property alias m_4Low: backend.m_4Low
    property alias m_4High: backend.m_4High
    property alias m_4Code: backend.m_4Code
    property alias m_5Day: backend.m_5Day
    property alias m_5Low: backend.m_5Low
    property alias m_5High: backend.m_5High
    property alias m_5Code: backend.m_5Code

    //UI block
    PlasmaComponents.Label {
        //top-left
        id: cityname
        visible: hasdata
        anchors { top: parent.top; left: parent.left }
        text: "<strong>" + m_city + "</strong><br />" + (m_region == "" ? m_country : m_region + "， " + m_country)
    }

    PlasmaComponents.Label {
        //top-right
        id: yahoo_n_date
        visible: hasdata
        anchors { top: parent.top; right: parent.right }
        text: m_lastBuildDate + "<br /><a href='" + m_link + "'>" + i18n("YAHOO! Weather") + "</a>"
        horizontalAlignment: Text.AlignRight
        font.family: theme.smallestFont.family
        font.italic: theme.smallestFont.italic
        font.pointSize: theme.smallestFont.pointSize
        font.weight: theme.smallestFont.weight
        onLinkActivated: Qt.openUrlExternally(link)
    }

    Row {
        id: conditionRow
        visible: hasdata
        anchors { top: yahoo_n_date.bottom; left:parent.left; right: parent.right }
        spacing: units.gridUnit * 2

        Column {
            id: conditionCol
            PlasmaComponents.Label {
                id: conditiontemp
                text: m_conditionTemp + "°" + m_unitTemperature
                font.weight: Font.Bold
                font.pointSize: theme.defaultFont.pointSize * 4.5
            }

            PlasmaComponents.Label {
                text: i18n("Sunrise") + ": " + m_astronomySunrise + "<br />" + i18n("Sunset") + ": " + m_astronomySunset
            }
        }

        PlasmaCore.IconItem {
            id: conditionIcon
            source: determineIcon(m_conditionCode)
            width: Math.min(conditionCol.height * 1.4, conditionRow.width * 0.5, 256)//don't be too large
            height: width
            usesPlasmaTheme: true
        }
    }

    Row {
        id: moredetails
        visible: hasdata
        anchors { top: conditionRow.bottom; horizontalCenter: parent.horizontalCenter }
        spacing: Math.max(6, (parent.width - firstDetail.width - secondDetail.width - thirdDetail.width) / 2)

        PlasmaComponents.Label {
            id: firstDetail
            text: i18n("Feels like") + ": " + m_windChill + "°" + m_unitTemperature + "<br />" + i18n("Visibility") + ": " + (m_atmosphereVisibility != "" ? m_atmosphereVisibility + m_unitDistance : i18n("NULL"))
            font.pointSize: theme.defaultFont.pointSize * 0.9
        }

        PlasmaComponents.Label {
            id: secondDetail
            text: i18n("Humidity") + ": " + m_atmosphereHumidity + "%<br />" + i18n("Pressure") + ": " + m_atmospherePressure + m_unitPressure
            font.pointSize: theme.defaultFont.pointSize * 0.9
        }

        PlasmaComponents.Label {
            id: thirdDetail
            text: i18n("UV Index") + ": " + m_atmosphereRising + "<br />" + i18n("Wind") + ": " + m_windSpeed + m_unitSpeed
            font.pointSize: theme.defaultFont.pointSize * 0.9
        }
    }

    Column {
        //first column
        id: dayscol
        visible: hasdata
        anchors { top: moredetails.bottom; topMargin: units.gridUnit; left: parent.left; leftMargin:units.gridUnit; bottom: parent.bottom }
        spacing: units.gridUnit

        PlasmaComponents.Label {
            id: todayLabel
            text: i18n("Today")
            font.weight: Font.DemiBold
            height: Math.max((dayscol.height - 24)/5, paintedHeight)
            horizontalAlignment: Text.AlignHCenter
        }

        PlasmaComponents.Label {
            text: i18n("Tomorrow")
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            height: todayLabel.height
        }

        PlasmaComponents.Label {
            text: m_afterTDay
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            height: todayLabel.height
        }

        PlasmaComponents.Label {
            text: m_4Day
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            height: todayLabel.height
        }

        PlasmaComponents.Label {
            text: m_5Day
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            height: todayLabel.height
        }
    }

    Column {
        //second column
        id: iconscol
        visible: hasdata
        anchors { top: dayscol.top; topMargin: units.gridUnit; bottom: parent.bottom }
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: dayscol.spacing

        PlasmaCore.IconItem {
            id: todayIcon
            source: determineIcon(m_todayCode)
            width: height
            height: todayLabel.height
            usesPlasmaTheme: true
        }

        PlasmaCore.IconItem {
            id: tomorrowIcon
            source: determineIcon(m_tomorrowCode)
            width: height
            height: todayLabel.height
            usesPlasmaTheme: true
        }

        PlasmaCore.IconItem {
            id: afterTIcon
            source: determineIcon(m_afterTCode)
            width: height
            height: todayLabel.height
            usesPlasmaTheme: true
        }

        PlasmaCore.IconItem {
            id: fourIcon
            source: determineIcon(m_4Code)
            width: height
            height: todayLabel.height
            usesPlasmaTheme: true
        }

        PlasmaCore.IconItem {
            id: fiveIcon
            source: determineIcon(m_5Code)
            width: height
            height: todayLabel.height
            usesPlasmaTheme: true
        }
    }

    Column {
        //third column
        id: tempcol
        visible: hasdata
        anchors { top: dayscol.top; topMargin: units.gridUnit; right: parent.right; bottom: parent.bottom }
        spacing: dayscol.spacing

        PlasmaComponents.Label {
            id: todayTemp
            text: m_todayLow + "~" + m_todayHigh + "°" + m_unitTemperature
            horizontalAlignment: Text.AlignRight
            height: todayLabel.height
        }

        PlasmaComponents.Label {
            text: m_tomorrowLow + "~" + m_tomorrowHigh + "°" + m_unitTemperature
            horizontalAlignment: Text.AlignRight
            height: todayLabel.height
        }

        PlasmaComponents.Label {
            text: m_afterTLow + "~" + m_afterTHigh + "°" + m_unitTemperature
            horizontalAlignment: Text.AlignRight
            height: todayLabel.height
        }

        PlasmaComponents.Label {
            text: m_4Low + "~" + m_4High + "°" + m_unitTemperature
            horizontalAlignment: Text.AlignRight
            height: todayLabel.height
        }

        PlasmaComponents.Label {
            text: m_5Low + "~" + m_5High + "°" + m_unitTemperature
            horizontalAlignment: Text.AlignRight
            height: todayLabel.height
        }
    }

    Rectangle {
        id: back
        visible: hasdata
        anchors { top: dayscol.top; bottom: dayscol.bottom; left: parent.left; right: parent.right; }
        color: theme.backgroundColor
        opacity: 0.2
    }

    Column {
        spacing: units.gridUnit
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }

        PlasmaCore.IconItem {
            visible: !(hasdata || m_isbusy)
            source: "dialog-error"
            width: units.gridUnit * 4
            height: units.gridUnit * 4
            usesPlasmaTheme: true
        }

        PlasmaComponents.Label {
            visible: !(hasdata || m_isbusy)
            text: errstring ? errstring : i18n("Unknown Error.")
            wrapMode: Text.WordWrap
        }

        PlasmaComponents.BusyIndicator {
            visible: m_isbusy
            running: m_isbusy
        }
    }
    
    property bool notify: false
    
    PlasmaCore.DataSource {
        id: notifications
        engine: "notifications"
    }
    
    Timer {
        id: iconUpdater
        interval: 1000
        running: m_isbusy
        repeat: m_isbusy
        onTriggered: {
            if(!hasdata) {
                plasmoid.icon = "weather-none-available"
                plasmoid.toolTipMainText = ""
                plasmoid.toolTipSubText = ""
            }
            else {
                notify = false
                plasmoid.icon = determineIcon(m_conditionCode)
                plasmoid.toolTipMainText = m_city + " " + m_conditionTemp + "°" + m_unitTemperature
                plasmoid.toolTipSubText = getDescription(m_conditionCode)
                if(notify) {
                    var service = notifications.serviceForSource("notification")
                    var op = service.operationDescription("createNotification")
                    op["appIcon"] = plasmoid.icon
                    op["summary"] = plasmoid.toolTipSubText
                    op["body"] = plasmoid.toolTipMainText
                    op["timeout"] = 6000
                    service.startOperationCall(op)
                }
            }
        }
    }

    Timer {
        id: timer
        interval: plasmoid.configuration.interval * 60000 //1m=60000ms
        running: !m_isbusy
        repeat: true
        onTriggered: action_reload()
    }
    
    function action_reload () {
        backend.query()
        iconUpdater.running = true
    }

    Connections {
        target: plasmoid.configuration
        onWoeidChanged: action_reload()
    }

    function determineIcon(code) {
        if (code <= 4) {
            notify = true
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
            notify = true
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
            notify = true
            return "weather-hail"
        }
        else if (code <= 40) {
            notify = true
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
            notify = true
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
                notify = true
                return i18n("Tornado")
            case 1:
                notify = true
                return i18n("Tropical Storm")
            case 2:
                notify = true
                return i18n("Hurricane")
            case 3:
                notify = true
                return i18n("Severe Thunderstorms")
            case 4:
                notify = true
                return i18n("Thunderstorms")
            case 5:
                return i18n("Mixed Rain and Snow")
            case 6:
                notify = true
                return i18n("Mixed Rain and Sleet")
            case 7:
                notify = true
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
                notify = true
                return i18n("Hail")
            case 18:
                notify = true
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
                notify = true
                return i18n("Mixed Rain and Hail")
            case 36:
                return i18n("Hot")
            case 37:
                notify = true
                return i18n("Isolated Thunderstorms")
            case 38://same with 39
            case 39:
                notify = true
                return i18n("Scattered Thunderstorms")
            case 40:
                return i18n("Scattered Showers")
            case 41://same with 43
            case 43:
                notify = true
                return i18n("Heavy Snow")
            case 42:
                return i18n("Scattered Snow Showers")
            case 44:
                return i18n("Partly Cloudy")
            case 45:
                notify = true
                return i18n("Thundershowers")
            case 46:
                return i18n("Snow Showers")
            case 47:
                notify = true
                return i18n("Isolated Thundershowers")
            default://code 3200
                return i18n("Not Available")
        }
    }

    Component.onCompleted: {
        plasmoid.setAction("reload", i18n("Refresh"), "view-refresh")
        action_reload()
    }
}
