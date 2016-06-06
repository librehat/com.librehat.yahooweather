Yahoo! Weather Widget
====

A simple weather widget that makes use of beloved Yahoo! Weather data. Written in pure QML.

For `KDE SC4`, please checkout `kde4` branch.

Dependencies
=====

- Plasma 5 (Plasma Shell)
- Qt >= 5.4
- QML Models 2 (`qml-module-qtqml-models2` on Ubuntu)

### Extra Dependencies For CMake ###

Only needed if you use `cmake` to install this widget.

- CMake >= 2.8.12
- Extra CMake Modules (`extra-cmake-modules`)
- Plasma Framework Development Package (`plasma-framework-devel`)

Installation
=====

### CMake ###

If you need localisation (i18n/l10n) support, please use `cmake` to install this widget to your system-wide directory.

```bash
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=`kf5-config --prefix`
sudo make install
```

### Plasma PKG ###

This may be more convenient but localisation support is not possible via `plasmapkg2`. This widget will be installed into your home directory.

Replace the version number as needed.

```bash
./mkplasmoid.sh
plasmapkg2 -i ~/com.librehat.yahooweather-5.2.0.plasmoid
```

For upgrade, run `plasmapkg2 -u ~/com.librehat.yahooweather-5.2.0.plasmoid` instead.

License
=====

### Code ###

GNU GENERAL PUBLIC LICENSE Version 3

Copyright 2014-2016 Symeon Huang

For details, please check `LICENSE` file.

### Weather Icons (font based) ###

From project [weather-icons](https://github.com/erikflowers/weather-icons)

For license details, please check [SIL OFL 1.1](http://scripts.sil.org/OFL)
