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
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "configure"
        source: "ConfigGeneral.qml"
    }

    ConfigCategory {
        name: i18n("Unit")
        icon: "format-text-symbol"
        source: "ConfigUnit.qml"
    }
}
