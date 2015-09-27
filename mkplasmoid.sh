#!/bin/sh

cd plasmoid
ver=`grep "X-KDE-PluginInfo-Version" metadata.desktop | sed 's/.*=//'`
app=`grep "X-KDE-PluginInfo-Name" metadata.desktop | sed 's/.*=//'`
zip ~/$app-$ver.plasmoid -r contents
zip ~/$app-$ver.plasmoid metadata.desktop
cd ..
zip ~/$app-$ver.plasmoid LICENSE README.md
