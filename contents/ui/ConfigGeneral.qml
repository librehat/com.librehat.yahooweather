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
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

Item {
    id: generalPage
    width: childrenRect.width
    height: childrenRect.height

    property alias cfg_woeid: woeidField.text
    property alias cfg_interval: intervalField.text

    ColumnLayout {
        ColumnLayout {
            Label {
                text: i18n("WOEID")
            }

            TextField {
                id: woeidField
            }

            Label {
                text: i18n("Visit <a href=\"http://zourbuth.com/tools/woeid/\">Yahoo! WOEID Lookup</a> to find your city's WOEID")
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }

        ColumnLayout {
            Label {
                text: i18n("Update Interval")
            }

            TextField {
                id: intervalField
                inputMask: "999"
                inputMethodHints: Qt.ImhDigitsOnly
            }
        }
    }
}
