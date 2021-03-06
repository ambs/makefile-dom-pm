# Description:
#    Test pattern rules.
#
# Details:
#    

use t::Gmake;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST #0: Make sure that multiple patterns where the same target
can be built are searched even if the first one fails
to match properly.

--- source preprocess

.PHONY: all

all: case.1 case.2 case.3
a: void

# 1 - existing file
%.1: void
	@exit 1
%.1: #MAKEFILE#
	@exit 0

# 2 - phony
%.2: void
	@exit 1
%.2: 2.phony
	@exit 0
.PHONY: 2.phony

# 3 - implicit-phony
%.3: void
	@exit 1
%.3: 3.implicit-phony
	@exit 0

3.implicit-phony:

--- stdout
--- stderr
--- error_code:  0



=== TEST #1: make sure files that are built via implicit rules are marked
as targets (Savannah bug #12202).

--- source

TARGETS := foo foo.out

.PHONY: all foo.in

all: $(TARGETS)

%: %.in
	@echo $@

%.out: %
	@echo $@

foo.in: ; @:


--- stdout
foo
foo.out
--- stderr
--- error_code:  0



=== TEST #2: make sure intermediate files that also happened to be
prerequisites are not removed (Savannah bug #12267).

--- source

$(dir)/foo.o:

$(dir)/foo.y:
	@echo $@

%.c: %.y
	touch $@

%.o: %.c
	@echo $@

.PHONY: install
install: $(dir)/foo.c


--- options preprocess:  dir=#PWD#
--- stdout preprocess
#PWD#/foo.y
touch #PWD#/foo.c
#PWD#/foo.o
--- stderr
--- error_code:  0



=== TEST #3: make sure precious flag is set properly for targets
that are built via implicit rules (Savannah bug #13218).

--- source

.DELETE_ON_ERROR:

.PRECIOUS: %.bar

%.bar:; @touch $@ && exit 1

$(dir)/foo.bar:


--- options preprocess:  dir=#PWD#
--- stdout
--- stderr preprocess
#MAKE#: *** [#PWD#/foo.bar] Error 1
--- error_code:  2



=== TEST #4: make sure targets of a matched implicit pattern rule are
never considered intermediate (Savannah bug #13022).

--- source

.PHONY: all
all: foo.c foo.o

%.h %.c: %.in
	touch $*.h
	touch $*.c

%.o: %.c %.h
	echo $+ >$@

%.o: %.c
	@echo wrong rule

foo.in:
	touch $@


--- stdout
touch foo.in
touch foo.h
touch foo.c
echo foo.c foo.h >foo.o
--- stderr
--- error_code:  0

