ifeq (, $(shell which llvm-config))
$(error "No llvm-config in $$PATH")
endif

LLVMVER  = $(shell llvm-config --version 2>/dev/null | sed 's/git//' | sed 's/svn//' )
LLVM_MAJOR = $(shell llvm-config --version 2>/dev/null | sed 's/\..*//' )
LLVM_MINOR = $(shell llvm-config --version 2>/dev/null | sed 's/.*\.//' | sed 's/git//' | sed 's/svn//' | sed 's/ .*//' )
$(info Detected LLVM VERSION : $(LLVMVER))

CC=clang
CXX=clang++
CFLAGS=`llvm-config --cflags` -fPIC -ggdb -O0
AR=ar

CXXFLAGS=`llvm-config --cxxflags` -fPIC -ggdb -O0

MAKEFILE_PATH=$(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR:=$(dir $(MAKEFILE_PATH))

.PHONY : clean all print_function

all: print_function

print_function: lib/libprintfunc.so lib/libpf-rt.a

lib/libprintfunc.so: src/print-function-pass.cpp
	mkdir -p lib
	$(CXX) $(CXXFLAGS) -shared $< -o $@

lib/libpf-rt.a: src/print-function-rt.cpp
	mkdir -p lib
	$(CXX) $(CXXFLAGS) -c $< -o lib/pf-rt.o
	$(AR) rcs $@ lib/pf-rt.o

test: lib/libprintfunc.so lib/libpf-rt.a
	$(MAKE) -C test

clean:
	rm -f lib/*.so lib/*.o log
