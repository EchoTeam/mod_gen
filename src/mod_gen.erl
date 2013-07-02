%%% vim: set ts=4 sts=4 sw=4 expandtab:
-module(mod_gen).
-export([
        go/1
    ]).

go(Decls) ->
    Forms = [begin
        BDecl = iolist_to_binary(D),
        SDecl = binary_to_list(BDecl),
        {ok, S, _} = erl_scan:string(SDecl),
        {ok, Form} = erl_parse:parse_form(S),
        Form
     end || D <- Decls],
    {ok, ModuleName, Binary} = compile:forms(Forms),
    {module, ModuleName} = code:load_binary(ModuleName, "nofile", Binary).


-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

go_test() ->
    M = module1,
    F = func1,
    V = 123,
    Decls = [
        ["-module(", atom_to_list(M), ")."],
        ["-export([", atom_to_list(F), "/0])."],
        [atom_to_list(F), "() -> ", integer_to_list(V), "."]
    ],
    go(Decls),
    ?assertEqual(V, apply(M, F, [])).

-endif.
