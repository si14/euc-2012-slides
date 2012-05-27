-module(perf_test).
-compile(export_all).
-compile({parse_transform, do}).
-include_lib("z_validate/include/z_validate.hrl").
-define(GOOD_DATA, [{login, <<"test_login">>},
                    {password, <<"test_password">>},
                    {session_id, <<"123">>},
                    {good_user, <<"true">>},
                    {some_other_id, <<"345">>},
                    {yet_another_id, <<"56">>},
                    {extra_data, term_to_binary({foo, bar, baz})}]).
-define(BAD_DATA1, [{login, <<"test_login">>},
                    {session_id, <<"123">>},
                    {good_user, <<"true">>},
                    {some_other_id, <<"345">>},
                    {yet_another_id, <<"56">>},
                    {extra_data, term_to_binary({foo, bar, baz})}]).
-define(BAD_DATA2, [{login, <<"test_login">>},
                    {password, <<"test_password">>},
                    {session_id, <<"123">>},
                    {good_user, <<"true">>},
                    {some_other_id, <<"345">>},
                    {yet_another_id, <<"56abc">>},
                    {extra_data, term_to_binary({foo, bar, baz})}]).

-record(request, {login, password, session_id, good_user,
                  some_other_id, yet_another_id, extra_data}).

-define(DEFAULT_RUNS, 100000).

test() ->
    [{TestCase, test(?DEFAULT_RUNS, TestCase)}
     || TestCase <- [test_handler_base, test_handler_edo, test_handler_z]].

test(N, Fun) ->
    {T1, T2, T3} = test(N, {0.0, 0.0, 0.0}, Fun),
    {T1 / N, T2 / N, T3 / N}.

test(0, Times, _) -> Times;
test(N, {TimeGood, TimeBad1, TimeBad2}, Fun) ->
    {NewTimeGood, _} = timer:tc(?MODULE, Fun, [?GOOD_DATA]),
    {NewTimeBad1, _} = timer:tc(?MODULE, Fun, [?BAD_DATA1]),
    {NewTimeBad2, _} = timer:tc(?MODULE, Fun, [?BAD_DATA2]),
    test(N-1, {TimeGood + NewTimeGood, TimeBad1 + NewTimeBad1,
               TimeBad2 + NewTimeBad2}, Fun).

test_handler_base(Data) ->
    try
        Login = base_proplist_get(Data, login),
        Password = base_proplist_get(Data, password),
        SessionBin = base_proplist_get(Data, session_id),
        Session = base_bin_to_int(SessionBin),
        GoodUserBin = base_proplist_get(Data, good_user),
        GoodUser = bin_to_bool(GoodUserBin),
        SomeOtherIdBin = base_proplist_get(Data, some_other_id),
        SomeOtherId = base_bin_to_int(SomeOtherIdBin),
        YetAnotherIdBin = base_proplist_get(Data, yet_another_id),
        YetAnotherId = base_bin_to_int(YetAnotherIdBin),
        ExtraDataBin = base_proplist_get(Data, extra_data),
        ExtraData = base_bin_to_term(ExtraDataBin),
        #request{login=Login, password=Password, session_id=Session,
                 good_user=GoodUser, some_other_id=SomeOtherId,
                 yet_another_id=YetAnotherId, extra_data=ExtraData}
    catch A:B -> {A, B}
    end.

base_proplist_get(List, Key) ->
    {_Key, Val} = lists:keyfind(Key, 1, List),
    Val.

base_bin_to_int(Bin) ->
    list_to_integer(binary_to_list(Bin)).

base_bin_to_term(Bin) ->
    binary_to_term(Bin).

base_bin_to_bool(Bin) ->
    bin_to_bool(Bin).

test_handler_edo(Data) ->
    do([error_m ||
           Login <- edo_proplist_get(Data, login),
           Password <- edo_proplist_get(Data, password),
           SessionBin <- edo_proplist_get(Data, session_id),
           Session <- edo_bin_to_int(SessionBin),
           GoodUserBin <- edo_proplist_get(Data, good_user),
           GoodUser <- edo_bin_to_bool(GoodUserBin),
           SomeOtherIdBin <- edo_proplist_get(Data, some_other_id),
           SomeOtherId <- edo_bin_to_int(SomeOtherIdBin),
           YetAnotherIdBin <- edo_proplist_get(Data, yet_another_id),
           YetAnotherId <- edo_bin_to_int(YetAnotherIdBin),
           ExtraDataBin <- edo_proplist_get(Data, extra_data),
           ExtraData <- edo_bin_to_term(ExtraDataBin),
           #request{login=Login, password=Password, session_id=Session,
                    good_user=GoodUser, some_other_id=SomeOtherId,
                    yet_another_id=YetAnotherId, extra_data=ExtraData}]).

edo_proplist_get(List, Key) ->
    case lists:keyfind(Key, 1, List) of
        false -> error_m:fail({key_missing, Key});
        {_Key, Val} -> error_m:return(Val)
    end.

edo_bin_to_int(Bin) ->
    try error_m:return(list_to_integer(binary_to_list(Bin)))
    catch error:badarg -> error_m:fail(not_integer)
    end.

edo_bin_to_term(Bin) ->
    try error_m:return(binary_to_term(Bin))
    catch error:badarg -> error_m:fail(not_encoded_data)
    end.

edo_bin_to_bool(<<"true">>)  -> error_m:return(true);
edo_bin_to_bool(<<"false">>) -> error_m:return(false);
edo_bin_to_bool(_)           -> error_m:fail(not_boolean).

test_handler_z(Data) ->
    try
        Login = zv_proplist_get(Data, login),
        Password = zv_proplist_get(Data, password),
        SessionBin = zv_proplist_get(Data, session_id),
        Session = zv_bin_to_int(SessionBin),
        GoodUserBin = zv_proplist_get(Data, good_user),
        GoodUser = bin_to_bool(GoodUserBin),
        SomeOtherIdBin = zv_proplist_get(Data, some_other_id),
        SomeOtherId = zv_bin_to_int(SomeOtherIdBin),
        YetAnotherIdBin = zv_proplist_get(Data, yet_another_id),
        YetAnotherId = zv_bin_to_int(YetAnotherIdBin),
        ExtraDataBin = zv_proplist_get(Data, extra_data),
        ExtraData = zv_bin_to_term(ExtraDataBin),
        z_return(#request{login=Login, password=Password, session_id=Session,
                          good_user=GoodUser, some_other_id=SomeOtherId,
                          yet_another_id=YetAnotherId, extra_data=ExtraData})
    catch
        ?Z_OK(Res) -> Res;
        ?Z_ERROR(Err) -> Err
    end.

zv_proplist_get(List, Key) ->
    ?Z_CATCH(begin
                 {_Key, Val} = lists:keyfind(Key, 1, List),
                 Val
             end,
             {key_missing, Key}).

zv_bin_to_int(Bin) ->
    ?Z_CATCH(list_to_integer(binary_to_list(Bin)), not_integer).

zv_bin_to_term(Bin) ->
    ?Z_CATCH(binary_to_term(Bin), not_encoded_data).

zv_bin_to_bool(Bin) ->
    ?Z_CATCH(bin_to_bool(Bin), not_boolean).

bin_to_bool(<<"true">>)  -> true;
bin_to_bool(<<"false">>) -> false.

get_data(good) -> ?GOOD_DATA;
get_data(bad1) -> ?BAD_DATA1;
get_data(bad2) -> ?BAD_DATA2.
