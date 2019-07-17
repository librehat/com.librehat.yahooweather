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

    property alias cfg_locationEntry: locationEntry.checked
    property alias cfg_woeidEntry: woeidEntry.checked
    property alias cfg_woeid: woeidField.text
    property alias cfg_interval: intervalField.text
    property alias cfg_timeFormat24: timeFormat24Field.checked
    property alias cfg_useWxFonts: useWxFontsField.checked
    property bool locChecked: plasmoid.configuration.locationEntry
    property bool woeChecked: plasmoid.configuration.woeidEntry

    // Respond to click on "Location" radio button. Below "currently"
    // means immediately before the radio button is clicked.
    //
    function onLocClicked() {
        if (woeChecked && plasmoid.configuration.locationEntry) { 
            // woeid radio button is currently selected and entry mode is
            // still location (new woeid not yet saved). Restore
            // location string to the text box.
            woeidField.text = plasmoid.configuration.woeid
        } else if (woeChecked) {
            //  woeid radio button is currently selected and entry mode is
            //  woeid. Clear the text box string. 
            woeidField.text = "" 
        } else {
            // location radio button is currently selected. Don't change
            // the text box string. 
        }
        // save the checked state for use in the next call to onLocClicked() or
        // onWoeClicked().
        locChecked = true
        woeChecked = false  
    }

    // Respond to click on "WOEID" radio button. Below "currently"
    // means immediately before the radio button is clicked.
    //
    function onWoeClicked() {
        if (locChecked && plasmoid.configuration.woeidEntry) { 
            // location radio button is currently selected and entry mode is
            // still woeid (new location not yet saved). Restore
            // woeid string to the text box.
            woeidField.text = plasmoid.configuration.woeid
        } else if (locChecked) {
            //  location radio button is currently selected and entry mode is
            //  location. Clear the text box string. 
            woeidField.text = "" 
        } else {
            // woeid radio button is currently selected. Don't change the
            // text box string.
        }
        // save the checked state for use in the next call to onLocClicked() or
        // onWoeClicked().
        locChecked = false
        woeChecked = true
    }

    ColumnLayout {
        GroupBox {
            title: i18n("Select Location or WOEID entry.")
            flat: true
            
            ColumnLayout {
                ExclusiveGroup {
                    id: locationOrWoeidGroup
                }

                RadioButton {
                    id: locationEntry 
                    text: i18n("Enter Location below.")
                    exclusiveGroup: locationOrWoeidGroup
                    onClicked: onLocClicked() 
                }

                RadioButton {
                    id: woeidEntry 
                    text: i18n("Enter WOEID below.")
                    exclusiveGroup: locationOrWoeidGroup
                    onClicked: onWoeClicked() 
                }
            }
        }
        RowLayout {
            Label {
                // Set text field label to match active radio button selection.
                text: woeChecked ? i18n("WOEID") : i18n("Location")
            }
            TextField {
                id: woeidField
            }
        }
        Label {
            text: i18n("If location entry selected above, enter location text such") +
                    "<br\>" +
                  i18n("as London,UK or a zipcode. If WOEID entry selected, please") +
                    "<br\>" +
                  i18n("visit <a href=\"http://zourbuth.com/tools/woeid/\">Yahoo! WOEID Lookup</a> to find your city's WOEID (Where On Earth") +
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
            text: i18n("Show Time in 24-hour Format.") 
        }

        CheckBox {
            id: useWxFontsField 
            text: i18n("Use webfont icons instead of KDE theme weather icons.") +
                  "<br\>" + 
                  i18n("Note: When residing in panel webfont icons are always used.")
        }
    }
}
