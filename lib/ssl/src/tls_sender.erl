%%
%% %CopyrightBegin%
%%
%% SPDX-License-Identifier: Apache-2.0
%%
%% Copyright Ericsson AB 2018-2025. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% %CopyrightEnd%
%%

-module(tls_sender).
-moduledoc false.

-behaviour(gen_statem).

-include("ssl_internal.hrl").
-include("ssl_alert.hrl").
-include("ssl_record.hrl").
-include("tls_handshake_1_3.hrl").

%% API
-export([start_link/0,
         start_link/1,
         initialize/2,
         send_data/2,
         send_post_handshake/2,
         send_alert/2,
         send_and_ack_alert/2,
         renegotiate/1,
         peer_renegotiate/1,
         downgrade/2,
         update_connection_state/3,
         dist_handshake_complete/3]).

%% gen_statem callbacks
-export([callback_mode/0,
         init/1,
         terminate/3,
         code_change/4]).
-export([init/3,
         connection/3,
         async_wait/3,
         handshake/3,
         death_row/3]).
%% Tracing
-export([handle_trace/3]).

-record(env,
        {connection_pid,
         role,
         socket,
         socket_opts_tab,
         transport_cb,
         negotiated_version,
         renegotiate_at,
         key_update_at,  %% TLS 1.3
         dist_handle,
         log_level,
         hibernate_after,
         keylog_fun,
         num_key_updates = 0
        }).

-record(data,
        {
         env = #env{},
         connection_states = #{},
         bytes_sent,     %% TLS 1.3
         buff = undefined %% Async socket
        }).

-record(async,
        {
         size  = 0,
         sent  = 0,    %% Windows only, sent and buffered data
         q_rev = [],   %% Q of remaining Encrypted data
         reply_to = undefined,
         high  = undefined,
         low   = undefined
        }).

-define(IS_ASYNC(Tag), Tag =:= select; Tag =:= completion).

%%%===================================================================
%%% API
%%%===================================================================
%%--------------------------------------------------------------------
-spec start_link() -> {ok, Pid :: pid()} |
                 ignore |
                 {error, Error :: term()}.
-spec start_link(list()) -> {ok, Pid :: pid()} |
                       ignore |
                       {error, Error :: term()}.

%%  Description: Start sender process to avoid dead lock that 
%%  may happen when a socket is busy (busy port) and the
%%  same process is sending and receiving 
%%--------------------------------------------------------------------
start_link() ->
    gen_statem:start_link(?MODULE, [], []).
start_link(SpawnOpts) ->
    gen_statem:start_link(?MODULE, [], SpawnOpts).

%%--------------------------------------------------------------------
-spec initialize(pid(), map()) -> ok. 
%%  Description: So TLS connection process can initialize it sender
%% process.
%%--------------------------------------------------------------------
initialize(Pid, InitMsg) ->
    gen_statem:call(Pid, {self(), InitMsg}).

%%--------------------------------------------------------------------
-spec send_data(pid(), iodata()) -> ok | {error, term()}.
%%  Description: Send application data
%%--------------------------------------------------------------------
send_data(Pid, AppData) ->
    %% Needs error handling for external API
    call(Pid, {application_data, AppData}).

