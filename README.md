Yahoo! Weather Widget
====

This widget is still under development to port to Plasma 5 properly.

For `KDE SC4`, please checkout `kde4` branch.

Dependency
=====

- `plasma5` (Plasma Shell)
- `qt5-xmllistmodel` (`qml-module-qtquick-xmllistmodel` in Ubuntu)

Installation
=====

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
