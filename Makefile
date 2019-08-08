# minimalist makefile123123123123123
######################
# To add a competitive technique, simply add your code in the src subdirectory (follow the README.md instructions) and
# add your executable file name to the EXECUTABLES variable below.
# along with a target to build it.
#######################
.SUFFIXES:
#
.SUFFIXES: .cpp .o .c .h

.PHONY: clean
UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
OSFLAGS= -Wl,--no-as-needed
endif

#######################
# SunOS gcc7.2.0 modifications QSI/Jon Strabala
#########
# original CXX flag, new for FLAGS
ifeq ($(UNAME), SunOS)
# must be 64 bit compile, new for CFLAGS
OSFLAGS= -m64
# force gnu99 intead of c99 for getopt, new for CFLAGS
OSCFLAGS= -std=gnu99
endif



ifeq ($(DEBUG),1)
CFLAGS = -fuse-ld=gold -fPIC  -std=c99 -ggdb -mavx2 -mbmi2 -march=native -Wall -Wextra -Wshadow -fsanitize=undefined  -fno-omit-frame-pointer -fsanitize=address  $(OSFLAGS) $(OSCFLAGS) -ldl
CXXFLAGS = -fuse-ld=gold -fPIC  -std=c++11 -ggdb -mavx2 -mbmi2 -march=native -Wall -Wextra -Wshadow -fsanitize=undefined  -fno-omit-frame-pointer -fsanitize=address   $(OSFLAGS) -ldl
ROARFLAGS = -DCMAKE_BUILD_TYPE=Debug -DSANITIZE=ON
else
CFLAGS = -ggdb -fPIC -std=c99 -O3 -mavx2 -mbmi2 -march=native -Wall -Wextra -Wshadow   $(OSFLAGS) -ldl
CXXFLAGS = -fPIC -std=c++11 -O3 -mavx2 -mbmi2  -march=native -Wall -Wextra -Wshadow   $(OSFLAGS) -ldl
ROARFLAGS = -DCMAKE_BUILD_TYPE=Release
endif # debug



EXECUTABLES=wah32_benchmarks concise_benchmarks roaring_benchmarks slow_roaring_benchmarks  bitmagic_benchmarks ewah32_benchmarks ewah64_benchmarks stl_vector_benchmarks stl_hashset_benchmarks stl_vector_benchmarks_memtracked stl_hashset_benchmarks_memtracked bitset_benchmarks malloced_roaring_benchmarks hot_roaring_benchmarks hot_slow_roaring_benchmarks gen

all: $(EXECUTABLES)

test:
	./scripts/all.sh

bigtest:
	./scripts/big.sh

hottest:
	./scripts/hot_roaring.sh




src/roaring.c :
	(cd src && exec ../CRoaring/amalgamation.sh && rm almagamation_demo.c && rm almagamation_demo.cpp)

gen : synthetic/anh_moffat_clustered.h synthetic/gen.cpp
	$(CXX) $(CXXFLAGS) -o gen synthetic/gen.cpp -Isynthetic

roaring_benchmarks : src/roaring.c src/roaring_benchmarks.c
	$(CC) $(CFLAGS) -o roaring_benchmarks src/roaring_benchmarks.c


hot_roaring_benchmarks : src/roaring.c src/hot_roaring_benchmarks.c
	$(CC) $(CFLAGS)  -ggdb -o hot_roaring_benchmarks src/hot_roaring_benchmarks.c

malloced_roaring_benchmarks : src/roaring.c src/roaring_benchmarks.c
	$(CC) $(CFLAGS) -o malloced_roaring_benchmarks src/roaring_benchmarks.c -DRECORD_MALLOCS


slow_roaring_benchmarks : src/roaring.c src/roaring_benchmarks.c
	$(CC) $(CFLAGS) -DDISABLE_X64 -o slow_roaring_benchmarks src/roaring_benchmarks.c

hot_slow_roaring_benchmarks : src/roaring.c src/hot_roaring_benchmarks.c
	$(CC) $(CFLAGS)   -ggdb  -DDISABLE_X64 -o hot_slow_roaring_benchmarks src/hot_roaring_benchmarks.c


bitmagic_benchmarks: src/bitmagic_benchmarks.cpp
	$(CXX) $(CXXFLAGS) -o bitmagic_benchmarks src/bitmagic_benchmarks.cpp -IBitMagic/src

ewah32_benchmarks: src/ewah32_benchmarks.cpp
	$(CXX) $(CXXFLAGS)  -o ewah32_benchmarks ./src/ewah32_benchmarks.cpp -IEWAHBoolArray/headers

wah32_benchmarks: src/wah32_benchmarks.cpp
	$(CXX) $(CXXFLAGS)  -o wah32_benchmarks ./src/wah32_benchmarks.cpp -IConcise/include

concise_benchmarks: src/concise_benchmarks.cpp
	$(CXX) $(CXXFLAGS)  -o concise_benchmarks ./src/concise_benchmarks.cpp -IConcise/include

ewah64_benchmarks: src/ewah64_benchmarks.cpp
	$(CXX) $(CXXFLAGS)  -o ewah64_benchmarks ./src/ewah64_benchmarks.cpp -IEWAHBoolArray/headers

stl_vector_benchmarks: src/stl_vector_benchmarks.cpp src/memtrackingallocator.h
	$(CXX) $(CXXFLAGS)  -o stl_vector_benchmarks ./src/stl_vector_benchmarks.cpp

stl_hashset_benchmarks: src/stl_hashset_benchmarks.cpp src/memtrackingallocator.h
	$(CXX) $(CXXFLAGS)  -o stl_hashset_benchmarks ./src/stl_hashset_benchmarks.cpp


stl_vector_benchmarks_memtracked: src/stl_vector_benchmarks.cpp src/memtrackingallocator.h
	$(CXX) $(CXXFLAGS)  -o stl_vector_benchmarks_memtracked ./src/stl_vector_benchmarks.cpp -DMEMTRACKED

stl_hashset_benchmarks_memtracked: src/stl_hashset_benchmarks.cpp src/memtrackingallocator.h
	$(CXX) $(CXXFLAGS)  -o stl_hashset_benchmarks_memtracked ./src/stl_hashset_benchmarks.cpp -DMEMTRACKED

bitset_benchmarks: src/bitset_benchmarks.c cbitset/include/bitset.h cbitset/src/bitset.c
	$(CC) $(CFLAGS)  -o bitset_benchmarks ./src/bitset_benchmarks.c cbitset/src/bitset.c   -Icbitset/include

clean:
	rm -r -f   $(EXECUTABLES) src/roaring.c src/roaring.h src/roaring.hh bigtmp