%%--------------------------------------------------------------------
-spec send_post_handshake(pid(), #key_update{}) -> ok | {error, term()}.
%%  Description: Send post handshake data
%%--------------------------------------------------------------------
send_post_handshake(Pid, HandshakeData) ->
    call(Pid, {post_handshake_data, HandshakeData}).

%%--------------------------------------------------------------------
-spec send_alert(pid(), #alert{}) -> _. 
%% Description: TLS connection process wants to send an Alert
%% in the connection state.
%%--------------------------------------------------------------------
send_alert(Pid, Alert) ->
    gen_statem:cast(Pid, Alert).

%%--------------------------------------------------------------------
-spec send_and_ack_alert(pid(), #alert{}) -> _.
%% Description: TLS connection process wants to send an Alert
%% in the connection state and receive an ack.
%%--------------------------------------------------------------------
send_and_ack_alert(Pid, Alert) ->
    gen_statem:call(Pid, {ack_alert, Alert}, ?DEFAULT_TIMEOUT).

%%--------------------------------------------------------------------
-spec renegotiate(pid()) -> {ok, WriteState::map()} | {error, closed}.
%% Description: So TLS connection process can synchronize the 
%% encryption state to be used when handshaking.
%%--------------------------------------------------------------------
renegotiate(Pid) ->
    %% Needs error handling for external API
    call(Pid, renegotiate).

%%--------------------------------------------------------------------
-spec peer_renegotiate(pid()) -> {ok, WriteState::map()} | {error, term()}.
%% Description: So TLS connection process can synchronize the 
%% encryption state to be used when handshaking.
%%--------------------------------------------------------------------
peer_renegotiate(Pid) ->
     gen_statem:call(Pid, renegotiate, ?DEFAULT_TIMEOUT).

%%--------------------------------------------------------------------
-spec update_connection_state(pid(), WriteState::map(), tls_record:tls_version()) -> ok. 
%% Description: So TLS connection process can synchronize the 
%% encryption state to be used when sending application data. 
%%--------------------------------------------------------------------
update_connection_state(Pid, NewState, Version) ->
    gen_statem:cast(Pid, {new_write, NewState, Version}).

%%--------------------------------------------------------------------
-spec downgrade(pid(), integer()) -> {ok, ssl_record:connection_state()}
                                         | {error, timeout}.
%% Description: So TLS connection process can synchronize the 
%% encryption state to be used when sending application data. 
%%--------------------------------------------------------------------
downgrade(Pid, Timeout) ->
    try gen_statem:call(Pid, downgrade, Timeout) of
        Result ->
            Result    
    catch
        _:_ ->
            {error, timeout}
    end.
%%--------------------------------------------------------------------
-spec dist_handshake_complete(pid(), node(), term()) -> ok. 
%%  Description: Erlang distribution callback 
%%--------------------------------------------------------------------
dist_handshake_complete(ConnectionPid, Node, DHandle) ->
    gen_statem:call(ConnectionPid, {dist_handshake_complete, Node, DHandle}).

%%%===================================================================
%%% gen_statem callbacks
%%%===================================================================
%%--------------------------------------------------------------------
-spec callback_mode() -> gen_statem:callback_mode_result().
%%--------------------------------------------------------------------
callback_mode() -> 
    state_functions.

%%--------------------------------------------------------------------
-spec init(Args :: term()) ->
                  gen_statem:init_result(atom()).
%%--------------------------------------------------------------------
init(_) ->
    %% As this process is now correctly supervised
    %% together with the connection process and the significant
    %% child mechanism we want to handle supervisor shutdown
    %% to achieve a normal shutdown avoiding SASL reports.
    process_flag(trap_exit, true),
    {ok, init, #data{}}.

%%--------------------------------------------------------------------
-spec init(gen_statem:event_type(),
           Msg :: term(),
           StateData :: term()) ->
                  gen_statem:event_handler_result(atom()).
%%--------------------------------------------------------------------
init({call, From}, {Pid, #{current_write := WriteState,
                           beast_mitigation := BeastMitigation,
                           role := Role,
                           socket := Socket,
                           socket_opts_tab := SockOpts,
                           erl_dist := IsErlDist,
                           transport_cb := Transport,
                           negotiated_version := Version,
                           renegotiate_at := RenegotiateAt,
                           key_update_at := KeyUpdateAt,
                           log_level := LogLevel,
                           hibernate_after := HibernateAfter,
                           keylog_fun := Fun}},
     #data{connection_states = ConnectionStates0, env = Env0} = StateData0) ->
    ConnectionStates = case BeastMitigation of
                           disabled ->
                               ConnectionStates0#{current_write => WriteState};
                           _ ->
                               ConnectionStates0#{current_write => WriteState,
                                                  beast_mitigation => BeastMitigation}
                       end,
    StateData =
        StateData0#data{connection_states = ConnectionStates,
                        bytes_sent = 0,
                        env = Env0#env{connection_pid = Pid,
                                       role = Role,
                                       socket = Socket,
                                       socket_opts_tab = SockOpts,
                                       dist_handle = IsErlDist,
                                       transport_cb = Transport,
                                       negotiated_version = Version,
                                       renegotiate_at = RenegotiateAt,
                                       key_update_at = KeyUpdateAt,
                                       log_level = LogLevel,
                                       hibernate_after = HibernateAfter,
                                       keylog_fun = Fun}},
    proc_lib:set_label({tls_sender, Role, {connection, Pid}}),
    put(log_level, LogLevel),
    put(tls_role, Role),
    {next_state, handshake, StateData, [{reply, From, ok}]};
init(info = Type, Msg, StateData) ->
    handle_common(init, Type, Msg, StateData);
init(_, _, _) ->
    %% Just in case anything else sneaks through
    {keep_state_and_data, [postpone]}.

%%--------------------------------------------------------------------
-spec connection(gen_statem:event_type(),
           Msg :: term(),
           StateData :: term()) ->
                  gen_statem:event_handler_result(atom()).
%%--------------------------------------------------------------------
connection({call, From}, {application_data, Data}, StateData) ->
    send_application_data(Data, From, connection, StateData);
connection({call, From}, {post_handshake_data, HSData}, #data{buff = Buff} = StateData) ->
    case Buff of
        undefined ->
            send_post_handshake_data(HSData, From, connection, StateData);
        Async ->
            {next_state, async_wait, StateData#data{buff = Async#async{low = 0}}, [postpone]}
    end;
connection({call, From}, {ack_alert, #alert{} = Alert}, #data{buff = Buff} = StateData0) ->
    case Buff of
        undefined ->
            StateData = send_tls_alert(Alert, StateData0),
            {next_state, connection, StateData, [{reply,From,ok}]};
        Async ->
            {next_state, async_wait, StateData0#data{buff = Async#async{low = 0}}, [postpone]}
    end;
connection({call, From}, renegotiate,
           #data{connection_states = #{current_write := Write}, buff = Buff} = StateData) ->
    case Buff of
        undefined ->
            {next_state, handshake, StateData, [{reply, From, {ok, Write}}]};
        Async ->
            {next_state, async_wait, StateData#data{buff = Async#async{low = 0}}, [postpone]}
    end;
connection({call, From}, downgrade, #data{connection_states =
                                              #{current_write := Write}} = StateData) ->
    {next_state, death_row, StateData, [{reply,From, {ok, Write}}]};
connection({call, From}, {dist_handshake_complete, _Node, DHandle},
           #data{env = #env{connection_pid = Pid} = Env} = StateData0) ->
    false = erlang:dist_ctrl_set_opt(DHandle, get_size, true),
    ok = erlang:dist_ctrl_input_handler(DHandle, Pid),
    ok = ssl_gen_statem:dist_handshake_complete(Pid, DHandle),
    %% From now on we execute on normal priority
    process_flag(priority, normal),
    StateData = StateData0#data{env = Env#env{dist_handle = DHandle}},
    case dist_data(DHandle) of
        [] ->
            hibernate_after(connection, StateData, [{reply,From,ok}]);
        Data ->
            {keep_state, StateData,
             [{reply,From,ok}, {next_event, internal, {application_packets, dist_data, Data}}]}
    end;

connection(internal, {application_packets, From, Data}, StateData) ->
    send_application_data(Data, From, connection, StateData);
connection(internal, {post_handshake_data, From, HSData}, #data{buff = Buff} = StateData) ->
     case Buff of
         undefined ->
             send_post_handshake_data(HSData, From, connection, StateData);
         Async ->
             {next_state, async_wait, StateData#data{buff = Async#async{low = 0}}, [postpone]}
     end;

connection(cast, #alert{} = Alert,  #data{buff = Buff} = StateData0) ->
     case Buff of
         undefined ->
             StateData = send_tls_alert(Alert, StateData0),
             {next_state, connection, StateData};
         Async ->
             {next_state, async_wait, StateData0#data{buff = Async#async{low = 0}}, [postpone]}
     end;
connection(cast, {new_write, WritesState, Version},
           #data{connection_states = ConnectionStates, env = Env} = StateData) ->
    CW = maps:remove(aead_handle, WritesState),
    hibernate_after(connection,
                    StateData#data{connection_states = ConnectionStates#{current_write => CW},
                                   env = Env#env{negotiated_version = Version}}, []);
%%
connection(info, dist_data,
           #data{env = #env{dist_handle = DHandle}} = StateData) ->
      case dist_data(DHandle) of
          [] -> hibernate_after(connection, StateData, []);
          Data -> send_application_data(Data, dist_data, connection, StateData)
      end;
connection(info, {'$socket', Socket, select, Handle},
           #data{env = #env{transport_cb = Transport}} = StateData) ->
    do_async_send(Transport, Socket, Handle, connection, ok, StateData);
connection(info, {'$socket', Socket, completion, {Handle, Status}},
           #data{env = #env{transport_cb = Transport}} = StateData) ->
    do_async_send(Transport, Socket, Handle, connection, Status, StateData);
connection(info, tick, #data{buff = Buff} = StateData) ->
    %% Send distribution tick, if nothing is in the queue
    consume_ticks(),
    case Buff of
        undefined ->
            Data = [<<0:32>>], % encode_packet(4, <<>>)
            From = {self(), undefined},
            send_application_data(Data, From, connection, StateData);
        _ -> %% No need to send tick, have outgoing data in buffer
            {keep_state_and_data, []}
    end;
connection(info, {send, From, Ref, Data}, _StateData) -> 
    %% This is for testing only!
    %%
    %% Needed by some OTP distribution
    %% test suites...
    From ! {Ref, ok},
    {keep_state_and_data,
     [{next_event, {call, {self(), undefined}},
       {application_data, erlang:iolist_to_iovec(Data)}}]};
connection(timeout, hibernate, _StateData) ->
    {keep_state_and_data, [hibernate]};
connection(Type, Msg, StateData) ->
    handle_common(connection, Type, Msg, StateData).

async_wait(info, {'$socket', Socket, select, Handle},
           #data{env = #env{transport_cb = Transport}} = StateData) ->
    do_async_send(Transport, Socket, Handle, connection, ok, StateData);
async_wait(info, {'$socket', Socket, completion, {Handle, Status}},
           #data{env = #env{transport_cb = Transport}} = StateData) ->
    do_async_send(Transport, Socket, Handle, connection, Status, StateData);
async_wait(info, tick, _StateData) ->
    consume_ticks(),
    %% No need to send tick, have outgoing data in buffer
    {keep_state_and_data, []};
async_wait(Type, {'EXIT', _, _} = Msg, StateData) ->
    handle_common(?FUNCTION_NAME, Type, Msg, StateData);
async_wait(_T, _Msg, _) ->
    {keep_state_and_data, [postpone]}.

%%--------------------------------------------------------------------
-spec handshake(gen_statem:event_type(),
                  Msg :: term(),
                  StateData :: term()) ->
                         gen_statem:event_handler_result(atom()).
%%--------------------------------------------------------------------
handshake({call, _}, _, _) ->
    %% Postpone all calls to the connection state
    {keep_state_and_data, [postpone]};
handshake(internal, {application_packets,_,_}, _) ->
    {keep_state_and_data, [postpone]};
handshake(cast, {new_write, WriteState0, Version},
          #data{connection_states = ConnectionStates0,
                env = #env{key_update_at = KeyUpdateAt0,
                                 role = Role,
                                 num_key_updates = N,
                                 keylog_fun = Fun} = Env} = StateData) ->
    WriteState = maps:remove(aead_handle, WriteState0),
    ConnectionStates = ConnectionStates0#{current_write => WriteState},
    KeyUpdateAt = key_update_at(Version, WriteState, KeyUpdateAt0),
    case Version of
        ?TLS_1_3 ->
            maybe_traffic_keylog_1_3(Fun, Role, ConnectionStates, N);
        _ ->
            ok
    end,
    {next_state, connection,
     StateData#data{connection_states = ConnectionStates,
                    env = Env#env{negotiated_version = Version,
                                           key_update_at = KeyUpdateAt}}};
handshake(info, dist_data, _) ->
    {keep_state_and_data, [postpone]};
handshake(info, tick, _) ->
    %% Ignore - data is sent anyway during handshake
    consume_ticks(),
    keep_state_and_data;
handshake(info, {send, _, _, _}, _) ->
    %% Testing only, OTP distribution test suites...
    {keep_state_and_data, [postpone]};
handshake(Type, Msg, StateData) ->
    handle_common(handshake, Type, Msg, StateData).

%%--------------------------------------------------------------------
-spec death_row(gen_statem:event_type(),
                Msg :: term(),
                StateData :: term()) ->
                       gen_statem:event_handler_result(atom()).
%%--------------------------------------------------------------------
death_row(state_timeout, Reason, _StateData) ->
    {stop, {shutdown, Reason}};
death_row(info, {'$socket', Socket, select, Handle},
          #data{env = #env{transport_cb = Transport}} = StateData) ->
    do_async_send(Transport, Socket, Handle, death_row, ok, StateData);
death_row(info, {'$socket', Socket, completion, {Handle, Status}},
          #data{env = #env{transport_cb = Transport}} = StateData) ->
    do_async_send(Transport, Socket, Handle, death_row, Status, StateData);

death_row(info = Type, Msg, StateData) ->
    handle_common(death_row, Type, Msg, StateData);
death_row(_Type, _Msg, _StateData) ->
    %% Waste all other events
    keep_state_and_data.

%% State entry function that starts shutdown state_timeout if
%% distribution otherwise shuts down the sender
death_row_shutdown(Reason, #data{env = #env{dist_handle = false}} = StateData) ->
    {stop, {shutdown, Reason}, StateData};
death_row_shutdown(Reason, StateData) ->
    {next_state, death_row, StateData, [{state_timeout, 5000, Reason}]}.

%%--------------------------------------------------------------------
-spec terminate(Reason :: term(), State :: term(), Data :: term()) ->
                       any().
%%--------------------------------------------------------------------
terminate(_Reason, _State, _Data) ->
    void.

%%--------------------------------------------------------------------
-spec code_change(
        OldVsn :: term() | {down,term()},
        State :: term(), Data :: term(), Extra :: term()) ->
                         {ok, NewState :: term(), NewData :: term()} |
                         (Reason :: term()).
%% Convert process state when code is changed
%%--------------------------------------------------------------------
code_change(_OldVsn, State, Data, _Extra) ->
    {ok, State, Data}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
handle_common(StateName, {call, From}, get_application_traffic_secret,
              #data{env = #env{num_key_updates = N}} = Data) ->
    CurrentWrite = maps:get(current_write, Data#data.connection_states),
    SecurityParams = maps:get(security_parameters, CurrentWrite),
    ApplicationTrafficSecret = SecurityParams#security_parameters.application_traffic_secret,
    hibernate_after(StateName, Data, [{reply, From, {ok, ApplicationTrafficSecret, N}}]);

handle_common(_StateName, info, {'EXIT', _Sup, Reason},
              #data{env = #env{dist_handle = DistHandle}} = StateData)
  when DistHandle =/= undefined ->
    case Reason of
        shutdown ->
            %% When the connection is on its way down operations
            %% begin to fail. We wait to receive possible exit signals
            %% for one of our links to the other involved distribution parties,
            %% in which case we want to use their exit reason
            %% for the connection teardown.
            death_row_shutdown(Reason, StateData);
        _ ->
            {stop, {shutdown, Reason}, StateData}
    end;
handle_common(_StateName, info, {'EXIT', _Sup, shutdown}, StateData) ->
    {stop, shutdown, StateData};
handle_common(_StateName, info, {'$socket', _, abort, Reason}, StateData) ->
    ?SSL_LOG(info, "TLS sender received socket error", [{message, Reason}]),
    {stop, shutdown, StateData};
handle_common(StateName, info, Msg, StateData) ->
    ?SSL_LOG(info, "TLS sender received unexpected info", [{message, Msg}]),
    hibernate_after(StateName, StateData, []);
handle_common(StateName, Type, Msg, StateData) ->
    ?SSL_LOG(error, "TLS sender received unexpected event",
             [{type, Type}, {message, Msg}]),
    hibernate_after(StateName, StateData, []).

send_tls_alert(#alert{} = Alert,
               #data{env = #env{negotiated_version = Version,
                                      socket = Socket,
                                      transport_cb = Transport},
                     connection_states = ConnectionStates0} = StateData0) ->
    {BinMsg, ConnectionStates} =
	tls_record:encode_alert_record(Alert, Version, ConnectionStates0),
    tls_socket:send(Transport, Socket, BinMsg),
    ssl_logger:debug(get(log_level), outbound, 'record', BinMsg),
    StateData0#data{connection_states = ConnectionStates}.

send_application_data(Data, From, StateName,
                      #data{env = #env{socket = Socket,
                                       negotiated_version = Version,
                                       transport_cb = Transport} = Opts,
                            bytes_sent = BytesSent0,
                            connection_states = ConnStates0} = StateData0) ->
    DataSz = iolist_size(Data),
    case time_to_rekey(Version, DataSz, BytesSent0, ConnStates0, Opts) of
        {true, KeyUpdateAt} ->
            KeyUpdate = tls_handshake_1_3:key_update(update_requested),
            case DataSz > KeyUpdateAt of
                false ->
                    {keep_state_and_data, [{next_event, internal, {post_handshake_data, From, KeyUpdate}},
                                           {next_event, internal, {application_packets, From, Data}}]};
                true ->
                    %% Prevent infinite loop of key updates
                    {Chunk, Rest} = split_binary(iolist_to_binary(Data), KeyUpdateAt),
                    {keep_state_and_data, [{next_event, internal, {post_handshake_data, From, KeyUpdate}},
                                           {next_event, internal, {application_packets, From, [Chunk]}},
                                           {next_event, internal, {application_packets, From, [Rest]}}]}
            end;
	{renegotiate, _} ->
            #env{connection_pid = Pid} = Opts,
	    tls_dtls_gen_connection:internal_renegotiation(Pid, ConnStates0),
            {next_state, handshake, StateData0,
             [{next_event, internal, {application_packets, From, Data}}]};
	{false, BytesSent} ->
	    {Msgs, ConnStates} = tls_record:encode_data(Data, Version, ConnStates0),
            case send_or_buffer(Transport, Socket, Msgs, From,
                                StateData0#data{bytes_sent = BytesSent,
                                                connection_states = ConnStates})
            of
                {ok, StateData} ->
                    hibernate_after(StateName, StateData, []);
                {block, StateData} ->
                    hibernate_after(async_wait, StateData, []);
                {error, _} = Error ->
                    death_row_shutdown(Error, StateData0#data{connection_states = ConnStates})
            end
    end.

%% Nothing buffered, send Msgs
send_or_buffer(Transport, Socket, Msgs, From, #data{buff = undefined} = StateData0) ->
    case tls_socket:send(Transport, Socket, Msgs, nowait) of
        ok ->
            send_reply(From, ok),
            {ok, StateData0};
        {error, _Err} = Error ->
            send_reply(From, Error),
            Error;
        {Tag, {_SelectInfo, RestData}} when ?IS_ASYNC(Tag) ->
            BuffSz = iolist_size(RestData),
            #async{high = High} = Async0 = new_async(StateData0),
            Sent = sent_data(Tag, BuffSz),
            Async = Async0#async{q_rev = [RestData], size = BuffSz, sent = Sent},
            case BuffSz < High of
                true ->
                    send_reply(From, ok),
                    {ok, StateData0#data{buff = Async}};
                false ->
                    {block, StateData0#data{buff = Async#async{reply_to = From}}}
            end;
        {Tag, _SelInfo} when ?IS_ASYNC(Tag) ->
            BuffSz = iolist_size(Msgs),
            #async{high = High} = Async0 = new_async(StateData0),
            Sent = sent_data(Tag, BuffSz),
            Async = Async0#async{q_rev = [Msgs], size = BuffSz, sent = Sent},
            case BuffSz < High of
                true ->
                    send_reply(From, ok),
                    {ok, StateData0#data{buff = Async}};
                false ->
                    {block, StateData0#data{buff = Async#async{reply_to = From}}}
            end
    end;
%% Buffer exists, push more data to buffer
send_or_buffer(_Transport, _Socket, Msgs, From, #data{buff = Async0} = StateData) ->
    #async{high = High, size = Sz0, q_rev = Q} = Async0,
    Sz = Sz0 + iolist_size(Msgs),
    Async = Async0#async{size = Sz, q_rev = [Msgs|Q]},
    case Sz < High of
        true ->
            send_reply(From, ok),
            {ok, StateData#data{buff = Async}};
        false ->
            {block, StateData#data{buff = Async#async{reply_to = From}}}
    end.

do_async_send(_Transport, _Socket, _Handle, _Nextstate, {error, Err} = Error,
              #data{buff = #async{reply_to = From}} = StateData) ->
    send_reply(From, Error),
    log_error(Err),
    death_row_shutdown(Error, StateData#data{buff = undefined});
do_async_send(Transport, Socket, Handle, Nextstate, Result,
              #data{buff = #async{reply_to = From} = Async0} = StateData) ->
    MsgQ = prepare_iovec(Result, Async0),
    case tls_socket:send(Transport, Socket, MsgQ, Handle) of
        ok ->
            send_reply(From, ok),
            {next_state, Nextstate, StateData#data{buff = undefined}};
        {error, Err} = Error ->
            send_reply(From, Error),
            log_error(Err),
            death_row_shutdown(Error, StateData#data{buff = undefined});
        {Tag, {_SelectInfo, RestData}} when ?IS_ASYNC(Tag) ->
            Sz = iolist_size(RestData),
            Sent  = sent_data(Tag, Sz),
            Async = Async0#async{size = Sz, q_rev = [RestData], sent = Sent},
            case Sz < Async#async.low of
                true ->
                    send_reply(From, ok),
                    {next_state, Nextstate, StateData#data{buff = Async#async{reply_to = undefined}}};
                false ->
                    {keep_state, StateData#data{buff = Async}}
            end;
        {select, _SelectInfo} ->
            {keep_state_and_data, []};
        {completion, _} ->
            BuffSz = iolist_size(MsgQ),
            #async{high = High} = Async1 = new_async(StateData),
            Sent  = sent_data(completion, BuffSz),
            Async = Async1#async{q_rev = [MsgQ], size = BuffSz, sent = Sent},
            case BuffSz < High of
                true ->
                    send_reply(From, ok),
                    {next_state, Nextstate, StateData#data{buff = Async}};
                false ->
                    {keep_state, StateData#data{buff = Async#async{reply_to = From}}}
            end
    end.

send_reply(dist_data, _Msg) -> ok;
send_reply(undefined, _Msg) -> ok;
send_reply(From, Msg) -> gen_statem:reply(From, Msg).

sent_data(completion, Sz) -> Sz;
sent_data(_, _) -> 0.

prepare_iovec(ok, #async{q_rev = RevMsgQ, sent = 0}) ->
    lists:reverse(RevMsgQ);
prepare_iovec(ok, #async{q_rev = RevMsgQ, sent = Written}) ->
    strip_bytes(Written, lists:reverse(RevMsgQ));
prepare_iovec({ok, Written}, #async{q_rev = RevMsgQ}) when is_integer(Written) ->
    %% Windows, Strip Written bytes
    strip_bytes(Written, lists:reverse(RevMsgQ)).

strip_bytes(0, RevMsQ) ->
    RevMsQ;
strip_bytes(N, [Bin|Rest]) when is_binary(Bin) ->
    Sz = byte_size(Bin),
    case N < Sz of
        true ->
            <<_:N/binary, Remain/binary>> = Bin,
            [Remain|Rest];
        false ->
            strip_bytes(N-Sz, Rest)
    end;
strip_bytes(N, [Deep|Rest]) when is_list(Deep) ->
    Sz = iolist_size(Deep),
    case N < Sz of
        true ->
            [strip_bytes(N, Deep)|Rest];
        false ->
            strip_bytes(N-Sz, Rest)
    end;
strip_bytes(_, []) ->
    [].

new_async(#data{env = #env{socket_opts_tab = Tab}}) ->
    Read = fun(Key, Def) ->
                   try ets:lookup_element(Tab, Key, 2)
                   catch _:_ -> Def
                   end
           end,
    #async{high = Read(high_watermark, 8192), low = Read(low_watermark, 4096)}.

log_error(Atom) when is_atom(Atom) ->
    ?SSL_LOG(notice, "ssl send socket error", Atom);
log_error({invalid, _} = Reason) ->
    ?SSL_LOG(notice, "ssl send socket error", Reason);
log_error({Reason, _Bytes}) ->
    ?SSL_LOG(notice, "ssl send socket error", Reason).

%% TLS 1.3 Post Handshake Data
send_post_handshake_data(Handshake, From, StateName,
                         #data{env = #env{socket = Socket,
                                          negotiated_version = Version,
                                          transport_cb = Transport},
                               connection_states = ConnStates0} = StateData0) ->
    BinHandshake = tls_handshake:encode_handshake(Handshake, Version),
    {Encoded, ConnStates} =
        tls_record:encode_handshake(BinHandshake, Version, ConnStates0),
    LogLevel = get(log_level),
    ssl_logger:debug(LogLevel, outbound, 'handshake', Handshake),
    StateData1 = StateData0#data{connection_states = ConnStates},
    case tls_socket:send(Transport, Socket, Encoded) of
        ok when From == dist_data ->
            ssl_logger:debug(LogLevel, outbound, 'record', Encoded),
            StateData = maybe_update_cipher_key(StateData1, Handshake),
            {next_state, StateName, StateData, []};
        ok ->
            ssl_logger:debug(LogLevel, outbound, 'record', Encoded),
            StateData = maybe_update_cipher_key(StateData1, Handshake),
            {next_state, StateName, StateData,  [{reply, From, ok}]};
        {error, Reason} ->
            death_row_shutdown(Reason, StateData1)
    end.

maybe_update_cipher_key(#data{connection_states = ConnectionStates0,
                              env = #env{role = Role,
                                         num_key_updates = N,
                                         keylog_fun = Fun} = Env
                             } = StateData, #key_update{}) ->
    ConnectionStates = tls_gen_connection_1_3:update_cipher_key(current_write, ConnectionStates0),
    maybe_traffic_keylog_1_3(Fun, Role, ConnectionStates, N + 1),
    StateData#data{connection_states = ConnectionStates,
                   env = Env#env{num_key_updates = N + 1},
                   bytes_sent = 0};
maybe_update_cipher_key(StateData, _) ->
    StateData.

maybe_traffic_keylog_1_3(Fun, Role, ConnectionStates, N) when is_function(Fun) ->
    #{security_parameters :=
          #security_parameters{
             client_random = ClientRandom,
             prf_algorithm = Prf,
             application_traffic_secret = TrafficSecret}}
        = ssl_record:current_connection_state(ConnectionStates, write),
    KeyLog =  ssl_logger:keylog_traffic_1_3(Role, ClientRandom, Prf, TrafficSecret, N),
    ssl_logger:keylog(KeyLog, ClientRandom, Fun);
maybe_traffic_keylog_1_3(_,_,_,_) ->
    ok.

%% For AES-GCM, up to 2^24.5 full-size records (about 24 million) may be
%% encrypted on a given connection while keeping a safety margin of
%% approximately 2^-57 for Authenticated Encryption (AE) security.  For
%% ChaCha20/Poly1305, the record sequence number would wrap before the
%% safety limit is reached.
key_update_at(?TLS_1_3, #{security_parameters :=
                             #security_parameters{
                                bulk_cipher_algorithm = ?CHACHA20_POLY1305}}, _KeyUpdateAt) ->
    seq_num_wrap;
key_update_at(?TLS_1_3, _, KeyUpdateAt) ->
    KeyUpdateAt;
key_update_at(_, _, KeyUpdateAt) ->
    KeyUpdateAt.

time_to_rekey(Version, _DataSz, _BytesSent, CS, #env{key_update_at = seq_num_wrap})
  when ?TLS_GTE(Version, ?TLS_1_3) ->
    #{current_write := #{sequence_number := Seq}} = CS,
    {Seq >= ?MAX_SEQUENCE_NUMBER, 0};
time_to_rekey(Version, DataSize, BytesSent0, _, #env{key_update_at = KeyUpdateAt})
  when ?TLS_GTE(Version, ?TLS_1_3) ->
    BytesSent = BytesSent0 + DataSize,
    case BytesSent > KeyUpdateAt of
        true ->
            {true, KeyUpdateAt};
        false ->
            {false, BytesSent}
    end;
time_to_rekey(_, DataSz, BytesSent, CS, #env{renegotiate_at = Max}) ->
    #{current_write := #{sequence_number := Seq}} = CS,
    %% We could do test:
    %% is_time_to_renegotiate((erlang:byte_size(_Data) div
    %% ?MAX_PLAIN_TEXT_LENGTH) + 1, RenegotiateAt), but we chose to
    %% have a some what lower renegotiateAt and a much cheaper test
    case Seq >= Max of
        true  -> {renegotiate, 0};
        false -> {false, DataSz+BytesSent}
    end.

call(FsmPid, Event) ->
    try gen_statem:call(FsmPid, Event)
    catch
 	exit:{noproc, _} ->
 	    {error, closed};
	exit:{normal, _} ->
	    {error, closed};
	exit:{shutdown,_} ->
	    {error, closed};
        exit:{{shutdown, _},_} ->
	    {error, closed}
    end.

%%-------------- Erlang distribution helpers ------------------------------

%% To avoid livelock, dist_data/2 will check for more bytes coming from
%%  distribution channel, if amount of already collected bytes greater
%%  or equal than the limit defined below.
-define(TLS_BUNDLE_SOFT_LIMIT, (16 * 1024 * 1024)).

dist_data(DHandle) ->
    dist_data(DHandle, 0).

dist_data(DHandle, CurBytes) ->
    case erlang:dist_ctrl_get_data(DHandle) of
        none ->
            erlang:dist_ctrl_get_data_notification(DHandle),
            [];
        %% This is encode_packet(4, Data) without Len check
        %% since the emulator will always deliver a Data
        %% smaller than 4 GB, and the distribution will
        %% therefore always have to use {packet,4}
        {Len, Data} when Len + CurBytes >= ?TLS_BUNDLE_SOFT_LIMIT ->
            %% Data is of type iovec(); lets keep it
            %% as an iovec()...
            erlang:dist_ctrl_get_data_notification(DHandle),
            [<<Len:32>> | Data];
        {Len, Data} ->
            Packet = [<<Len:32>> | Data],
            case dist_data(DHandle, CurBytes + Len) of
                [] -> Packet;
                More -> Packet ++ More
            end
    end.


%% Empty the inbox from distribution ticks - do not let them accumulate
consume_ticks() ->
    receive tick ->
            consume_ticks()
    after 0 ->
            ok
    end.

hibernate_after(connection = StateName,
		#data{env=#env{hibernate_after = HibernateAfter}} = State,
		Actions) when HibernateAfter =/= infinity ->
    {next_state, StateName, State, [{timeout, HibernateAfter, hibernate} | Actions]};
hibernate_after(StateName, State, []) ->
    {next_state, StateName, State};
hibernate_after(StateName, State, Actions) ->
    {next_state, StateName, State, Actions}.

%%%################################################################
%%%#
%%%# Tracing
%%%#
handle_trace(kdt,
             {call, {?MODULE, time_to_rekey,
                     [_Version, DataSize, BytesSent, Map, #env{key_update_at = KeyUpdateAt}]}},
             Stack) ->
    #{current_write := #{sequence_number := Sn}} = Map,
    {io_lib:format("~w) (BytesSent:~w + DataSize:~w) > KeyUpdateAt:~w",
                   [Sn, BytesSent, DataSize, KeyUpdateAt]), Stack};
handle_trace(kdt,
             {call, {?MODULE, send_post_handshake_data,
                     [{key_update, update_requested}|_]}}, Stack) ->
    {io_lib:format("KeyUpdate procedure 1/4 - update_requested sent", []), Stack};
handle_trace(kdt,
             {call, {?MODULE, send_post_handshake_data,
                     [{key_update, update_not_requested}|_]}}, Stack) ->
    {io_lib:format("KeyUpdate procedure 3/4 - update_not_requested sent", []), Stack};
handle_trace(hbn,
             {call, {?MODULE, connection,
                     [timeout, hibernate | _]}}, Stack) ->
    {io_lib:format("* * * hibernating * * *", []), Stack};
handle_trace(hbn,
                 {call, {?MODULE, hibernate_after,
                         [_StateName = connection, State, Actions]}},
             Stack) ->
    #data{env=#env{hibernate_after = HibernateAfter}} = State,
    {io_lib:format("* * * maybe hibernating in ~w ms * * * Actions = ~W ",
                   [HibernateAfter, Actions, 10]), Stack};
handle_trace(hbn,
                 {return_from, {?MODULE, hibernate_after, 3},
                  {Cmd, Arg,_State, Actions}},
             Stack) ->
    {io_lib:format("Cmd = ~w Arg = ~w Actions = ~W", [Cmd, Arg, Actions, 10]), Stack};
handle_trace(rle,
                 {call, {?MODULE, init, [Type, Opts, _StateData]}}, Stack0) ->
    {Pid, #{role := Role,
            socket := _Socket,
            key_update_at := KeyUpdateAt,
            erl_dist := IsErlDist,
            trackers := Trackers,
            negotiated_version := _Version}} = Opts,
    {io_lib:format("(*~w) Type = ~w Pid = ~w Trackers = ~w Dist = ~w KeyUpdateAt = ~w",
                   [Role, Type, Pid, Trackers, IsErlDist, KeyUpdateAt]),
     [{role, Role} | Stack0]}.
