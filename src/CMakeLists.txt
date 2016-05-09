set(modules mod_a.F90 mod_b.F90)

add_executable(prog_a prog_a.F90 ${modules})
add_executable(prog_b prog_b.F90 ${modules})

add_pfunit_sources(pfsources test_a.pf test_b.pf)
add_executable(runtests ${pfsources} ${modules})
add_test(runtests)
