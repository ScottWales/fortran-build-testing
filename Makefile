all: build
	cd build && cmake ..
	${MAKE} -C build

check: all
	cd build && ctest

build:
	mkdir -p $@
