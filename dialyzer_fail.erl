-module(dialyzer_fail).
-compile(export_all).

good() ->
    A = 1,
    B = "string",
    A + B.

bad() ->
    A = 1,
    B = "string",
    C = try throw(B)
        catch _:BThrowed -> BThrowed
        end,
    A + C.
