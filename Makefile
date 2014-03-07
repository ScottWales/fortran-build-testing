# Makefile for Fortran automatic dependency generation
# ====================================================
#
# Author: Scott Wales
# 
# Copyright 2014 ARC Centre of Excellence for Climate Systems Science
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

all: check

.PHONY:all clean check
.SUFFIXES:

# Tested with gfortran-4.8 and ifort
FC=mpif90
LD=$(FC)

# Compiler detection
ifeq ($(findstring gcc,$(shell $(FC) -v 2>&1)),gcc)
    COMPILER_TYPE=gnu

    FCFLAGS+=-fimplicit-none
    FCFLAGS+=-g -fbacktrace
    FCFLAGS+=-Wall -Wextra -Werror
    FCFLAGS+=-Iinclude -Jmod
    FCFLAGS+=-fopenmp

    LDFLAGS+=-fopenmp

    TESTFCFLAGS+=-Wno-unused
    TESTFCFLAGS+=-Wno-uninitialized
    TESTFCFLAGS+=-Wno-unused-parameter

else ifeq ($(findstring ifort,$(shell $(FC) -v 2>&1)),ifort)
    COMPILER_TYPE=intel

    FCFLAGS+=-g -traceback
    FCFLAGS+=-warn all -warn errors -check all
    FCFLAGS+=-Iinclude -module mod
    FCFLAGS+=-openmp

    LDFLAGS+=-openmp

    TESTFCFLAGS+=-Wno-unused-parameter

endif

# .mod files are stored in this directory
VPATH   += mod

# Find pFunit files
FCFLAGS += -I$(PFUNIT)/mod
VPATH   += $(PFUNIT)/mod
PFPARSE =  $(PFUNIT)/bin/pFUnitParser.py

# Get source files
SRC     := $(shell find src -name '*.f90' -type f)
TESTSRC := $(shell find src -name '*.pf' -type f)

# Get list of tests to run
TESTS   = $(patsubst src/%.pf,test/%,$(TESTSRC))

# Run all tests
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
test/%: obj/%.o $$(OBJREQ_obj/%.o)
	@mkdir -p $(dir $@)
	$(FC) $(FCFLAGS) $(TESTFCFLAGS) $(LDFLAGS) -L$(PFUNIT)/lib -DUSE_MPI -DSUITE=$(notdir $*)_suite -o $@ $^ $(LDLIBS) -lpfunit

# Dependency generation
deps/%.d: %.f90
	@mkdir -p $(dir $@)
	./gendeps -o $@ $<
deps/%.d: %.F90
	@mkdir -p $(dir $@)
	./gendeps -o $@ $<

DEPS += $(patsubst %.f90,deps/%.d,$(SRC))
DEPS += $(patsubst src/%.pf,deps/obj/%.d,$(TESTSRC))
-include $(DEPS)

# Compile programs found by the dependency generation
all: $(PROGRAMS)
