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
import QtGraphicalEffects 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/icons.js" as FontSymbolTools

Item {
    id: inPanelItems

    anchors.fill: parent
    property double fontPixelSize: parent.height * 0.7
    property string fontSymbolStr: FontSymbolTools.getFontCode(backend.m_conditionIcon)

    // Weather condition icon (actually, a font symbol) in panel 
    PlasmaComponents.Label {
        visible: backend.hasdata || backend.networkError  || !backend.m_isbusy

        width: parent.width
        height: parent.height
        
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        horizontalAlignment: Text.AlignLeft 
        verticalAlignment: Text.AlignVCenter
        fontSizeMode: Text.Fit
        
        font.family: 'weathericons'
        text: fontSymbolStr
        
        opacity: 0.8 
        
        font.pixelSize: fontPixelSize
        font.weight: Font.Black
        font.pointSize: -1
    }

    // Temperature value in panel (over left center of condition icon)
    PlasmaComponents.Label {
        id: temperatureText
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }

        width: parent.width
        height: parent.height

        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignBottom

        visible: backend.hasdata || backend.networkError  || !backend.m_isbusy

        text: backend.m_conditionIcon != "weather-none-available" ? backend.m_conditionTemp + "°" 
                  : ""

        font.pixelSize: fontPixelSize * 0.5 
        font.pointSize: -1
    }

    // Busy indicator in panel 
    PlasmaComponents.BusyIndicator {
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        width: parent.width
        height: parent.height
        visible: backend.m_isbusy
        running: backend.m_isbusy
    }

    // Improve temperature text readability over icon/background
    DropShadow {
        anchors.fill: temperatureText
        radius: 3
        samples: 16
        spread: 0.9
        fast: true
        color: theme.backgroundColor
        source: temperatureText
        visible: true
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
