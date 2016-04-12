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
    property alias cfg_ms: msSpeed.checked
    property alias cfg_kmh: kmhSpeed.checked
    property alias cfg_mph: mphSpeed.checked
    property alias cfg_mi: miDistance.checked
    property alias cfg_km: kmDistance.checked
    property alias cfg_in: inPressure.checked
    property alias cfg_atm: atmPressure.checked
    property alias cfg_hpa: hpaPressure.checked

    ColumnLayout {
        GroupBox {
            title: i18n("Temperature Unit")
            flat: true

            ColumnLayout {
                ExclusiveGroup {
                    id: tempGroup
                }

                RadioButton {
                    id: fahrenheitTemp
                    text: i18n("Fahrenheit")
                    exclusiveGroup: tempGroup
                }

                RadioButton {
                    id: celsiusTemp
                    text: i18n("Celsius")
                    exclusiveGroup: tempGroup
                }
            }
        }

        GroupBox {
            title: i18n("Speed Unit")
            flat: true
            
            ColumnLayout {
                ExclusiveGroup {
                    id: speedGroup
                }

                RadioButton {
                    id: mphSpeed
                    text: i18n("Miles per hour")
                    exclusiveGroup: speedGroup
                }

                RadioButton {
                    id: msSpeed
                    text: i18n("Metre per second")
                    exclusiveGroup: speedGroup
                }

                RadioButton {
                    id: kmhSpeed
                    text: i18n("Kilometre per hour")
                    exclusiveGroup: speedGroup
                }
            }
        }
        
        GroupBox {
            title: i18n("Distance Unit")
            flat: true
            
            ColumnLayout {
                ExclusiveGroup {
                    id: distanceGroup
                }

                RadioButton {
                    id: miDistance
                    text: i18n("Mile")
                    exclusiveGroup: distanceGroup
                }

                RadioButton {
                    id: kmDistance
                    text: i18n("Kilometre")
                    exclusiveGroup: distanceGroup
                }
            }
        }
        
        GroupBox {
            title: i18n("Pressure Unit")
            flat: true

            ColumnLayout {
                ExclusiveGroup {
                    id: pressureGroup
                }

                RadioButton {
                    id: inPressure
                    text: i18n("Inch of mercury")
                    exclusiveGroup: pressureGroup
                }
                
                RadioButton {
                    id: atmPressure
                    text: i18n("Atmosphere")
                    exclusiveGroup: pressureGroup
                }
                
                RadioButton {
                    id: hpaPressure
                    text: i18n("Hectopascal")
                    exclusiveGroup: pressureGroup
                }
            }
        }
    }
}
