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

    //UI block
    PlasmaComponents.Label {
        //top-left
        id: cityname
        visible: main.hasdata
        anchors { top: parent.top; left: parent.left }
        text: "<strong>" + main.m_city + "</strong><br />" + (main.m_region ? main.m_region + ", " : "") + main.m_country
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
        visible: main.hasdata
        anchors { top: parent.top; right: refresh_button.left; rightMargin: units.gridUnit }
        text: main.m_pubDate + "<br /><a href='" + main.m_link + "'>" + i18n("YAHOO! Weather") + "</a>"
        horizontalAlignment: Text.AlignRight
        font: theme.smallestFont
        onLinkActivated: Qt.openUrlExternally(link)
    }

    Row {
        id: conditionRow
        visible: main.hasdata
        anchors.top: yahoo_n_date.bottom
        width: parent.width
        height: width / 3

        Column {
            id: conditionCol
            width: parent.width / 2
            height: parent.height
            
            PlasmaComponents.Label {
                id: conditiontemp
                text: main.m_conditionTemp + "°" + main.m_unitTemperature
                height: parent.height - descLabel.implicitHeight
                width: parent.width
                minimumPointSize: theme.smallestFont.pointSize
                font.pointSize: theme.defaultFont.pointSize * 10
                font.weight: Font.Bold
                fontSizeMode: Text.Fit
            }

            PlasmaComponents.Label {
                id: descLabel
                text: main.m_conditionDesc + "<br />" + i18n("Feels like") + ": " + main.m_windChill + "°" + main.m_unitTemperature
            }
        }

        PlasmaCore.IconItem {
            id: conditionIcon
            source: main.m_conditionIcon
            height: Math.min(conditionCol.height, 256)
            width: height
            anchors.verticalCenter: conditionCol.verticalCenter
        }
    }

    Row {
        id: moredetails
        visible: main.hasdata
        anchors { top: conditionRow.bottom; horizontalCenter: parent.horizontalCenter }
        spacing: Math.max(6, (parent.width - firstDetail.width - secondDetail.width - thirdDetail.width) / 2)

        PlasmaComponents.Label {
            id: firstDetail
            text: i18n("Sunrise") + ": " + main.m_astronomySunrise + "<br />" + i18n("Sunset") + ": " + main.m_astronomySunset
            font: theme.defaultFont
        }

        PlasmaComponents.Label {
            id: secondDetail
            text: i18n("Humidity") + ": " + main.m_atmosphereHumidity + "%<br />" + i18n("Pressure") + ": " + main.m_atmosphereRising + main.m_atmospherePressure + ' ' + main.m_unitPressure
            font: theme.defaultFont
        }

        PlasmaComponents.Label {
            id: thirdDetail
            text: i18n("Visibility") + ": " + (main.m_atmosphereVisibility ? main.m_atmosphereVisibility + ' ' + main.m_unitDistance : i18n("NULL")) + "<br />" + i18n("Wind") + ": " + main.m_windDirection + main.m_windSpeed + ' ' + main.m_unitSpeed
            font: theme.defaultFont
        }
    }
    
    ListView {
        id: forecastView
        visible: main.hasdata
        anchors { top: moredetails.bottom; topMargin: units.gridUnit; left: parent.left; right: parent.right; bottom: parent.bottom }
        orientation: ListView.Horizontal
        model: main.dataModel
        delegate: ForecastDelegate {
            height: forecastView.height
            width: forecastView.width / 5
        }
    }

    Row {
        spacing: units.gridUnit
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }

        PlasmaCore.IconItem {
            visible: !(main.hasdata || main.m_isbusy)
            source: "dialog-error"
            width: theme.mediumIconSize
            height: width
        }

        PlasmaComponents.Label {
            visible: !(main.hasdata || main.m_isbusy)
            text: main.errstring ? main.errstring : i18n("Unknown Error.")
            wrapMode: Text.WordWrap
        }

        PlasmaComponents.BusyIndicator {
            visible: main.m_isbusy
            running: main.m_isbusy
        }
    }

    Timer {
        id: timer
        interval: plasmoid.configuration.interval * 60000 //1m=60000ms
        running: !main.m_isbusy
        repeat: true
        onTriggered: action_reload()
    }
    
    function action_reload () {
        main.query()
    }
    
    Connections {
        target: plasmoid.configuration
        onWoeidChanged: action_reload()

        //this signal is emitted when any unit checkbox changes
        //binding multiple unit changed signals will cause a segfault
        onMbrChanged: main.reparse()
    }

    Component.onCompleted: {
        if (!main.queried) {
            // on appearance, no need for query if if compact
            // representation has already queried.
            action_reload()
        }
    }
}
