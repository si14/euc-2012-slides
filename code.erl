handle(Data) ->
    case test1(Data) of
        {ok, Data2} ->
            case test2(Data2) of
                {ok, Data3} ->
                    case test3(Data3) of
                        {ok, Data4} ->
                            do_something(Data4);
                        {error, Err} ->
                            {error, {test3, Err}}
                    end;
                {error, Err} ->
                    {error, {test2, Err}}
            end;
        {error, Err} ->
            {error, {test1, Err}}
    end.

handle(Data) ->
    case test1(Data) of
        {ok, Data2} -> handle2(Data2);
        {error, Err} -> {error, {test1, Err}}
    end.

handle2(Data) ->
    case test2(Data) of
        {ok, Data2} -> handle3(Data2);
        {error, Err} -> {error, {test2, Err}}
    end.

-type colors() :: blue | red | green | yellow.
-type paintable_object() :: #paintable_object{}.

paint(Color, Object) ->
    true = sheriff:check(Color, colors),
    true = sheriff:check(Object, paintable_object),
    do_paint(Color, Object).

-type colors() :: blue | red | green | yellow.
paint(Color, Object) ->
    case sheriff:check(Color, colors) of
        true ->
            do_paint(Color, Object);
        false ->
            {error, badarg}
    end.

i_love_exceptions() ->
    {ok, Data} = get_data(),
    {ok, Params} = get_params(Data).

1> list_to_integer(<<"abc">>).
** exception error: bad argument
     in function  list_to_integer/1
        called as list_to_integer(<<"abc">>)

1> try list_to_integer(<<"abc">>)
1> catch error:badarg -> not_an_integer
1> end.
not_an_integer

test() ->
    try
        A = list_to_integer(StringA),
        B = list_to_integer(StringB),
        {ok, {A, B}}
    catch error:badarg -> {error, something_is_wrong}
    end.

comma_is_not_so_simple() ->
    Foo = make_foo(),
    make_bar(Foo).

conditional_comma() ->
    comma(make_foo(),
          fun (Foo) -> comma(make_bar(Foo),
                             fun (Bar) -> Bar end)
          end).

magic() ->
    do([Monad ||
        A <- make_foo(),
        Bar <- make_bar(A),
        Bar]).

write_file(Path, Data, Modes) ->
    Modes1 = [binary, write | (Modes -- [binary, write])],
    case make_binary(Data) of
        Bin when is_binary(Bin) ->
            case file:open(Path, Modes1) of
                {ok, Hdl} ->
                    case file:write(Hdl, Bin) of
                        ok ->
                            case file:sync(Hdl) of
                                ok ->
                                    file:close(Hdl);
                                {error, _} = E ->
                                    file:close(Hdl),
                                    E
                            end;
                        {error, _} = E ->
                            file:close(Hdl),
                            E
                    end;
                {error, _} = E -> E
            end;
        {error, _} = E -> E
    end.

write_file(Path, Data, Modes) ->
    Modes1 = [binary, write |
              (Modes -- [binary, write])],
    do([error_m ||
        Bin <- make_binary(Data),
        Hdl <- file:open(Path, Modes1),
        Result <- return(do([error_m ||
                             file:write(Hdl, Bin),
                             file:sync(Hdl)])),
        file:close(Hdl),
        Result])
