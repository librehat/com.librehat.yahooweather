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
import QtQuick.Controls 1.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    Layout.minimumWidth: units.gridUnit * 18
    Layout.minimumHeight: units.gridUnit * 18
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

    property alias m_conditionTemp: backend.m_conditionTemp

    //UI block
    PlasmaComponents.Label {
        //top-left
        id: cityname
        visible: hasdata
        anchors { top: parent.top; left: parent.left }
        text: "<strong>" + m_city + "</strong><br />" + (m_region ? m_region + ", " + m_country : m_country)
    }

    PlasmaComponents.Label {
        //top-right
        id: yahoo_n_date
        visible: hasdata
        anchors { top: parent.top; right: parent.right }
        text: m_lastBuildDate + "<br /><a href='" + m_link + "'>" + i18n("YAHOO! Weather") + "</a>"
        horizontalAlignment: Text.AlignRight
        font: theme.smallestFont
        onLinkActivated: Qt.openUrlExternally(link)
    }

    Row {
        id: conditionRow
        visible: hasdata
        anchors.top: yahoo_n_date.bottom
        width: parent.width
        height: width / 3

        Column {
            id: conditionCol
            width: parent.width / 2
            height: parent.height
            
            PlasmaComponents.Label {
                id: conditiontemp
                text: m_conditionTemp + "°" + m_unitTemperature
                height: parent.height - descLabel.implicitHeight
                width: parent.width
                minimumPointSize: theme.smallestFont.pointSize
                font.pointSize: theme.defaultFont.pointSize * 10
                font.weight: Font.Bold
                fontSizeMode: Text.Fit
            }

            PlasmaComponents.Label {
                id: descLabel
                text: backend.m_conditionDesc + "<br />" + i18n("Sunrise") + ": " + m_astronomySunrise + "<br />" + i18n("Sunset") + ": " + m_astronomySunset
            }
        }

        PlasmaCore.IconItem {
            id: conditionIcon
            source: backend.m_conditionIcon
            height: Math.min(conditionCol.height, 256)
            width: height
            anchors.verticalCenter: conditionCol.verticalCenter
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
            font: theme.defaultFont
        }

        PlasmaComponents.Label {
            id: secondDetail
            text: i18n("Humidity") + ": " + m_atmosphereHumidity + "%<br />" + i18n("Pressure") + ": " + m_atmospherePressure + m_unitPressure
            font: theme.defaultFont
        }

        PlasmaComponents.Label {
            id: thirdDetail
            text: i18n("UV Index") + ": " + m_atmosphereRising + "<br />" + i18n("Wind") + ": " + m_windSpeed + m_unitSpeed
            font: theme.defaultFont
        }
    }
    
    ListView {
        id: forecastView
        visible: hasdata
        anchors { top: moredetails.bottom; topMargin: units.gridUnit; left: parent.left; right: parent.right; bottom: parent.bottom }
        orientation: ListView.Horizontal
        model: backend.dataModel
        delegate: ForecastDelegate {
            height: forecastView.height
            width: forecastView.width / 5
            unit: m_unitTemperature
        }
    }

    Row {
        spacing: units.gridUnit
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }

        PlasmaCore.IconItem {
            visible: !(hasdata || m_isbusy)
            source: "dialog-error"
            width: theme.mediumIconSize
            height: width
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
                plasmoid.icon = backend.m_conditionIcon
                plasmoid.toolTipMainText = m_city + " " + m_conditionTemp + "°" + m_unitTemperature
                plasmoid.toolTipSubText = backend.m_conditionDesc
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

    Component.onCompleted: {
        plasmoid.setAction("reload", i18n("Refresh"), "view-refresh")
        action_reload()
    }
}
