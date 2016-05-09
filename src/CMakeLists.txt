add_library(foolib mod_a.f90 mod_b.f90)

add_executable(prog_a prog_a.f90)
target_link_libraries(prog_a foolib)

add_executable(prog_b prog_b.f90)
target_link_libraries(prog_b foolib)

add_pfunit_sources(pfsources test_a.pfunit test_b.pfunit)
add_executable(runtests ${pfsources} $ENV{PFUNIT}/include/driver.F90)
target_link_libraries(runtests pfunit foolib)
target_include_directories(runtests PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_compile_definitions(runtests PUBLIC USE_MPI)
add_test(NAME pfunit COMMAND mpirun -np 4 $<TARGET_FILE:runtests>)
