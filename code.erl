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
    catch error:badarg -> {error, smth_is_wrong}
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

validate_some_input(Input) ->
    try
        WrappedInput = z_wrap(Input, error_in_foo),
        Foo = z_bin_to_int(
                z_proplist_get(MaybeInput, {foo})),
        SmallFoo = z_int_in_range(Foo, {1, 10}),
        z_return(z_unwrap(SmallFoo))
    catch
        ?Z_OK(Result)   -> {ok, Result};
        ?Z_ERROR(Error) -> {error, Error}
    end.

z_extract_small_int(List, Key) ->
    z_int_in_range(
      z_bin_to_int(
        z_proplist_get(List, {Key}),
       {1, 10})).

-define(Z_CATCH(EXPR, ERROR),
        try
            EXPR
        catch
            _:_ -> throw({z_throw, {error, ERROR}})
        end).

try
    {Method, TaskName, VarSpecs} =
      ?Z_CATCH({_, _, _} = lists:keyfind(Method, 1, TaskSpecs),
               bad_method),
    TaskVarsRoute =
      ?Z_CATCH([fetch_var(RouteVar, RouteVarType, Bindings)
                || {RouteVar, RouteVarType} <- RouteVars],
               bad_route),
    TaskVars = [?Z_CATCH(fetch_var(Var, VarType, QSVals),
                         {bad_var, Var})
                || {Var, VarType} <- VarSpecs],
    z_return(rnbwdash_task:create(...))
catch
    ?Z_OK(Task) -> form_reply(run_task(Task), Errors, Req@);
    ?Z_ERROR(Err) -> form_error(Err, Req@)
end

{Method, TaskName, VarSpecs} =
  ?Z_CATCH({_, _, _} = lists:keyfind(Method, 1,
                                     TaskSpecs)
           bad_method)

TaskVarsRoute =
  ?Z_CATCH([fetch_var(RouteVar, RouteVarType, Bindings)
            || {RouteVar, RouteVarType} <- RouteVars],
           bad_route)

TaskVars = [?Z_CATCH(fetch_var(Var, VarType, QSVals),
                     {bad_var, Var})
            || {Var, VarType} <- VarSpecs]

error(bad_route) ->
    {404, <<"Check path variables">>};
error(bad_method) ->
    {405, <<"No such method in API">>};
error({bad_var, Var}) ->
    {400, [<<"Check variable ">>, Var]}.

-define(GOOD_DATA,
        [{login, <<"test_login">>},
         {password, <<"test_password">>},
         {session_id, <<"123">>},
         {good_user, <<"true">>},
         {some_other_id, <<"345">>},
         {yet_another_id, <<"56">>},
         {extra_data,
          term_to_binary({foo, bar, baz})}]).

-define(BAD_DATA1,
        [{login, <<"test_login">>},
         {session_id, <<"123">>}, %% no password
         {good_user, <<"true">>},
         {some_other_id, <<"345">>},
         {yet_another_id, <<"56">>},
         {extra_data,
          term_to_binary({foo, bar, baz})}]).

-define(BAD_DATA2,
        [{login, <<"test_login">>},
         {password, <<"test_password">>},
         {session_id, <<"123">>},
         {good_user, <<"true">>},
         {some_other_id, <<"345">>},
         {yet_another_id, <<"56abc">>}, %% bad ID
         {extra_data,
          term_to_binary({foo, bar, baz})}]).

test_handler_base(Data) ->
    try
        Login = proplist_get(Data, login),
        Password = proplist_get(Data, password),
        SessionBin = proplist_get(Data, session_id),
        Session = bin_to_int(SessionBin),
        GoodUserBin = proplist_get(Data, good_user),
        GoodUser = bin_to_bool(GoodUserBin),
        SomeOtherIdBin = proplist_get(Data, some_other_id),
        SomeOtherId = bin_to_int(SomeOtherIdBin),
        YetAnotherIdBin = proplist_get(Data, yet_another_id),
        YetAnotherId = bin_to_int(YetAnotherIdBin),
        ExtraDataBin = proplist_get(Data, extra_data),
        ExtraData = bin_to_term(ExtraDataBin),
        #request{login=Login, password=Password, ...}
    catch A:B -> {A, B}
    end.
