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

    // Items that appear in tray 
    Row {
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }

        PlasmaComponents.Label {
            text: plasmoid.icon != "weather-none-available" ? main.m_conditionTemp + "°" 
                      : ""
        }

        PlasmaCore.IconItem {
            id: conditionIcon
            source: plasmoid.icon //main.m_conditionIcon
        }

        PlasmaComponents.Label {
            text: " " 
        }
    }


    Row {
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }

        PlasmaComponents.BusyIndicator {
            visible: main.m_isbusy
            running: main.m_isbusy
        }
    }

    Timer {
        id: iconUpdater
        interval: 1000
        running: main.m_isbusy
        repeat: main.m_isbusy
        onTriggered: {
            if(!main.hasdata) {
                plasmoid.icon = "weather-none-available"
                plasmoid.toolTipMainText = i18n("Click tray icon")
                plasmoid.toolTipSubText = i18n("for error details")
            }
            else {
                plasmoid.icon = main.m_conditionIcon
                plasmoid.toolTipMainText = main.m_city + " " + main.m_conditionTemp + "°" + main.m_unitTemperature
                plasmoid.toolTipSubText = main.m_conditionDesc
            }
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
        iconUpdater.running = true
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
            // on appearance, no need for query if if full 
            // representation has already queried.
            action_reload()
        }
    }

    MouseArea {
        anchors.fill: parent
        
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        
        hoverEnabled: true
        
        onClicked: {
            if (mouse.button == Qt.MiddleButton) {
                action_reload() 
            } else {
                plasmoid.expanded = !plasmoid.expanded
            }
        }
    }
}
