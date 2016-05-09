cmake_minimum_required(version 2.0)
enable_language(Fortran)

project(fortran-build-testing)
include(CTest)
include($ENV{PFUNIT}/PreprocessMacro.cmake)
add_subdirectory(src)
