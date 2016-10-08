.PHONY: all

FLAGS=-std=c++11 -O3 -Wall -Wextra -pedantic -I.
FLAGS_SSE4=$(FLAGS) -msse4.1 
FLAGS_AVX2=$(FLAGS) -mavx2 -DHAVE_AVX2_INSTRUCTIONS

DEPS=utils/ansi.cpp utils/bits.cpp
DEPS_SSE4=sse4-strstr.cpp utils/sse.cpp $(DEPS)
DEPS_AVX2=avx2-strstr.cpp utils/avx2.cpp $(DEPS_SSE4)

ALL=validate \
    speedup \
    unittests \
    validate_avx2 \
    speedup_avx2 \
    unittests_avx2

all: $(ALL)

validate: src/validate.cpp src/application_base.cpp $(DEPS_SSE4)
	$(CXX) $(FLAGS_SSE4) src/validate.cpp -o $@

speedup: src/speedup.cpp src/application_base.cpp $(DEPS_SSE4)
	$(CXX) $(FLAGS_SSE4) src/speedup.cpp -o $@

unittests: src/unittests.cpp $(DEPS_SSE4)
	$(CXX) $(FLAGS_SSE4) src/unittests.cpp -o $@

validate_avx2: src/validate.cpp src/application_base.cpp $(DEPS_AVX2)
	$(CXX) $(FLAGS_AVX2) src/validate.cpp -o $@

speedup_avx2: src/speedup.cpp src/application_base.cpp $(DEPS_AVX2)
	$(CXX) $(FLAGS_AVX2) src/speedup.cpp -o $@

unittests_avx2: src/unittests.cpp $(DEPS_AVX2)
	$(CXX) $(FLAGS_AVX2) src/unittests.cpp -o $@

data/i386.txt:
	wget http://css.csail.mit.edu/6.858/2013/readings/i386.txt data/i386.txt

data/words: data/i386.txt
	sh make_words.sh $^ $@

test: unittests validate data/words data/i386.txt
	./unittests
	./validate data/i386.txt data/words

run: speedup data/words data/i386.txt
	./speedup data/i386.txt data/words 

clean:
	rm -f $(ALL)