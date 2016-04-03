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
//import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Column {
    id: delegate
    spacing: units.gridUnit
    
    PlasmaComponents.Label {
        text: day
        anchors.horizontalCenter: parent.horizontalCenter
        font: theme.defaultFont
    }
    
    PlasmaCore.IconItem {
        source: icon
        width: theme.smallMediumIconSize
        height: width
        usesPlasmaTheme: true
        anchors.horizontalCenter: parent.horizontalCenter
    }
    
    PlasmaComponents.Label {
        text: temp
        anchors.horizontalCenter: parent.horizontalCenter
        font: theme.defaultFont
    }
}
