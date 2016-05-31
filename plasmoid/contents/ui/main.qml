/*
*   Author: Symeon Huang (librehat) <hzwhuang@gmail.com>
*   Copyright 2014-2016
*
*   This program is free software; you can redistribute it and/or modify
*   it under the terms of the GNU Library General Public License as
*   published by the Free Software Foundation; either version 3 or
*   (at your option) any later version.
*/

import QtQuick 2.2
import org.kde.plasma.plasmoid 2.0

Item {

    FontLoader {
        source: '../fonts/weathericons-regular-webfont-2.0.10.ttf'
    }

    //Yahoo.qml implements the API and stores relevant data
    Yahoo {
        id: backend
    }

    Plasmoid.switchWidth: units.gridUnit * 12
    Plasmoid.switchHeight: units.gridUnit * 12

    Plasmoid.fullRepresentation: Weather { }
    Plasmoid.compactRepresentation: CompactWx { }
}
