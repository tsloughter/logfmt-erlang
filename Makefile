ERLFLAGS= -pa $(CURDIR)/.eunit -pa $(CURDIR)/ebin -pa $(CURDIR)/deps/*/ebin

DEPS_PLT=$(CURDIR)/.deps_plt

# =============================================================================
# Verify that the programs we need to run are installed on this system
# =============================================================================
ERL = $(shell which erl)

ifeq ($(ERL),)
$(error "Erlang not available on this system")
endif

REBAR=$(shell which rebar)

ifeq ($(REBAR),)
$(error "Rebar not available on this system")
endif

# =============================================================================
# Handle version discovery
# =============================================================================

DIALYZER=$(shell which dialyzer)

.PHONY: all compile doc clean test dialyzer typer shell distclean pdf \
	update-deps clean-common-test-data rebuild

all: deps compile

# =============================================================================
# Rules to build the system
# =============================================================================

deps:
	$(REBAR) get-deps
	$(REBAR) compile

update-deps:
	$(REBAR) update-deps
	$(REBAR) compile

compile:
	$(REBAR) skip_deps=true compile

doc:
	$(REBAR) skip_deps=true doc

eunit: compile clean-common-test-data
	$(REBAR) skip_deps=true eunit

ct: compile clean-common-test-data
	mkdir -p $(CURDIR) logs
	ct_run -pa $(CURDIR)/ebin \
	-pa $(CURDIR)/deps/*/ebin \
	-logdir $(CURDIR)/logs \
	-dir $(CURDIR)/test/ \
	-suite rclt_command_SUITE rclt_discover_SUITE -suite rclt_release_SUITE

test: compile eunit ct

$(DEPS_PLT):
	@echo Building local erts plt at $(DEPS_PLT)
	@echo
	$(DIALYZER) --output_plt $(DEPS_PLT) --build_plt \
	   --apps erts kernel stdlib -r deps

dialyzer: $(DEPS_PLT)
	$(DIALYZER) --fullpath --plt $(DEPS_PLT) \
		 -I include -Wrace_conditions -r ./ebin

typer:
	typer --plt $(DEPS_PLT) -r ./src

shell: deps compile
	@$(ERL) $(ERLFLAGS)

pdf:
	pandoc README.md -o README.pdf

clean-common-test-data:
# We have to do this because of the unique way we generate test
# data. Without this rebar eunit gets very confused
	- rm -rf $(CURDIR)/test/*_SUITE_data

clean: clean-common-test-data
	- rm -rf $(CURDIR)/test/*.beam
	- rm -rf $(CURDIR)/logs
	- rm -rf $(CURDIR)/ebin
	$(REBAR) skip_deps=true clean

distclean: clean
	- rm -rf $(DEPS_PLT)
	- rm -rvf $(CURDIR)/deps

rebuild: distclean deps compile dialyzer test
