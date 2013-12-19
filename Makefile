all: check

.PHONY:all clean check
.SUFFIXES:

# Tested with gfortran-4.8
FC=mpif90
LD=$(FC)

# Compiler detection
ifeq ($(findstring gcc,$(shell $(FC) -v 2>&1)),gcc)
    COMPILER_TYPE=gnu
    FCFLAGS+=-fimplicit-none
    FCFLAGS+=-Wall -Wextra -Werror
    FCFLAGS+=-Iinclude -Jmod
else ifeq ($(findstring ifort,$(shell $(FC) -v 2>&1)),ifort)
    COMPILER_TYPE=intel
    FCFLAGS+=-g -traceback
    FCFLAGS+=-warn all -warn errors -check all
#    FCFLAGS+=-stand f03
    FCFLAGS+=-Iinclude -module mod
endif
VPATH+=mod

# Find pFunit files
FCFLAGS+=-I$(PFUNIT)/mod
VPATH+=$(PFUNIT)/mod

PFPARSE=$(PFUNIT)/bin/pFUnitParser.py

# Get source files
SRC=$(shell find src -name '*.f90' -type f)
TESTSRC=$(shell find src -name '*.pf' -type f)

# Get list of tests to run
TESTS=$(patsubst src/%.pf,test/%,$(TESTSRC))

# Run tests
check: $(TESTS)
	@for test in $^; do echo "\n$$test"; ./$$test; done

# Cleanup
clean:
	$(RM) -r bin test obj deps mod

# Compile source files
obj/%.o: src/%.f90
	@mkdir -p $(dir $@)
	@mkdir -p mod
	$(FC) $(FCFLAGS) -c -o $@ $<

# Process pFunit tests
obj/%.F90: src/%.pf
	@mkdir -p $(dir $@)
	$(PFPARSE) $< $@

# Compile tests
obj/%.o: obj/%.F90
	@mkdir -p $(dir $@)
	@mkdir -p mod
	$(FC) $(FCFLAGS) -c -o $@ $<

# Secondexpansion to calculate prerequisite modules
.SECONDEXPANSION:

# Link programs
bin/%: obj/%.o $$(OBJREQ_%.o)
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS)

# Link tests with driver
$(TESTS):$(PFUNIT)/include/driver.F90
test/%: obj/%.o $$(OBJREQ_obj/%.F90)
	@mkdir -p $(dir $@)
	$(FC) $(FCFLAGS) $(LDFLAGS) -L$(PFUNIT)/lib -DUSE_MPI -DSUITE=$*_suite -Wno-unused-parameter -o $@ $^ $(LDLIBS) -lpfunit

# Dependency generation
deps/%.d: %.f90
	@mkdir -p $(dir $@)
	./gendeps -o $@ $<
deps/%.d: %.F90
	@mkdir -p $(dir $@)
	./gendeps -o $@ $<

DEPS=$(patsubst %.f90,deps/%.d,$(SRC))
DEPS+=$(patsubst src/%.pf,deps/obj/%.d,$(TESTSRC))
-include $(DEPS)
