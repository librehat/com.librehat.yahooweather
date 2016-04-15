#!/bin/sh
#
# Based on extract-and-merge-messages.sh of https://github.com/Musikolo/plasma5-applets-system-panel

PROJECT="com.librehat.yahooweather"   # project name
WDIR=`pwd`                            # working dir
BASEDIR="$WDIR/.."                    # root of translatable sources


echo "Preparing rc files"
cd "${BASEDIR}"
# we use simple sorting to make sure the lines do not jump around too much from system to system
find . -name '*.rc' -o -name '*.ui' -o -name '*.kcfg' -o -name '*.js'| sort > ${WDIR}/rcfiles.list
# additional string for KAboutData
echo 'i18nc("NAME OF TRANSLATORS","Your names");' >> ${WDIR}/rc.cpp
echo 'i18nc("EMAIL OF TRANSLATORS","Your emails");' >> ${WDIR}/rc.cpp
echo 'i18nc("HOMEPAGE OF TRANSLATORS","Your homepages");' >> ${WDIR}/rc.cpp
echo "Done preparing rc files"


echo "Extracting messages"
cd ${BASEDIR}
# see above on sorting
find . -name '*.cpp' -o -name '*.qml'| sort > ${WDIR}/infiles.list
echo "rc.cpp" >> ${WDIR}/infiles.list
cd ${WDIR}
xgettext --from-code=UTF-8 -C -kde -ci18n -ki18n:1 -ki18nc:1c,2 -ki18np:1,2 -ki18ncp:1c,2,3 -ktr2i18n:1 \
         -kI18N_NOOP:1 -kI18N_NOOP2:1c,2 -kN_:1 -kaliasLocale -kki18n:1 -kki18nc:1c,2 -kki18np:1,2 -kki18ncp:1c,2,3 \
         --files-from=infiles.list -D ${BASEDIR} -D ${WDIR} -o ${PROJECT}.pot || { echo "error while calling xgettext. aborting."; exit 1; }
echo "Done extracting messages"


echo "Merging translations"
catalogs=`find . -name '*.po'`
for cat in $catalogs; do
  echo $cat
  msgmerge -o $cat.new $cat ${PROJECT}.pot
  mv $cat.new $cat
done
echo "Done merging translations"


echo "Cleaning up"
cd "${WDIR}"
rm rcfiles.list
rm infiles.list
rm rc.cpp
echo "Done"
