cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
project(lightdm_interop VERSION 1.0.0 LANGUAGES C)
add_library(lightdm_interop SHARED interop.c)
target_link_libraries(
    lightdm_interop 
    PUBLIC 
    PkgConfig::liblightdm
    m
    )
find_package(PkgConfig REQUIRED)
pkg_check_modules(liblightdm REQUIRED IMPORTED_TARGET liblightdm-gobject-1)
set_target_properties(lightdm_interop PROPERTIES
    PUBLIC_HEADER interop.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "lightdm_interop"
)
