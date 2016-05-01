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
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: delegate
    
    PlasmaComponents.Label {
        text: day
        id: dayId
        anchors.horizontalCenter: parent.horizontalCenter
        font: theme.defaultFont
    }
    
    PlasmaCore.IconItem {
        source: icon
        id: iconId
        width: theme.smallMediumIconSize
        height: width
        anchors {horizontalCenter: parent.horizontalCenter;
                 top: dayId.bottom; topMargin: units.gridUnit}
    }
    
    PlasmaComponents.Label {
        text: tempHi
        id: tempHiId
        anchors {horizontalCenter: parent.horizontalCenter; 
                 top: iconId.bottom; topMargin: units.gridUnit}
        font: theme.defaultFont
    }

    PlasmaComponents.Label {
        text: tempLo
        anchors {horizontalCenter: parent.horizontalCenter; 
                 top: tempHiId.bottom; topMargin: -units.gridUnit/2}
        font: theme.defaultFont
    }
}
