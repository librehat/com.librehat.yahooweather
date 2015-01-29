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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: mainWindow
    property int minimumWidth: 250;
    property int minimumHeight: 250;
    clip: true

    property bool hasdata: false;
    property string errstring;//used to display error on widget
    property bool m_isbusy: false;

    //hold city properties
    property string m_woeid;//http://developer.yahoo.com/geo/geoplanet/guide/concepts.html
    property bool m_unitCelsius;//neglect bool fahrenheit
    property bool m_unitms;//speed unit m/s neglect bool km/h

    property string m_lastBuildDate;
    property string m_link;
    property int m_interval;//update interval (minute)
    property string m_city;
    property string m_region;
    property string m_country;
    property string m_unitTemperature;
    property string m_unitDistance;
    property string m_unitPressure;
    property string m_unitSpeed;
    property string m_windChill;
    property string m_windDirection;
    property string m_windSpeed;
    property string m_atmosphereHumidity;
    property string m_atmosphereVisibility;
    property string m_atmospherePressure;
    property string m_atmosphereRising;
    property string m_astronomySunrise;
    property string m_astronomySunset;

    //<item>/<geo:lat> and <geo:long>
    property string m_geoLat;
    property string m_geoLong;

    //<yweather:condition>
    property int m_conditionCode;
    property int m_conditionTemp;

    //<yweather:forecast>
    property string m_todayDay;
    property int m_todayLow;
    property int m_todayHigh;
    property int m_todayCode;
    property string m_tomorrowDay;
    property int m_tomorrowLow;
    property int m_tomorrowHigh;
    property int m_tomorrowCode;
    property string m_afterTDay;
    property int m_afterTLow;
    property int m_afterTHigh;
    property int m_afterTCode;
    property string m_4Day;//today is day 1
    property int m_4Low;
    property int m_4High;
    property int m_4Code;
    property string m_5Day;
    property int m_5Low;
    property int m_5High;
    property int m_5Code;

    //Yahoo.qml implements API
    Yahoo {
        id: yh
    }

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
        onLinkActivated: Qt.openUrlExternally(link);
    }

    Row {
        id: conditionRow
        visible: hasdata
        anchors { top: yahoo_n_date.bottom; left:parent.left; right: parent.right }
        spacing: 6

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

            MouseArea {
                anchors.fill: parent;
                hoverEnabled: true;
                onEntered: { conditionIcon.active = true; updateToolTip(m_conditionCode); }
                onExited: { conditionIcon.active = false; generalTooltip(); }
            }
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
        anchors { top: moredetails.bottom; topMargin: 6; left: parent.left; leftMargin:2; bottom: parent.bottom }
        spacing: 6

        PlasmaComponents.Label {
            id: todayLabel
            text: i18n("Today")
            font.weight: Font.DemiBold
            height: Math.max((dayscol.height - 24) / 5, paintedHeight, theme.defaultFont.mSize.height * 1.6)
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
        anchors { top: dayscol.top; topMargin: 6; bottom: parent.bottom }
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: dayscol.spacing

        PlasmaCore.IconItem {
            id: todayIcon
            source: determineIcon(m_todayCode)
            width: height
            height: todayLabel.height

            MouseArea {
                anchors.fill: parent;
                hoverEnabled: true;
                onEntered: { todayIcon.active = true; updateToolTip(m_todayCode); }
                onExited: { todayIcon.active = false; generalTooltip(); }
            }
        }

        PlasmaCore.IconItem {
            id: tomorrowIcon
            source: determineIcon(m_tomorrowCode)
            width: height
            height: todayLabel.height

            MouseArea {
                anchors.fill: parent;
                hoverEnabled: true;
                onEntered: { tomorrowIcon.active = true; updateToolTip(m_tomorrowCode); }
                onExited: { tomorrowIcon.active = false; generalTooltip(); }
            }
        }

        PlasmaCore.IconItem {
            id: afterTIcon
            source: determineIcon(m_afterTCode)
            width: height
            height: todayLabel.height

            MouseArea {
                anchors.fill: parent;
                hoverEnabled: true;
                onEntered: { afterTIcon.active = true; updateToolTip(m_afterTCode); }
                onExited: { afterTIcon.active = false; generalTooltip(); }
            }
        }

        PlasmaCore.IconItem {
            id: fourIcon
            source: determineIcon(m_4Code)
            width: height
            height: todayLabel.height

            MouseArea {
                anchors.fill: parent;
                hoverEnabled: true;
                onEntered: { fourIcon.active = true; updateToolTip(m_4Code); }
                onExited: { fourIcon.active = false; generalTooltip(); }
            }
        }

        PlasmaCore.IconItem {
            id: fiveIcon
            source: determineIcon(m_5Code)
            width: height
            height: todayLabel.height

            MouseArea {
                anchors.fill: parent;
                hoverEnabled: true;
                onEntered: { fiveIcon.active = true; updateToolTip(m_5Code); }
                onExited: { fiveIcon.active = false; generalTooltip(); }
            }
        }
    }

    Column {
        //third column
        id: tempcol
        visible: hasdata
        anchors { top: dayscol.top; topMargin: 6; right: parent.right; bottom: parent.bottom }
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
        anchors { top: dayscol.top; topMargin: 4; bottom: dayscol.bottom; bottomMargin: -2; left: parent.left; leftMargin: -2; right: parent.right; rightMargin: -2 }
        color: theme.backgroundColor
        opacity: 0.2
    }

    Row {
        id: warn_errRow
        spacing: 6
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }

        PlasmaCore.IconItem {
            visible: !(hasdata || m_isbusy)
            source: "error"
            width: 28
            height: 28
        }

        PlasmaComponents.Label {
            visible: !(hasdata || m_isbusy)
            text: errstring != "" ? errstring : i18n("Error 2. WOEID may be invalid.")
            wrapMode: Text.WordWrap
        }

        PlasmaComponents.BusyIndicator {
            visible: m_isbusy
            running: m_isbusy
        }
    }

    Timer {
        id: timer
        interval: m_interval * 60000 //1m=60000ms
        running: false
        repeat: true
        onTriggered: yh.query(m_woeid)
    }

    function determineIcon(code) {
        if (code <= 4) {
            return "weather-storm";
        }
        else if (code <= 6) {
            return "weather-snow-rain";
        }
        else if (code == 7 ) {
            return "weather-snow-scattered";
        }
        else if (code == 8 || code == 10) {
            return "weather-freezing-rain";
        }
        else if (code == 9) {
            return "weather-showers-scattered";
        }
        else if (code <= 12) {
            return "weather-showers";
        }
        else if (code <= 16) {
            return "weather-snow";
        }
        else if (code == 17) {
            return "weather-hail";
        }
        else if (code == 18) {//sleet
            return "weather-snow-scattered";
        }
        else if (code <= 22) {
            return "weather-mist";
        }
        else if (code <= 24) {//windy
            return "weather-clouds";
        }
        else if (code == 25) {//cold
            return "weather-freezing-rain";
        }
        else if (code == 26) {//cloudy
            return "weather-clouds";
        }
        else if (code <= 28) {
            return "weather-many-clouds";
        }
        else if (code == 29) {
            return "weather-few-clouds-night";
        }
        else if (code == 30) {
            return "weather-few-clouds";
        }
        else if (code == 31 || code == 33) {
            return "weather-clear-night";
        }
        else if (code == 32 || code == 34 || code ==36) {
            return "weather-clear";
        }
        else if (code == 35) {
            return "weather-hail";
        }
        else if (code <= 40) {
            return "weather-storm";
        }
        else if (code == 41 || code == 43) {
            return "weather-snow";
        }
        else if (code == 42 || code == 46) {
            return "weather-snow-rain";
        }
        else if (code == 44) {
            return "weather-few-clouds";
        }
        else if (code == 45 || code == 47) {
            return "weather-storm";
        }
        else {
            return "weather-none-available";
        }
    }

    function getDescription(conCode) {
        //according to http://developer.yahoo.com/weather/#codes
        switch (conCode) {
            case 0:
                return i18n("Tornado");
            case 1:
                return i18n("Tropical Storm");
            case 2:
                return i18n("Hurricane");
            case 3:
                return i18n("Severe Thunderstorms");
            case 4:
                return i18n("Thunderstorms");
            case 5:
                return i18n("Mixed Rain and Snow");
            case 6:
                return i18n("Mixed Rain and Sleet");
            case 7:
                return i18n("Mixed Snow and Sleet");
            case 8:
                return i18n("Freezing Drizzle");
            case 9:
                return i18n("Drizzle");
            case 10:
                return i18n("Freezing Rain");
            case 11://has same descr with 12
            case 12:
                return i18n("Showers");
            case 13:
                return i18n("Snow Flurries");
            case 14:
                return i18n("Light Snow Showers");
            case 15:
                return i18n("Blowing Snow");
            case 16:
                return i18n("Snow");
            case 17:
                return i18n("Hail");
            case 18:
                return i18n("Sleet");
            case 19:
                return i18n("Dust");
            case 20:
                return i18n("Foggy");
            case 21:
                return i18n("Haze");
            case 22:
                return i18n("Smoky");
            case 23:
                return i18n("Blustery");
            case 24:
                return i18n("Windy");
            case 25:
                return i18n("Cold");
            case 26:
                return i18n("Cloudy");
            case 27:
                return i18n("Mostly Cloudy (Night)");
            case 28:
                return i18n("Mostly Cloudy (Day)");
            case 29:
                return i18n("Partly Cloudy (Night)");
            case 30:
                return i18n("Partly Cloudy (Day)");
            case 31:
                return i18n("Clear (Night)");
            case 32:
                return i18n("Sunny");
            case 33:
                return i18n("Fair (Night)");
            case 34:
                return i18n("Fair (Day)");
            case 35:
                return i18n("Mixed Rain and Hail");
            case 36:
                return i18n("Hot");
            case 37:
                return i18n("Isolated Thunderstorms");
            case 38://same with 39
            case 39:
                return i18n("Scattered Thunderstorms");
            case 40:
                return i18n("Scattered Showers");
            case 41://same with 43
            case 43:
                return i18n("Heavy Snow");
            case 42:
                return i18n("Scattered Snow Showers");
            case 44:
                return i18n("Partly Cloudy");
            case 45:
                return i18n("Thundershowers");
            case 46:
                return i18n("Snow Showers");
            case 47:
                return i18n("Isolated Thundershowers");
            default://code 3200
                return i18n("Not Available");
        }
    }

    function configChanged() {
        timer.running = false;

        m_woeid = plasmoid.readConfig("woeid");
	m_interval = plasmoid.readConfig("interval");
        m_unitCelsius = plasmoid.readConfig("celsius");
        m_unitms = plasmoid.readConfig("ms");

        timer.running = true;
        yh.query(m_woeid);
    }

    function updateToolTip(ttcode) {
        var toolTip = new Object;
        toolTip["image"] = determineIcon(ttcode);
        toolTip["mainText"] = getDescription(ttcode);
        plasmoid.popupIconToolTip = toolTip;
    }

    function generalTooltip() {
        var toolTip = new Object;
        toolTip["image"] = "weather-clouds";
        toolTip["mainText"] = i18n("Yahoo! Weather Widget");
        plasmoid.popupIconToolTip = toolTip;
    }

    Component.onCompleted: {
        plasmoid.popupIcon = "weather-clouds";
        plasmoid.aspectRatioMode = IgnoreAspectRatio;
        plasmoid.addEventListener("configChanged", mainWindow.configChanged);
        generalTooltip();
    }
}
