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

    // Items that appear in tray except busy indicator
    Row {
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        visible: backend.hasdata || backend.networkError  || !backend.m_isbusy

        PlasmaComponents.Label {
            text: plasmoid.icon != "weather-none-available" ? backend.m_conditionTemp + "°" 
                      : ""
        }

        PlasmaCore.IconItem {
            source: plasmoid.icon 
        }
    }

    // Busy indicator in tray
    Row {
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }

        PlasmaComponents.BusyIndicator {
            visible: backend.m_isbusy
            running: backend.m_isbusy
        }
    }

    Timer {
        id: timer
        interval: plasmoid.configuration.interval * 60000 //1m=60000ms
        running: !backend.m_isbusy
        repeat: true
        onTriggered: action_reload()
    }
    
    function action_reload () {
        backend.query()
    }
    
    Connections {
        target: plasmoid.configuration
        onWoeidChanged: action_reload()

        //this signal is emitted when any unit checkbox changes
        //binding multiple unit changed signals will cause a segfault
        onMbrChanged: backend.reparse()
    }

    Component.onCompleted: {
        if (!backend.haveQueried) {
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
