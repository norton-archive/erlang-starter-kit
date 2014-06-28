
REBAR?=./rebar

OTPREL=$(shell erl -noshell -eval 'io:format(erlang:system_info(otp_release)), halt().')
PLT=$(HOME)/.dialyzer_plt.$(OTPREL)

ERLDIRS?=./deps
ERLEUNITDIRS=`find $(ERLDIRS) -name .eunit -print | xargs echo` .eunit
ERLQCDIRS=`find $(ERLDIRS) -name .qc -print | xargs echo` .qc

DIALYZE_IGNORE_WARN?=dialyze-ignore-warnings.txt
DIALYZE_NOSPEC_IGNORE_WARN?=dialyze-nospec-ignore-warnings.txt

#TBD DIALYZER_OPTS?=-Wunmatched_returns -Werror_handling -Wrace_conditions -Wunderspecs
DIALYZER_OPTS?=-Wunmatched_returns -Werror_handling -Wunderspecs
DIALYZER_NOSPEC_OPTS?=-Wno_undefined_callbacks

dialyzer=dialyzer -q --plt $(PLT) $(DIALYZER_OPTS) -r $(ERLDIRS)
dialyzer-nospec=dialyzer -q --plt $(PLT) --no_spec $(DIALYZER_NOSPEC_OPTS) -r $(ERLDIRS)
dialyzer-eunit=dialyzer -q --plt $(PLT) $(DIALYZER_OPTS) -r $(ERLEUNITDIRS)
dialyzer-eunit-nospec=dialyzer -q --plt $(PLT) --no_spec $(DIALYZER_NOSPEC_OPTS) -r $(ERLEUNITDIRS)
dialyzer-qc=dialyzer -q --plt $(PLT) $(DIALYZER_OPTS) -r $(ERLQCDIRS)
dialyzer-qc-nospec=dialyzer -q --plt $(PLT) --no_spec $(DIALYZER_NOSPEC_OPTS) -r $(ERLQCDIRS)

ifeq ($(shell uname -s),Darwin)
	ifeq ($(shell uname -m),x86_64)
		otp_configure_flags= --enable-darwin-64bit
	else
		otp_configure_flags= --enable-darwin-universal
	endif
else
	otp_configure_flags=
endif

.PHONY: all clean deps compile xref doc test eunit eqc proper triq \
	compile-for-eunit compile-for-eqc compile-for-proper compile-for-triq \
	ctags etags \
	dialyze dialyze-nospec \
	update-dialyzer-baseline update-dialyzer-nospec-baseline \
	dialyze-eunit dialyze-eunit-nospec \
	dialyze-eqc dialyze-eqc-nospec \
	dialyze-proper dialyze-proper-nospec \
	dialyze-triq dialyze-triq-nospec \
	build-plt check-plt \
	otp_make_release_tests otp_run_release_tests

all: compile

deps:
	$(REBAR) get-deps

clean:
	$(REBAR) clean
	@rm -f TAGS

compile:
	$(REBAR) compile

xref:
	$(REBAR) xref

