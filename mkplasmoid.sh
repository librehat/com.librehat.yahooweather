#!/bin/sh

ver=`grep "X-KDE-PluginInfo-Version" metadata.desktop | sed 's/.*=//'`
app=`grep "X-KDE-PluginInfo-Name" metadata.desktop | sed 's/.*=//'`
zip ~/$app-$ver.plasmoid -r contents
zip ~/$app-$ver.plasmoid metadata.desktop LICENSE README.md
