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
    property alias cfg_location: locationField.text
    property alias cfg_interval: intervalField.text
    property alias cfg_timeFormat24: timeFormat24Field.checked
    property alias cfg_useWxFonts: useWxFontsField.checked

    ColumnLayout {
        RowLayout {
            Label {
                text: i18n("Location")
            }
            TextField {
                id: locationField
            }
        }
        Label {
            text: i18n("Enter location string such as \"London UK\" or a zipcode.") +
                    "<br\>" +
                  i18n("Leave Location blank if WOEID usage preferred.")
        }
        RowLayout {
            Label {
                text: i18n("WOEID")
            }
            TextField {
                id: woeidField
            }
        }
        Label {
            text: i18n("Visit <a href=\"http://zourbuth.com/tools/woeid/\">Yahoo! WOEID Lookup</a> to find your city's WOEID (Where On Earth") +
                    "<br\>" +
                  i18n("IDentifier) or search the web for other WOEID lookup sites if necessary.")
            onLinkActivated: Qt.openUrlExternally(link)
        }

        RowLayout {
            Label {
                text: i18n("Update Interval")
            }
            TextField {
                id: intervalField
                inputMask: "99"
                inputMethodHints: Qt.ImhDigitsOnly
            }
        }

        CheckBox {
            id: timeFormat24Field 
            text: i18n("Show Time in 24-hour Format") 
        }

        CheckBox {
            id: useWxFontsField 
            text: i18n("Use webfont icons instead of KDE theme weather icons.") +
                  "<br\>" + 
                  i18n("Note: When residing in panel webfont icons are always used.")
        }
    }
}