doc:
	@rm -rf README.md doc/edoc-info doc/*.md
	$(REBAR) -C rebar.config.doc get-deps compile
	$(REBAR) -C rebar.config.doc doc

test: eunit

eunit: compile-for-eunit
	$(REBAR) eunit

eqc: compile-for-eqc
	$(REBAR) eqc

proper: compile-for-proper
	@echo "rebar does not implement a 'proper' command" && false

triq: compile-for-triq
	$(REBAR) triq

compile-for-eunit:
	$(REBAR) compile eunit compile_only=true

compile-for-eqc:
	$(REBAR) -D QC -D QC_EQC compile eqc compile_only=true

compile-for-proper:
	$(REBAR) -D QC -D QC_PROPER compile eqc compile_only=true

compile-for-triq:
	$(REBAR) -D QC -D QC_TRIQ compile triq compile_only=true

#
# tags
#

ctags:
	find $(ERLDIRS) -name "*.[he]rl" -print | fgrep -v .eunit | fgrep -v .qc | ctags -
	find $(ERLDIRS) -name "*.app.src" -print | fgrep -v .eunit | fgrep -v .qc | ctags -a -
	find $(ERLDIRS) -name "*.config" -print | fgrep -v .eunit | fgrep -v .qc | ctags -a -
	find $(ERLDIRS) -name "*.[ch]" -print | fgrep -v .eunit | fgrep -v .qc | ctags -a -
	find $(ERLDIRS) -name "*.cc" -print | fgrep -v .eunit | fgrep -v .qc | ctags -a -
	find $(ERLDIRS) -name "*.con" -print | fgrep -v .eunit | fgrep -v .qc | ctags -a -

etags:
	find $(ERLDIRS) -name "*.[he]rl" -print | fgrep -v .eunit | fgrep -v .qc | etags -
	find $(ERLDIRS) -name "*.app.src" -print | fgrep -v .eunit | fgrep -v .qc | etags -a -
	find $(ERLDIRS) -name "*.config" -print | fgrep -v .eunit | fgrep -v .qc | etags -a -
	find $(ERLDIRS) -name "*.[ch]" -print | fgrep -v .eunit | fgrep -v .qc | etags -a -
	find $(ERLDIRS) -name "*.cc" -print | fgrep -v .eunit | fgrep -v .qc | etags -a -
	find $(ERLDIRS) -name "*.con" -print | fgrep -v .eunit | fgrep -v .qc | etags -a -

#
# dialyzer
#

dialyze: build-plt clean compile
	-$(dialyzer) | grep -v '^ *$$' | tee $(DIALYZE_IGNORE_WARN).log | fgrep -v -f $(DIALYZE_IGNORE_WARN)

dialyze-nospec: build-plt clean compile
	-$(dialyzer-nospec) | grep -v '^ *$$' | tee $(DIALYZE_NOSPEC_IGNORE_WARN).log | fgrep -v -f $(DIALYZE_NOSPEC_IGNORE_WARN)

update-dialyzer-baseline: dialyze
	mv -f $(DIALYZE_IGNORE_WARN).log $(DIALYZE_IGNORE_WARN)

update-dialyzer-nospec-baseline: dialyze-nospec
	mv -f $(DIALYZE_NOSPEC_IGNORE_WARN).log $(DIALYZE_NOSPEC_IGNORE_WARN)

dialyze-eunit: build-plt clean compile-for-eunit
	-$(dialyzer-eunit) | grep -v '^ *$$' | tee $(DIALYZE_IGNORE_WARN).log | fgrep -v -f $(DIALYZE_IGNORE_WARN)

dialyze-eunit-nospec: build-plt clean compile-for-eunit
	-$(dialyzer-eunit-nospec) | grep -v '^ *$$' | tee $(DIALYZE_NOSPEC_IGNORE_WARN).log | fgrep -v -f $(DIALYZE_NOSPEC_IGNORE_WARN)

dialyze-eqc: build-plt clean compile-for-eqc
	-$(dialyzer-qc) | grep -v '^ *$$' | tee $(DIALYZE_IGNORE_WARN).log | fgrep -v -f $(DIALYZE_IGNORE_WARN)

dialyze-eqc-nospec: build-plt clean compile-for-eqc
	-$(dialyzer-qc-nospec) | grep -v '^ *$$' | tee $(DIALYZE_NOSPEC_IGNORE_WARN).log | fgrep -v -f $(DIALYZE_NOSPEC_IGNORE_WARN)

dialyze-proper: build-plt clean compile-for-proper
	-$(dialyzer-qc) | grep -v '^ *$$' | tee $(DIALYZE_IGNORE_WARN).log | fgrep -v -f $(DIALYZE_IGNORE_WARN)

dialyze-proper-nospec: build-plt clean compile-for-proper
	-$(dialyzer-qc-nospec) | grep -v '^ *$$' | tee $(DIALYZE_NOSPEC_IGNORE_WARN).log | fgrep -v -f $(DIALYZE_NOSPEC_IGNORE_WARN)

dialyze-triq: build-plt clean compile-for-triq
	-$(dialyzer-qc) | grep -v '^ *$$' | tee $(DIALYZE_IGNORE_WARN).log | fgrep -v -f $(DIALYZE_IGNORE_WARN)

dialyze-triq-nospec: build-plt clean compile-for-triq
	-$(dialyzer-qc-nospec) | grep -v '^ *$$' | tee $(DIALYZE_NOSPEC_IGNORE_WARN).log | fgrep -v -f $(DIALYZE_NOSPEC_IGNORE_WARN)

#
# dialyzer PLT
#

build-plt: $(PLT)

check-plt: $(PLT)
	dialyzer -q --plt $(PLT) --check_plt

$(PLT):
	-dialyzer -q --build_plt --output_plt $(PLT) --apps \
		asn1 \
		compiler \
		crypto \
		dialyzer \
		diameter \
		edoc \
		erts \
		et \
		eunit \
		gs \
		hipe \
		inets \
		kernel \
		mnesia \
		parsetools \
		public_key \
		runtime_tools \
		sasl \
		ssl \
		stdlib \
		syntax_tools \
		tools \
		webtool \
		xmerl

#
# rebar
#

# $ rm -rf rebar rebar.git
# $ make -f rebar.mk rebar
rebar: rebar.git
	(source ~/.kerl/installations/r13b04/activate && cd $(CURDIR)/rebar.git && make clean && make && cp -f rebar ..)
	$(REBAR) -V
	echo git commit -m \"Update rebar \(`./rebar -V | cut -d ' ' -f 6`\)\" rebar

rebar.git:
	rm -rf $(CURDIR)/rebar
	git clone git://github.com/norton/rebar.git rebar.git

#
# Erlang/OTP
#

otp: otp.git
	make -C $(CURDIR)/otp.git install

otp.git:
	rm -rf $(CURDIR)/otp
	mkdir -p $(CURDIR)/otp
	git clone git://github.com/erlang/otp.git otp.git
	(cd $(CURDIR)/otp.git && \
		git co OTP-17.1 && \
		./otp_build autoconf && \
		./configure \
			--disable-hipe \
			--enable-debug \
			--enable-kernel-poll \
			--enable-threads \
			--enable-dynamic-ssl-lib \
			--enable-shared-zlib \
			--enable-smp-support \
			$(otp_configure_flags) \
			--prefix=$(CURDIR)/otp)
	make -C $(CURDIR)/otp.git

otp-debug: otp.git
	env ERL_TOP=$(CURDIR)/otp.git make -C otp.git/erts/emulator debug FLAVOR=smp

otp-valgrind: otp.git
	env ERL_TOP=$(CURDIR)/otp.git make -C otp.git/erts/emulator valgrind FLAVOR=smp

cerl-debug: otp.git
	env ERL_TOP=$(CURDIR)/otp.git otp.git/bin/cerl -debug

cerl-valgrind: otp.git
	env ERL_TOP=$(CURDIR)/otp.git otp.git/bin/cerl -valgrind

## See https://github.com/erlang/otp/wiki/Running-tests for details
otp_make_release_tests: otp.git
	rm -rf otp.git/release/tests
	env ERL_TOP=$(CURDIR)/otp.git ERL_LIBS=$(CURDIR)/otp.git/lib \
		make -C otp.git release_tests

otp_run_release_tests: otp_make_release_tests
	@echo ""
	@echo "** Warning killing all local beam, beam.smp, and epmd programs **"
	@echo ""
	sleep 10
	killall -q -9 beam || true
	killall -q -9 beam.smp || true
	killall -q -9 epmd || true
	@echo ""
	@echo "** Open '$(CURDIR)/otp.git/release/tests/test_server/index.html' in your browser**"
	@echo ""
	sleep 10
	(cd $(CURDIR)/otp.git/release/tests/test_server && \
		env ERL_TOP=$(CURDIR)/otp.git ERL_LIBS=$(CURDIR)/otp.git/lib \
			$(CURDIR)/otp.git/bin/erl \
				-s ts install \
				-s ts run \
				-s erlang halt)
