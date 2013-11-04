all: check

LD=$(FC)
FCFLAGS+=-I$(PFUNIT)/mod

PFPARSE=$(PFUNIT)/bin/pFUnitParser.py

# Get source files
SRC=$(shell find src -name '*.f90' -type f)
TESTSRC=$(shell find src -name '*.pf' -type f)

# Get list of tests to run
TESTS=$(patsubst src/%.pf,test/%,$(TESTSRC))

# Run tests
check: $(TESTS)
	@for test in $^; do echo $$test; ./$$test; done

# Cleanup
clean:
	$(RM) -r bin test obj

# Compile source files
obj/%.o: src/%.f90
	@mkdir -p $(dir $@)
	$(FC) $(FCFLAGS) -c -o $@ $<

# Process pFunit tests
obj/%.F90: src/%.pf
	@mkdir -p $(dir $@)
	$(PFPARSE) $< $@

# Compile tests
obj/%.o: obj/%.F90
	@mkdir -p $(dir $@)
	$(FC) $(FCFLAGS) -c -o $@ $<

# Link programs
bin/%: obj/%.o
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS)

# Link tests with driver
$(TESTS):$(PFUNIT)/include/driver.F90
test/%: obj/%.o
	@mkdir -p $(dir $@)
	echo "ADD_TEST_SUITE($*_suite)" > obj/testSuites.inc
	$(FC) $(FCFLAGS) $(LDFLAGS) -L$(PFUNIT)/lib -Iobj -o $@ $^ $(LDLIBS) -lpfunit
	rm obj/testSuites.inc

