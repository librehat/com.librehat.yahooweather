Yahoo! Weather Widget
====

A simple weather widget that makes use of beloved Yahoo! Weather data. Written in pure QML.

For `KDE SC4`, please checkout `kde4` branch.

Dependency
=====

- Plasma 5 (Plasma Shell)
- Qt >= 5.4
- QML Models 2 (`qml-module-qtqml-models2` on Ubuntu)

Installation
=====

Replace the version number as needed.

```
./mkplasmoid.sh
plasmapkg2 -i ~/com.librehat.yahooweather-5.0.0.plasmoid
```

For upgrade, run `plasmapkg2 -u ~/com.librehat.yahooweather-5.0.0.plasmoid` instead.

License
=====

GNU GENERAL PUBLIC LICENSE Version 3

Copyright 2014-2015 Symeon Huang

For details, please check `LICENSE` file.
