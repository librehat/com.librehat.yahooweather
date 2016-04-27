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
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    Layout.minimumWidth: units.gridUnit * 18
    Layout.minimumHeight: units.gridUnit * 20
    clip: true

    //Yahoo.qml implements the API and stores relevant data
    Yahoo {
        id: backend
    }

    property alias hasdata: backend.hasdata
    property alias errstring: backend.errstring
    property alias m_isbusy: backend.m_isbusy

    //UI block
    PlasmaComponents.Label {
        //top-left
        id: cityname
        visible: hasdata
        anchors { top: parent.top; left: parent.left }
        text: "<strong>" + backend.m_city + "</strong><br />" + (backend.m_region ? backend.m_region + ", " : "") + backend.m_country
    }

    PlasmaComponents.Button {
        id: refresh_button
        anchors { top: parent.top; right: parent.right }
        iconSource: "view-refresh"
        tooltip: i18n("Refresh")
        onClicked: action_reload()
    }

    PlasmaComponents.Label {
        //top-right
        id: yahoo_n_date
        visible: hasdata
        anchors { top: parent.top; right: refresh_button.left; rightMargin: units.gridUnit }
        text: backend.m_pubDate + "<br /><a href='" + backend.m_link + "'>" + i18n("YAHOO! Weather") + "</a>"
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
                text: backend.m_conditionTemp + "°" + backend.m_unitTemperature
                height: parent.height - descLabel.implicitHeight
                width: parent.width
                minimumPointSize: theme.smallestFont.pointSize
                font.pointSize: theme.defaultFont.pointSize * 10
                font.weight: Font.Bold
                fontSizeMode: Text.Fit
            }

            PlasmaComponents.Label {
                id: descLabel
                text: backend.m_conditionDesc + "<br />" + i18n("Feels like") + ": " + backend.m_windChill + "°" + backend.m_unitTemperature
            }
        }

        PlasmaCore.IconItem {
            id: conditionIcon
            source: backend.m_conditionIcon
            height: Math.min(conditionCol.height, 256)
            width: height
            anchors.verticalCenter: conditionCol.verticalCenter
        }
    }

    Row {
        id: moredetails
        visible: hasdata
        anchors { top: conditionRow.bottom; horizontalCenter: parent.horizontalCenter }
        spacing: Math.max(6, (parent.width - firstDetail.width - secondDetail.width - thirdDetail.width) / 2)

        PlasmaComponents.Label {
            id: firstDetail
            text: i18n("Sunrise") + ": " + backend.m_astronomySunrise + "<br />" + i18n("Sunset") + ": " + backend.m_astronomySunset
            font: theme.defaultFont
        }

        PlasmaComponents.Label {
            id: secondDetail
            text: i18n("Humidity") + ": " + backend.m_atmosphereHumidity + "%<br />" + i18n("Pressure") + ": " + backend.m_atmosphereRising + backend.m_atmospherePressure + ' ' + backend.m_unitPressure
            font: theme.defaultFont
        }

        PlasmaComponents.Label {
            id: thirdDetail
            text: i18n("Visibility") + ": " + (backend.m_atmosphereVisibility ? backend.m_atmosphereVisibility + ' ' + backend.m_unitDistance : i18n("NULL")) + "<br />" + i18n("Wind") + ": " + backend.m_windDirection + backend.m_windSpeed + ' ' + backend.m_unitSpeed
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
        }
    }

    Row {
        spacing: units.gridUnit
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }

        PlasmaCore.IconItem {
            visible: (!(hasdata || m_isbusy)) || backend.networkError
            source: "dialog-error"
            width: theme.mediumIconSize
            height: width
        }

        PlasmaComponents.Label {
            visible: (!(hasdata || m_isbusy)) || backend.networkError
            text: errstring ? errstring : i18n("Unknown Error.")
            wrapMode: Text.WordWrap
        }
    }

    Row {
        spacing: units.gridUnit
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }

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
                plasmoid.toolTipMainText = backend.m_city + " " + backend.m_conditionTemp + "°" + backend.m_unitTemperature
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

        //this signal is emitted when any unit checkbox changes
        //binding multiple unit changed signals will cause a segfault
        onMbrChanged: backend.reparse()
    }

    Component.onCompleted: {
        action_reload()
    }
}
