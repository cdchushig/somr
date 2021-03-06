DEBUG = 0

PACKAGE = somr
LIB_TARGET = lib/lib$(PACKAGE).so
DEMO_TARGETS = bin/somrviz

CC = gcc
LD = $(CC)
CFLAGS = -std=c11 -Wall -Wextra -Wno-sign-compare -Iinclude/
LDFLAGS =

ifeq ($(DEBUG), 1)
CFLAGS += -g -DDEBUG
else
CFLAGS += -O2 -DNDEBUG
endif

LIB_CFLAGS = -fPIC -Iinclude/$(PACKAGE)/
LIB_LDFLAGS = -lm

DEMO_CFLAGS =  -Iinclude/ $(shell pkg-config --cflags libpng)
DEMO_LDFLAGS = -lm $(shell pkg-config --libs libpng)

LIB_SRCS = $(wildcard src/*.c)
LIB_OBJS = $(patsubst src/%.c, obj/lib/%.o, $(LIB_SRCS))
LIB_DEPS = $(wildcard .d/lib/*.d)
DEMO_SRCS = $(wildcard demo/*.c)
DEMO_DEPS = $(wildcard .d/demo/*.d)

.PHONY: all lib demo clean

all: lib demo

lib: $(LIB_TARGET)

demo: $(DEMO_TARGETS)

lib/lib$(PACKAGE).so: $(LIB_OBJS)
	@mkdir -p $(@D)
	$(LD) -shared $^ -o $@ $(LDFLAGS) $(LIB_LDFLAGS)

bin/%: obj/demo/%.o $(LIB_OBJS)
	@mkdir -p $(@D)
	$(LD) -o $@ $^ $(LDFLAGS) $(DEMO_LDFLAGS)

obj/lib/%.o: src/%.c
	@mkdir -p $(@D) .d/lib
	$(CC) $(CFLAGS) $(LIB_CFLAGS) -MMD -MF .d/lib/$*.d -c -o $@ $<

obj/demo/%.o: demo/%.c $(LIB_OBJS)
	@mkdir -p $(@D) .d/demo
	$(CC) $(CFLAGS) $(DEMO_CFLAGS) -MMD -MF .d/demo/$*.d -c -o $@ $<

ifneq ($(MAKECMDGOALS), clean)
-include $(LIB_DEPS)
-include $(DEMO_DEPS)
endif

clean:
	$(RM) lib/* bin/* obj/lib/* obj/demo/* .d/lib/* .d/demo/*
