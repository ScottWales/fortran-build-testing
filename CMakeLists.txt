cmake_minimum_required(VERSION 3.4)
enable_language(Fortran)

project(fortran-build-testing)
include(CTest)
include($ENV{PFUNIT}/include/PreprocessMacro.cmake)

set(CMAKE_Fortran_COMPILER mpif90)
list(APPEND CMAKE_Fortran_FLAGS -qopenmp)

add_subdirectory(src)
