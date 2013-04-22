Logfmt for Erlang
=============

Erlang app for parsing log lines in the `logfmt` style.  See the
original project by Blake Mizerany and Keith Rarick for information
about `logfmt` conventions and use:

  https://github.com/kr/logfmt

```
$ make shell
/home/tristan/bin/rebar skip_deps=true compile
==> logfmt-erlang (compile)
Compiled src/logfmt.peg
Compiled src/logfmt.erl
Erlang R16B (erts-5.10.1) [source-05f1189] [64-bit] [smp:8:8] [async-threads:10] [hipe] [kernel-poll:false]

Eshell V5.10.1  (abort with ^G)
1> logfmt:parse("foo=bar a=14 baz=\"hello kitty\" cool%story=bro f %^asdf").
[[{<<"foo">>,<<"bar">>},
  {<<"a">>,14},
  {<<"baz">>,<<"hello kitty">>},
  {<<"cool%story">>,<<"bro">>},
  {<<"f">>,<<>>},
  {<<"%^asdf">>,<<>>}]]
```
