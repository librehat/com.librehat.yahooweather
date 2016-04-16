CMAKE_MINIMUM_REQUIRED(VERSION 2.8.12)
SET(_moPrefix plasma_applet_)

FILE(GLOB_RECURSE MO_FILES RELATIVE ${CMAKE_CURRENT_LIST_DIR} "*.mo")

FOREACH(_mo ${MO_FILES})
    GET_FILENAME_COMPONENT(_langLocation ${_mo} DIRECTORY)
    GET_FILENAME_COMPONENT(_moFile ${_mo} NAME)
    
    SET(_relname ${_moPrefix}${_moFile})

    INSTALL(FILES ${_mo} DESTINATION ${LOCALE_INSTALL_DIR}/${_langLocation}/ RENAME ${_relname})

ENDFOREACH(_mo ${MO_FILES})
