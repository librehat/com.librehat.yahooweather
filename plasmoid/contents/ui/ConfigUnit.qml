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

    property alias cfg_celsius: celsiusTemp.checked
    property alias cfg_fahrenheit: fahrenheitTemp.checked
    property alias cfg_ms: msWind.checked
    property alias cfg_kmh: kmhWind.checked

    ColumnLayout {
        GroupBox {
            title: i18n("Temperature Unit")
            flat: true

            ColumnLayout {
                ExclusiveGroup {
                    id: tempGroup
                }

                RadioButton {
                    id: celsiusTemp
                    text: i18n("Celsius")
                    exclusiveGroup: tempGroup
                }

                RadioButton {
                    id: fahrenheitTemp
                    text: i18n("Fahrenheit")
                    exclusiveGroup: tempGroup
                }
            }
        }

        GroupBox {
            title: i18n("Wind Unit")
            flat: true
            
            ColumnLayout {
                ExclusiveGroup {
                    id: windGroup
                }

                RadioButton {
                    id: msWind
                    text: i18n("m/s")
                    exclusiveGroup: windGroup
                }

                RadioButton {
                    id: kmhWind
                    text: i18n("Km/h")
                    exclusiveGroup: windGroup
                }
            }
        }
    }
}
