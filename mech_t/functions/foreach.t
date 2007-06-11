# Description:
#    Test the foreach function.
#
# Details:
#    This is a test of the foreach function in gnu make.
#    This function starts with a space separated list of
#    names and a variable. Each name in the list is subsituted
#    into the variable and the given text evaluated. The general
#    form of the command is 1000 1001 1000 118 114 113 111 110 46 44 30 29 25 24 20 4foreach var,,). Several
#    types of foreach loops are tested


use t::Gmake;

plan tests => 3 * blocks();

run_tests;

__DATA__

=== TEST 0
$Id: foreach,v 1.5 2006/03/10 02:20:46 psmith Exp $
Set an environment variable that we can test in the makefile.

--- source
space = ' '
null :=
auto_var = udef space CC null FOOFOO MAKE foo CFLAGS WHITE @ <
foo = bletch null @ garf
av = $(foreach var, $(auto_var), $(origin $(var)) )
override WHITE := BLACK
for_var = $(addsuffix .c,foo $(null) $(foo) $(space) $(av) )
fe = $(foreach var2, $(for_var),$(subst .c,.o, $(var2) ) )
all: auto for2
auto : ; @echo $(av)
for2: ; @echo $(fe)

--- pre:  $::ExtraENV{'FOOFOO'} = 'foo foo';
--- options:  -e WHITE=WHITE CFLAGS=
--- stdout
undefined file default file environment default file command line override automatic automatic
foo.o bletch.o null.o @.o garf.o .o    .o undefined.o file.o default.o file.o environment.o default.o file.o command.o line.o override.o automatic.o automatic.o
--- stderr
--- error_code:  0



=== TEST 1: Test that foreach variables take precedence over global
variables in a global scope (like inside an eval).  Tests bug #11913

--- source

.PHONY: all target
all: target

x := BAD

define mktarget
target: x := $(x)
target: ; @echo "$(x)"
endef

x := GLOBAL

$(foreach x,FOREACH,$(eval $(value mktarget)))
--- stdout
FOREACH
--- stderr
--- error_code:  0



=== TEST 2: Check some error conditions.
--- source

x = $(foreach )
y = $x

all: ; @echo $y
--- stdout
--- stderr preprocess
#MAKEFILE#:1: *** insufficient number of arguments (1) to function `foreach'.  Stop.
--- error_code:  2



=== TEST 4:
--- source

x = $(foreach )
y := $x

all: ; @echo $y
--- stdout
--- stderr preprocess
#MAKEFILE#:1: *** insufficient number of arguments (1) to function `foreach'.  Stop.
--- error_code:  2

