%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2019-2021. All Rights Reserved.
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

%%
-module(ssl_api_SUITE).

-behaviour(ct_suite).

-include_lib("common_test/include/ct.hrl").
-include_lib("ssl/src/ssl_api.hrl").

%% Common test
-export([all/0,
         groups/0,
         init_per_suite/1,
         init_per_group/2,
         init_per_testcase/2,
         end_per_suite/1,
         end_per_group/2,
         end_per_testcase/2
        ]).

%% Test cases
-export([conf_signature_algs/0,
         conf_signature_algs/1,
         no_common_signature_algs/0,
         no_common_signature_algs/1,
         default_reject_anonymous/0,
         default_reject_anonymous/1,
         connection_information_with_srp/0,
         connection_information_with_srp/1,
         peercert/0,
         peercert/1,
         peercert_with_client_cert/0,
         peercert_with_client_cert/1,
         connection_information/0,
         connection_information/1,
         secret_connection_info/0,
         secret_connection_info/1,
         keylog_connection_info/0,
         keylog_connection_info/1,
         versions/0,
         versions/1,
         versions_option_based_on_sni/0,
         versions_option_based_on_sni/1,
         active_n/0,
         active_n/1,
         dh_params/0,
         dh_params/1,
         prf/0,
         prf/1,
         hibernate/0,
         hibernate/1,
         hibernate_right_away/0,
         hibernate_right_away/1,
         listen_socket/0,
         listen_socket/1,
         peername/0,
         peername/1,
         recv_active/0,
         recv_active/1,
         recv_active_once/0,
         recv_active_once/1,
         recv_active_n/0,
         recv_active_n/1,
         recv_no_active_msg/0,
         recv_no_active_msg/1,
         recv_timeout/0,
         recv_timeout/1,
         recv_close/0,
         recv_close/1,
         controlling_process/0,
         controlling_process/1,
         controller_dies/0,
         controller_dies/1,
         controlling_process_transport_accept_socket/0,
         controlling_process_transport_accept_socket/1,
         close_with_timeout/0,
         close_with_timeout/1,
         close_in_error_state/0,
         close_in_error_state/1,
         call_in_error_state/0,
         call_in_error_state/1,
         close_transport_accept/0,
         close_transport_accept/1,
         abuse_transport_accept_socket/0,
         abuse_transport_accept_socket/1,
         honor_server_cipher_order/0,
         honor_server_cipher_order/1,
         honor_client_cipher_order/0,
         honor_client_cipher_order/1,
         honor_client_cipher_order_tls13/0,
         honor_client_cipher_order_tls13/1,
         honor_server_cipher_order_tls13/0,
         honor_server_cipher_order_tls13/1,
         ipv6/0,
         ipv6/1,
         der_input/0,
         der_input/1,
         new_options_in_handshake/0,
         new_options_in_handshake/1,
         max_handshake_size/0,
         max_handshake_size/1,
         invalid_certfile/0,
         invalid_certfile/1,
         invalid_cacertfile/0,
         invalid_cacertfile/1,
         invalid_keyfile/0,
         invalid_keyfile/1,
         options_not_proplist/0,
         options_not_proplist/1,
         invalid_options/0,
         invalid_options/1,
         cb_info/0,
         cb_info/1,
         log_alert/0,
         log_alert/1,
         getstat/0,
         getstat/1,
         handshake_continue/0,
         handshake_continue/1,
         handshake_continue_timeout/0,
         handshake_continue_timeout/1,
         handshake_continue_change_verify/0,
         handshake_continue_change_verify/1,
         hello_client_cancel/0,
         hello_client_cancel/1,
         hello_server_cancel/0,
         hello_server_cancel/1,
         handshake_continue_tls13_client/0,
         handshake_continue_tls13_client/1,
         rizzo_disabled/0,
         rizzo_disabled/1,
         rizzo_zero_n/0,
         rizzo_zero_n/1,
         rizzo_one_n_minus_one/0,
         rizzo_one_n_minus_one/1,
         supported_groups/0,
         supported_groups/1,
         client_options_negative_version_gap/0,
         client_options_negative_version_gap/1,
         client_options_negative_dependency_version/0,
         client_options_negative_dependency_version/1,
         client_options_negative_dependency_stateless/0,
         client_options_negative_dependency_stateless/1,
         client_options_negative_dependency_role/0,
         client_options_negative_dependency_role/1,
         client_options_negative_early_data/0,
         client_options_negative_early_data/1,
         server_options_negative_early_data/0,
         server_options_negative_early_data/1,
         server_options_negative_version_gap/0,
         server_options_negative_version_gap/1,
         server_options_negative_dependency_role/0,
         server_options_negative_dependency_role/1,
         invalid_options_tls13/0,
         invalid_options_tls13/1,
         cookie/0,
         cookie/1,
	 warn_verify_none/0,
	 warn_verify_none/1,
	 suppress_warn_verify_none/0,
         suppress_warn_verify_none/1,
         check_random_nonce/0,
         check_random_nonce/1,
         cipher_listing/0,
         cipher_listing/1
        ]).

%% Apply export
-export([connection_information_result/1,
         connection_info_result/1,
         secret_connection_info_result/1,
         keylog_connection_info_result/2,
         check_srp_in_connection_information/3,
         check_connection_info/2,
         prf_verify_value/4,
         try_recv_active/1,
         try_recv_active_once/1,
         controlling_process_result/3,
         controller_dies_result/3,
         send_recv_result_timeout_client/1,
         send_recv_result_timeout_server/1,
         do_recv_close/1,
         tls_close/1,
         no_recv_no_active/1,
         ssl_getstat/1,
	 log/2,
         get_connection_information/3,
         protocol_version_check/2,
         %%TODO Keep?
         run_error_server/1,
         run_error_server_close/1,
         run_client_error/1
        ]).


-define(SLEEP, 500).
%%--------------------------------------------------------------------
%% Common Test interface functions -----------------------------------
%%--------------------------------------------------------------------

all() ->
    [
     {group, 'tlsv1.3'},
     {group, 'tlsv1.2'},
     {group, 'tlsv1.1'},
     {group, 'tlsv1'},
     {group, 'dtlsv1.2'},
     {group, 'dtlsv1'}
    ].

groups() ->
    [
     {'tlsv1.3', [], ((gen_api_tests() ++ tls13_group() ++
                           handshake_paus_tests()) --
                          [dh_params,
                           honor_server_cipher_order,
                           honor_client_cipher_order,
                           new_options_in_handshake,
                           handshake_continue_tls13_client,
                           invalid_options])
      ++ (since_1_2() -- [conf_signature_algs])},
     {'tlsv1.2', [],  gen_api_tests() ++ since_1_2() ++ handshake_paus_tests() ++ pre_1_3()},
     {'tlsv1.1', [],  gen_api_tests() ++ handshake_paus_tests() ++ pre_1_3()},
     {'tlsv1', [],  gen_api_tests() ++ handshake_paus_tests() ++ pre_1_3() ++ beast_mitigation_test()},
     {'dtlsv1.2', [], (gen_api_tests() --
                           [invalid_keyfile, invalid_certfile, invalid_cacertfile,
                            invalid_options, new_options_in_handshake])  ++
          handshake_paus_tests() -- [handshake_continue_tls13_client] ++ pre_1_3()},
     {'dtlsv1', [],  (gen_api_tests() --
                          [invalid_keyfile, invalid_certfile, invalid_cacertfile,
                           invalid_options, new_options_in_handshake]) ++
          handshake_paus_tests() -- [handshake_continue_tls13_client] ++ pre_1_3()}
    ].

since_1_2() ->
    [
     conf_signature_algs,
     no_common_signature_algs,
     versions_option_based_on_sni
    ].

pre_1_3() ->
    [
     default_reject_anonymous,
     connection_information_with_srp,
     prf
    ].

gen_api_tests() ->
    [
     peercert,
     peercert_with_client_cert,
     connection_information,
     secret_connection_info,
     keylog_connection_info,
     versions,
     active_n,
     dh_params,
     hibernate,
     hibernate_right_away,
     listen_socket,
     peername,
     recv_active,
     recv_active_once,
     recv_active_n,
     recv_no_active_msg,
     recv_timeout,
     recv_close,
     controlling_process,
     controller_dies,
     controlling_process_transport_accept_socket,
     close_with_timeout,
     close_in_error_state,
     call_in_error_state,
     close_transport_accept,
     abuse_transport_accept_socket,
     honor_server_cipher_order,
     honor_client_cipher_order,
     ipv6,
     der_input,
     new_options_in_handshake,
     max_handshake_size,
     invalid_certfile,
     invalid_cacertfile,
     invalid_keyfile,
     options_not_proplist,
     invalid_options,
     cb_info,
     log_alert,
     getstat,
     warn_verify_none,
     suppress_warn_verify_none,
     check_random_nonce,
     cipher_listing
    ].

handshake_paus_tests() ->
    [
     handshake_continue, 
     handshake_continue_timeout,
     handshake_continue_change_verify,
     hello_client_cancel,
     hello_server_cancel,
     handshake_continue_tls13_client
    ].

%% Only relevant for SSL 3.0 and TLS 1.0
beast_mitigation_test() ->
    [%% Original option
     rizzo_disabled,
     %% Same effect as disable
     rizzo_zero_n, 
     %% Same as default
     rizzo_one_n_minus_one 
    ].

tls13_group() ->
    [
     supported_groups,
     honor_server_cipher_order_tls13,
     honor_client_cipher_order_tls13,
     client_options_negative_version_gap,
     client_options_negative_dependency_version,
     client_options_negative_dependency_stateless,
     client_options_negative_dependency_role,
     client_options_negative_early_data,
     server_options_negative_early_data,
     server_options_negative_version_gap,
     server_options_negative_dependency_role,
     invalid_options_tls13,
     cookie
    ].

init_per_suite(Config0) ->
    catch crypto:stop(),
    try crypto:start() of
	ok ->
	    ssl_test_lib:clean_start(),
	    ssl_test_lib:make_rsa_cert(Config0)
    catch _:_ ->
	    {skip, "Crypto did not start"}
    end.

end_per_suite(_Config) ->
    ssl:stop(),
    application:unload(ssl),
    application:stop(crypto).

init_per_group(GroupName, Config) ->
    case ssl_test_lib:is_protocol_version(GroupName) of
        true  ->
            ssl_test_lib:init_per_group(GroupName, 
                                        [{client_type, erlang},
                                         {server_type, erlang},
                                         {version, GroupName}
                                        | Config]);
        false -> 
            Config
    end.

end_per_group(GroupName, Config) ->
    ssl_test_lib:end_per_group(GroupName, Config).

init_per_testcase(prf, Config) ->
    ssl_test_lib:ct_log_supported_protocol_versions(Config),
    ct:timetrap({seconds, 10}),
    Version = ssl_test_lib:protocol_version(Config),
    PRFS = [md5, sha, sha256, sha384, sha512],
    %% All are the result of running tls_v1:prf(PrfAlgo, <<>>, <<>>, <<>>, 16)
    %% with the specified PRF algorithm
    ExpectedPrfResults =
        [{md5, <<96,139,180,171,236,210,13,10,28,32,2,23,88,224,235,199>>},
         {sha, <<95,3,183,114,33,169,197,187,231,243,19,242,220,228,70,151>>},
         {sha256, <<166,249,145,171,43,95,158,232,6,60,17,90,183,180,0,155>>},
         {sha384, <<153,182,217,96,186,130,105,85,65,103,123,247,146,91,47,106>>},
         {sha512, <<145,8,98,38,243,96,42,94,163,33,53,49,241,4,127,28>>},
         %% TLS 1.0 and 1.1 PRF:
         {md5sha, <<63,136,3,217,205,123,200,177,251,211,17,229,132,4,173,80>>}],
    TestPlan = prf_create_plan(Version, PRFS, ExpectedPrfResults),
    [{prf_test_plan, TestPlan} | Config];
init_per_testcase(handshake_continue_tls13_client, Config) ->
    case ssl_test_lib:sufficient_crypto_support('tlsv1.3') of
        true ->
            ssl_test_lib:ct_log_supported_protocol_versions(Config),
            ct:timetrap({seconds, 10}),
            Config;
        false ->
            {skip, "Missing crypto support: TLS 1.3 not supported"}
    end;
init_per_testcase(connection_information_with_srp, Config) ->
    PKAlg = proplists:get_value(public_keys, crypto:supports()),
    case lists:member(srp, PKAlg) of
        true ->
            Config;
        false ->
            {skip, "Missing SRP crypto support"}
    end;
init_per_testcase(conf_signature_algs, Config) ->
    case ssl_test_lib:appropriate_sha(crypto:supports()) of
        sha256 ->
            ssl_test_lib:ct_log_supported_protocol_versions(Config),
            ct:timetrap({seconds, 10}),
            Config;
        sha ->
            {skip, "Tests needs certs with sha256"}
    end;
init_per_testcase(check_random_nonce, Config) ->
    ssl_test_lib:ct_log_supported_protocol_versions(Config),
    ct:timetrap({seconds, 20}),
    Config;
init_per_testcase(_TestCase, Config) ->
    ssl_test_lib:ct_log_supported_protocol_versions(Config),
    ct:timetrap({seconds, 10}),
    Config.

end_per_testcase(internal_active_n, _Config) ->
    application:unset_env(ssl, internal_active_n);
end_per_testcase(_TestCase, Config) ->     
    Config.

%%--------------------------------------------------------------------
%% Test Cases --------------------------------------------------------
%%--------------------------------------------------------------------
peercert() ->
    [{doc,"Test API function peercert/1"}].
peercert(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server = ssl_test_lib:start_server([{node, ClientNode}, {port, 0},
					{from, self()},
			   {mfa, {ssl, peercert, []}},
			   {options, ServerOpts}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ServerNode}, {port, Port},
					{host, Hostname},
			   {from, self()},
			   {mfa, {ssl, peercert, []}},
			   {options, ClientOpts}]),

    CertFile = proplists:get_value(certfile, ServerOpts),
    [{'Certificate', BinCert, _}]= ssl_test_lib:pem_to_der(CertFile),

    ServerMsg = {error, no_peercert},
    ClientMsg = {ok, BinCert},

    ct:log("Testcase ~p, Client ~p  Server ~p ~n",
		       [self(), Client, Server]),

    ssl_test_lib:check_result(Server, ServerMsg, Client, ClientMsg),

    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%--------------------------------------------------------------------

peercert_with_client_cert() ->
    [{doc,"Test API function peercert/1"}].
peercert_with_client_cert(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server = ssl_test_lib:start_server([{node, ClientNode}, {port, 0},
					{from, self()},
			   {mfa, {ssl, peercert, []}},
			   {options, [{verify, verify_peer} | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ServerNode}, {port, Port},
					{host, Hostname},
			   {from, self()},
			   {mfa, {ssl, peercert, []}},
			   {options, ClientOpts}]),

    ServerCertFile = proplists:get_value(certfile, ServerOpts),
    [{'Certificate', ServerBinCert, _}]= ssl_test_lib:pem_to_der(ServerCertFile),
     ClientCertFile = proplists:get_value(certfile, ClientOpts),
    [{'Certificate', ClientBinCert, _}]= ssl_test_lib:pem_to_der(ClientCertFile),

    ServerMsg = {ok, ClientBinCert},
    ClientMsg = {ok, ServerBinCert},

    ct:log("Testcase ~p, Client ~p  Server ~p ~n",
		       [self(), Client, Server]),

    ssl_test_lib:check_result(Server, ServerMsg, Client, ClientMsg),

    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%--------------------------------------------------------------------
connection_information() ->
    [{doc,"Test the API function ssl:connection_information/1"}].
connection_information(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0}, 
					{from, self()}, 
					{mfa, {?MODULE, connection_information_result, []}},
					{options, ServerOpts}]),
    
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
					{host, Hostname},
			   {from, self()}, 
			   {mfa, {?MODULE, connection_information_result, []}},
			   {options, ClientOpts}]),
    
    ct:log("Testcase ~p, Client ~p  Server ~p ~n",
		       [self(), Client, Server]),
    			   
    ssl_test_lib:check_result(Server, ok, Client, ok),
    
    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%--------------------------------------------------------------------
connection_information_with_srp() ->
    [{doc,"Test the result of API function ssl:connection_information/1"
          "includes srp_username."}].
connection_information_with_srp(Config) when is_list(Config) ->
    run_conn_info_srp_test(srp_anon, 'aes_128_cbc', Config).

run_conn_info_srp_test(Kex, Cipher, Config) ->
    Version = ssl_test_lib:protocol_version(Config),
    TestCiphers = ssl_test_lib:test_ciphers(Kex, Cipher, Version),

    case TestCiphers of
        [] ->
            {skip, {not_sup, Kex, Cipher, Version}};
        [TestCipher | _T] ->
            do_run_conn_info_srp_test(TestCipher, Version, Config)
    end.

do_run_conn_info_srp_test(ErlangCipherSuite, Version, Config) ->
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    SOpts = [{user_lookup_fun, {fun ssl_test_lib:user_lookup/3, undefined}}],
    COpts = [{srp_identity, {"Test-User", "secret"}}],

    ServerOpts = ssl_test_lib:ssl_options(SOpts, Config),
    ClientOpts = ssl_test_lib:ssl_options(COpts, Config),

    ct:log("Erlang Cipher Suite is: ~p~n", [ErlangCipherSuite]),

    Server =
        ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
                                   {from, self()},
                                   {mfa, {?MODULE, check_srp_in_connection_information, [<<"Test-User">>, server]}},
                                   {options, [{versions, [Version]}, {ciphers, [ErlangCipherSuite]} |
                                              ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client =
        ssl_test_lib:start_client(
          [{node, ClientNode}, {port, Port},
           {host, Hostname},
           {from, self()},
           {mfa, {?MODULE, check_srp_in_connection_information, [<<"Test-User">>, client]}},
           {options, [{versions, [Version]}, {ciphers, [ErlangCipherSuite]} |
                      ClientOpts]}]),

    ssl_test_lib:check_result(Server, ok, Client, ok),

    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%--------------------------------------------------------------------

secret_connection_info() ->
    [{doc,"Test the API function ssl:connection_information/2"}].
secret_connection_info(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server =
        ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
                                   {from, self()},
                                   {mfa, {?MODULE, secret_connection_info_result, []}},
                                   {options, [{verify, verify_peer} | ServerOpts]}]),
    
    Port = ssl_test_lib:inet_port(Server),
    Client =
        ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
                                   {host, Hostname},
                                   {from, self()},
                                   {mfa, {?MODULE, secret_connection_info_result, []}},
                                   {options,  [{verify, verify_peer} |ClientOpts]}]),
    
    ct:log("Testcase ~p, Client ~p  Server ~p ~n",
		       [self(), Client, Server]),
			   
    ssl_test_lib:check_result(Server, true, Client, true),
    
    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).
%%--------------------------------------------------------------------
keylog_connection_info() ->
    [{doc,"Test the API function ssl:connection_information/2"}].
keylog_connection_info(Config) when is_list(Config) ->
    keylog_connection_info(Config, true),
    keylog_connection_info(Config, false).
keylog_connection_info(Config, KeepSecrets) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server =
        ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
                                   {from, self()},
                                   {mfa, {?MODULE, keylog_connection_info_result, [KeepSecrets]}},
                                   {options, [{verify, verify_peer}, {keep_secrets, KeepSecrets} | ServerOpts]}]),

    Port = ssl_test_lib:inet_port(Server),
    Client =
        ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
                                   {host, Hostname},
                                   {from, self()},
                                   {mfa, {?MODULE, keylog_connection_info_result, [KeepSecrets]}},
                                   {options,  [{verify, verify_peer}, {keep_secrets, KeepSecrets} |ClientOpts]}]),

    ct:log("Testcase ~p, KeepSecrets ~p Client ~p  Server ~p ~n",
		       [self(), KeepSecrets, Client, Server]),

    ServerKeylog = receive
                       {Server, {ok, Keylog}} ->
                           Keylog;
                       {Server, ServerError} ->
                           ct:fail({server, ServerError})
                   after 5000 ->
                           ct:fail({server, timeout})
                   end,

    receive
        {Client, {ok, ServerKeylog}} ->
            ok;
        {Client, {ok, ClientKeylog}} ->
            ct:fail({mismatch, {ServerKeylog, ClientKeylog}});
        {Client, ClientError} ->
            ct:fail({client, ClientError})
    after 5000 ->
            ct:fail({client, timeout})
    end,

    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%--------------------------------------------------------------------
prf() ->
    [{doc,"Test that ssl:prf/5 uses the negotiated PRF."}].
prf(Config) when is_list(Config) ->
    Version = ssl_test_lib:protocol_version(Config),
    TestPlan = proplists:get_value(prf_test_plan, Config),
    lists:foreach(fun(Test) ->
                          C = proplists:get_value(ciphers, Test),
                          E = proplists:get_value(expected, Test),
                          P = proplists:get_value(prf, Test),
                          prf_run_test(Config, Version, C, E, P)
                  end, TestPlan).

%%--------------------------------------------------------------------
dh_params() ->
    [{doc,"Test to specify DH-params file in server."}].

dh_params(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    DataDir = proplists:get_value(data_dir, Config),
    DHParamFile = filename:join(DataDir, "dHParam.pem"),

    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    
    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0}, 
					{from, self()}, 
			   {mfa, {ssl_test_lib, send_recv_result_active, []}},
			   {options, [{dhfile, DHParamFile} | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port}, 
					{host, Hostname},
			   {from, self()}, 
			   {mfa, {ssl_test_lib, send_recv_result_active, []}},
			   {options,
			    [{ciphers,[{dhe_rsa,aes_256_cbc,sha}]} | 
				       ClientOpts]}]),
    
    ssl_test_lib:check_result(Server, ok, Client, ok),
    
    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%--------------------------------------------------------------------
conf_signature_algs() ->
    [{doc,"Test to set the signature_algs option on both client and server"}].
conf_signature_algs(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    Server = 
	ssl_test_lib:start_server([{node, ServerNode}, {port, 0}, 
				   {from, self()}, 
				   {mfa, {ssl_test_lib, send_recv_result, []}},
				   {options,  [{active, false}, {signature_algs, [{sha256, rsa}]}, 
                                               {versions, ['tlsv1.2']} | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = 
	ssl_test_lib:start_client([{node, ClientNode}, {port, Port}, 
				   {host, Hostname},
				   {from, self()}, 
				   {mfa, {ssl_test_lib, send_recv_result, []}},
				   {options, [{active, false}, {signature_algs, [{sha256, rsa}]},
                                              {versions, ['tlsv1.2']} | ClientOpts]}]),
    
    ct:log("Testcase ~p, Client ~p  Server ~p ~n",
			 [self(), Client, Server]),
    
    ssl_test_lib:check_result(Server, ok, Client, ok),
    
    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).


%%--------------------------------------------------------------------
no_common_signature_algs()  ->
    [{doc,"Set the signature_algs option so that there client and server does not share any hash sign algorithms"}].
no_common_signature_algs(Config) when is_list(Config) ->
    
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),

    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),


    Server = ssl_test_lib:start_server_error([{node, ServerNode}, {port, 0},
					      {from, self()},
					      {options, [{signature_algs, [{sha256, rsa}]}
							 | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client_error([{node, ClientNode}, {port, Port},
                                              {host, Hostname},
                                              {from, self()},
                                              {options, [{signature_algs, [{sha384, rsa}]}
                                                         | ClientOpts]}]),
    
    ssl_test_lib:check_server_alert(Server, Client, insufficient_security).

%%--------------------------------------------------------------------
handshake_continue() ->
    [{doc, "Test API function ssl:handshake_continue/3"}].
handshake_continue(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server =
        ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
                                   {from, self()},
                                   {mfa, {ssl_test_lib, send_recv_result_active, []}},
                                   {options, ssl_test_lib:ssl_options([{reuseaddr, true},
                                                                       {log_level, debug},
                                                                            {verify, verify_peer},
                                                                       {handshake, hello} | ServerOpts
                                                                      ],
                                                                      Config)},
                                   {continue_options, proplists:delete(reuseaddr, ServerOpts)}
                                  ]),
    
    Port = ssl_test_lib:inet_port(Server),

    Client =
        ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
                                   {host, Hostname},
                                   {from, self()},
                                   {mfa, {ssl_test_lib, send_recv_result_active, []}},
                                   {options, ssl_test_lib:ssl_options([{handshake, hello},
                                                                       {verify, verify_peer} | ClientOpts
                                                                      ],
                                                                      Config)},
                                   {continue_options,  proplists:delete(reuseaddr, ClientOpts)}]),
     
    ssl_test_lib:check_result(Server, ok, Client, ok),
    
    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%--------------------------------------------------------------------
handshake_continue_tls13_client() ->
    [{doc, "Test API function ssl:handshake_continue/3 with fixed TLS 1.3 client"}].
handshake_continue_tls13_client(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    SCiphers = ssl:filter_cipher_suites(ssl:cipher_suites(all, 'tlsv1.3'),
                                        [{key_exchange, fun(srp_rsa)  -> false;
                                                           (srp_anon) -> false;
                                                           (srp_dss) -> false;
                                                           (_) -> true end}]),
    Server =
        ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
                                   {from, self()},
                                   {mfa, {ssl_test_lib, send_recv_result_active, []}},
                                   {options, ssl_test_lib:ssl_options([{reuseaddr, true},
                                                                       {log_level, debug},
                                                                       {verify, verify_peer},
                                                                       {ciphers, SCiphers},
                                                                      {handshake, hello} | ServerOpts
                                                                      ],
                                                                     Config)},
                                   {continue_options, proplists:delete(reuseaddr, ServerOpts)}
                                  ]),

    Port = ssl_test_lib:inet_port(Server),

    DummyTicket =
        <<131,116,0,0,0,5,100,0,4,104,107,100,102,100,0,6,115,104,97,51,
          56,52,100,0,3,112,115,107,109,0,0,0,48,150,90,38,127,26,12,5,
          228,180,235,229,214,215,27,236,149,182,82,14,140,50,81,0,150,
          248,152,180,193,207,80,52,107,196,200,2,77,4,96,140,65,239,205,
          224,125,129,179,147,103,100,0,3,115,110,105,107,0,25,112,114,
          111,117,100,102,111,111,116,46,111,116,112,46,101,114,105,99,
          115,115,111,110,46,115,101,100,0,6,116,105,99,107,101,116,104,6,
          100,0,18,110,101,119,95,115,101,115,115,105,111,110,95,116,105,
          99,107,101,116,98,0,0,28,32,98,127,110,83,249,109,0,0,0,8,0,0,0,
          0,0,0,0,5,109,0,0,0,113,112,154,74,26,27,0,111,147,51,110,216,
          43,45,4,100,215,152,195,118,96,22,34,1,184,170,42,166,238,109,
          187,138,196,147,102,205,116,83,241,174,227,232,156,148,60,153,3,
          175,128,115,192,36,103,191,239,58,222,192,172,190,239,92,8,131,
          195,0,217,187,222,143,104,6,86,53,93,27,218,198,205,138,223,202,
          11,55,168,104,6,219,228,217,157,37,52,205,252,165,135,167,116,
          216,172,231,222,189,84,97,0,8,106,108,88,47,114,48,116,0,0,0,0,
          100,0,9,116,105,109,101,115,116,97,109,112,98,93,205,0,44>>,

    %% Send dummy session ticket to trigger sending of pre_shared_key and
    %% psk_key_exchange_modes extensions.
    Client =
        ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
                                   {host, Hostname},
                                   {from, self()},
                                   {mfa, {ssl_test_lib, send_recv_result_active, []}},
                                   {options, ssl_test_lib:ssl_options([{handshake, hello},
                                                                       {session_tickets, manual},
                                                                       {use_ticket, [DummyTicket]},
                                                                       {versions, ['tlsv1.3',
                                                                                   'tlsv1.2',
                                                                                   'tlsv1.1',
                                                                                   'tlsv1'
                                                                                  ]},
                                                                       {ciphers, ssl:cipher_suites(all, 'tlsv1.3')},
                                                                       {verify, verify_peer} | ClientOpts
                                                                      ],
                                                                      Config)},
                                   {continue_options,  proplists:delete(reuseaddr, ClientOpts)}]),

    ssl_test_lib:check_result(Server, ok, Client, ok),

    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%------------------------------------------------------------------
handshake_continue_timeout() ->
    [{doc, "Test API function ssl:handshake_continue/3 with short timeout"}].
handshake_continue_timeout(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
                                        {from, self()},
                                        {timeout, 1},
                                        {options, ssl_test_lib:ssl_options([{reuseaddr, true}, {handshake, hello},
                                                                            {verify, verify_peer} | ServerOpts],
                                                                           Config)},
                                        {continue_options, proplists:delete(reuseaddr, ServerOpts)}
                                       ]),

    Port = ssl_test_lib:inet_port(Server),


    ssl_test_lib:start_client_error([{node, ClientNode}, {port, Port},
                                     {host, Hostname},
                                     {from, self()},
                                     {options, [{verify, verify_peer} | ClientOpts]}]),
    
    ssl_test_lib:check_result(Server, {error,timeout}),
    ssl_test_lib:close(Server).

handshake_continue_change_verify() ->
    [{doc, "Test API function ssl:handshake_continue with updated verify option. "
      "Use a verification that will fail to make sure verification is run"}].
handshake_continue_change_verify(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server = ssl_test_lib:start_server(
               [{node, ServerNode}, {port, 0},
                {from, self()},
                {options, ssl_test_lib:ssl_options(
                            [{handshake, hello},
                             {verify, verify_peer} | ServerOpts], Config)},
                {continue_options, proplists:delete(reuseaddr, ServerOpts)}]),

    Port = ssl_test_lib:inet_port(Server),

    Client = ssl_test_lib:start_client_error(
               [{node, ClientNode}, {port, Port},
                {host, Hostname},
                {from, self()},
                {options, ssl_test_lib:ssl_options(
                            [{handshake, hello},
                             {server_name_indication, "foobar"}
                            | ClientOpts], Config)},
                {continue_options, [{verify, verify_peer} | ClientOpts]}]),
    ssl_test_lib:check_client_alert(Client,  handshake_failure).

%%--------------------------------------------------------------------
hello_client_cancel() ->
    [{doc, "Test API function ssl:handshake_cancel/1 on the client side"}].
hello_client_cancel(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server =
        ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
                                   {from, self()},
                                   {options, ssl_test_lib:ssl_options([{handshake, hello},
                                                                       {verify, verify_peer} | ServerOpts], Config)},
                                   {continue_options, proplists:delete(reuseaddr, ServerOpts)}]),
    
    Port = ssl_test_lib:inet_port(Server),

    %% That is ssl:handshake_cancel returns ok
    {connect_failed, ok} =
        ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
                                   {host, Hostname},
                                   {from, self()},
                                   {options, ssl_test_lib:ssl_options([{handshake, hello},
                                                                       {verify, verify_peer} | ClientOpts], Config)},
                                   {continue_options, cancel}]),
    ssl_test_lib:check_server_alert(Server, user_canceled).
%%--------------------------------------------------------------------
hello_server_cancel() ->
    [{doc, "Test API function ssl:handshake_cancel/1 on the server side"}].
hello_server_cancel(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server =
        ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
                                   {from, self()},
                                   {options, ssl_test_lib:ssl_options([{handshake, hello},
                                                                       {verify, verify_peer} | ServerOpts
                                                                      ], Config)},
                                   {continue_options, cancel}]),
    
    Port = ssl_test_lib:inet_port(Server),

    ssl_test_lib:start_client_error([{node, ClientNode}, {port, Port},
                                     {host, Hostname},
                                     {from, self()}, 
                                     {options, ssl_test_lib:ssl_options([{handshake, hello},
                                                                         {verify, verify_peer} | ClientOpts
                                                                        ], Config)},
                                     {continue_options, proplists:delete(reuseaddr, ClientOpts)}]),
    
    ssl_test_lib:check_result(Server, ok).

%%--------------------------------------------------------------------
versions() ->
    [{doc,"Test API function versions/0"}].

versions(Config) when is_list(Config) -> 
    [_|_] = Versions = ssl:versions(),
    ct:log("~p~n", [Versions]).

%%--------------------------------------------------------------------

versions_option_based_on_sni() ->
    [{doc,"Test that SNI versions option is selected over default versions"}].

versions_option_based_on_sni(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    TestVersion = ssl_test_lib:protocol_version(Config),
    {Version, Versions} = test_versions_for_option_based_on_sni(TestVersion),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    SNI = net_adm:localhost(),
    Fun = fun(ServerName) ->
              case ServerName of
                  SNI ->
                      [{versions, [Version]} | ServerOpts];
                  _ ->
                      ServerOpts
              end
          end,

    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
					{from, self()},
					{mfa, {?MODULE, protocol_version_check, [Version]}},
					{options, [{sni_fun, Fun},
                                                   {versions, Versions} | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
					{host, Hostname},
					{from, self()},
					{mfa, {ssl_test_lib, no_result, []}},
					{options, [{server_name_indication, SNI}, {versions, Versions} | ClientOpts]}]),

    ssl_test_lib:check_result(Server, ok),
    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%--------------------------------------------------------------------
%% Test case adapted from gen_tcp_misc_SUITE.
active_n() ->
    [{doc,"Test {active,N} option"}].

active_n(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    Port = ssl_test_lib:inet_port(node()),
    N = 3,
    LS = ok(ssl:listen(Port, [{active,N}|ServerOpts])),
    [{active,N}] = ok(ssl:getopts(LS, [active])),
    active_n_common(LS, N),
    Self = self(),
    spawn_link(fun() ->
        S0 = ok(ssl:transport_accept(LS)),
        {ok, S} = ssl:handshake(S0),
        ok = ssl:setopts(S, [{active,N}]),
        [{active,N}] = ok(ssl:getopts(S, [active])),
        ssl:controlling_process(S, Self),
        Self ! {server, S}
    end),
    C = ok(ssl:connect("localhost", Port, [{active,N}|ClientOpts])),
    [{active,N}] = ok(ssl:getopts(C, [active])),
    S = receive
        {server, S0} -> S0
    after
        1000 ->
            exit({error, connect})
    end,
    active_n_common(C, N),
    active_n_common(S, N),
    ok = ssl:setopts(C, [{active,N}]),
    ok = ssl:setopts(S, [{active,N}]),
    ReceiveMsg = fun(Socket, Msg) ->
        receive
            {ssl,Socket,Msg} ->
                ok;
            {ssl,Socket,Begin} ->
                receive
                    {ssl,Socket,End} ->
                        Msg = Begin ++ End,
                        ok
                after 1000 ->
                    exit(timeout)
                end
        after 1000 ->
            exit(timeout)
        end
    end,
    repeat(3, fun(I) ->
        Msg = "message "++integer_to_list(I),
        ok = ssl:send(C, Msg),
        ReceiveMsg(S, Msg),
        ok = ssl:send(S, Msg),
        ReceiveMsg(C, Msg)
    end),
    receive
        {ssl_passive,S} ->
            [{active,false}] = ok(ssl:getopts(S, [active]))
    after
        1000 ->
            exit({error,ssl_passive})
    end,
    receive
        {ssl_passive,C} ->
            [{active,false}] = ok(ssl:getopts(C, [active]))
    after
        1000 ->
            exit({error,ssl_passive})
    end,
    LS2 = ok(ssl:listen(0, [{active,0}])),
    receive
        {ssl_passive,LS2} ->
            [{active,false}] = ok(ssl:getopts(LS2, [active]))
    after
        1000 ->
            exit({error,ssl_passive})
    end,
    ok = ssl:close(LS2),
    ok = ssl:close(C),
    ok = ssl:close(S),
    ok = ssl:close(LS),
    ok.

hibernate() ->
    [{doc,"Check that an SSL connection that is started with option "
      "{hibernate_after, 1000} indeed hibernates after 1000ms of "
      "inactivity"}].

hibernate(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),

    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
					{from, self()},
					{mfa, {ssl_test_lib, send_recv_result_active, []}},
					{options, ServerOpts}]),
    Port = ssl_test_lib:inet_port(Server),
    {Client, #sslsocket{pid=[Pid|_]}} = ssl_test_lib:start_client([return_socket,
                    {node, ClientNode}, {port, Port},
					{host, Hostname},
					{from, self()},
					{mfa, {ssl_test_lib, send_recv_result_active, []}},
					{options, [{hibernate_after, 1000}|ClientOpts]}]),
    {current_function, _} =
        process_info(Pid, current_function),

    ssl_test_lib:check_result(Server, ok, Client, ok),
    
    ct:sleep(1500),
    {current_function, {erlang, hibernate, 3}} =
	process_info(Pid, current_function),
    
    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%--------------------------------------------------------------------

hibernate_right_away() ->
    [{doc,"Check that an SSL connection that is configured to hibernate "
    "after 0 or 1 milliseconds hibernates as soon as possible and not "
    "crashes"}].

hibernate_right_away(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),

    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    StartServerOpts = [{node, ServerNode}, {port, 0},
                    {from, self()},
                    {mfa, {ssl_test_lib, send_recv_result_active, []}},
                    {options, ServerOpts}],
    StartClientOpts = [return_socket,
                    {node, ClientNode},
                    {host, Hostname},
                    {from, self()},
                    {mfa, {ssl_test_lib, send_recv_result_active, []}}],

    Server1 = ssl_test_lib:start_server(StartServerOpts),
    Port1 = ssl_test_lib:inet_port(Server1),
    {Client1, #sslsocket{pid = [Pid1|_]}} = ssl_test_lib:start_client(StartClientOpts ++
                    [{port, Port1}, {options, [{hibernate_after, 0}|ClientOpts]}]),

    ssl_test_lib:check_result(Server1, ok, Client1, ok),
    
    ct:sleep(1000), %% Schedule out
  
     {current_function, {erlang, hibernate, 3}} =
	process_info(Pid1, current_function),
    ssl_test_lib:close(Server1),
    ssl_test_lib:close(Client1),
    
    Server2 = ssl_test_lib:start_server(StartServerOpts),
    Port2 = ssl_test_lib:inet_port(Server2),
    {Client2, #sslsocket{pid = [Pid2|_]}} = ssl_test_lib:start_client(StartClientOpts ++
                    [{port, Port2}, {options, [{hibernate_after, 1}|ClientOpts]}]),

    ssl_test_lib:check_result(Server2, ok, Client2, ok),

    ct:sleep(1000), %% Schedule out
    
    {current_function, {erlang, hibernate, 3}} =
	process_info(Pid2, current_function),

    ssl_test_lib:close(Server2),
    ssl_test_lib:close(Client2).

listen_socket() ->
    [{doc,"Check error handling and inet compliance when calling API functions with listen sockets."}].

listen_socket(Config) ->
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ok, ListenSocket} = ssl:listen(0, ServerOpts),

    %% This can be a valid thing to do as
    %% options are inherited by the accept socket
    ok = ssl:controlling_process(ListenSocket, self()),

    {ok, _} = ssl:sockname(ListenSocket),

    {error, enotconn} = ssl:send(ListenSocket, <<"data">>),
    {error, enotconn} = ssl:recv(ListenSocket, 0),
    {error, enotconn} = ssl:connection_information(ListenSocket),
    {error, enotconn} = ssl:peername(ListenSocket),
    {error, enotconn} = ssl:peercert(ListenSocket),
    {error, enotconn} = ssl:renegotiate(ListenSocket),
    {error, enotconn} = ssl:prf(ListenSocket, 'master_secret', <<"Label">>, [client_random], 256),
    {error, enotconn} = ssl:shutdown(ListenSocket, read_write),

    ok = ssl:close(ListenSocket).

%%--------------------------------------------------------------------
peername() ->
    [{doc,"Test API function peername/1"}].

peername(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server = ssl_test_lib:start_server(
               [
                {node, ServerNode}, {port, 0},
                {from, self()},
                {options, ServerOpts}]),
    Port = ssl_test_lib:inet_port(Server),
    {Client, CSocket} = ssl_test_lib:start_client(
                          [return_socket,
                           {node, ClientNode}, {port, Port},
                           {host, Hostname},
                           {from, self()},
                           {options, ClientOpts}]),

    ct:log("Testcase ~p, Client ~p  Server ~p ~n",
           [self(), Client, Server]),

    Server ! get_socket,
    SSocket =
        receive
            {Server, {socket, Socket}} ->
                Socket
        end,

    {ok, ServerPeer} = ssl:peername(SSocket),
    ct:log("Server's peer: ~p~n", [ServerPeer]),
    {ok, ClientPeer} = ssl:peername(CSocket),
    ct:log("Client's peer: ~p~n", [ClientPeer]),

    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%--------------------------------------------------------------------

recv_active() ->
    [{doc,"Test recv on active socket"}].

recv_active(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    Server = 
	ssl_test_lib:start_server([{node, ServerNode}, {port, 0}, 
				   {from, self()}, 
				   {mfa, {?MODULE, try_recv_active, []}},
				   {options,  [{active, true} | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = 
	ssl_test_lib:start_client([{node, ClientNode}, {port, Port}, 
				   {host, Hostname},
				   {from, self()}, 
				   {mfa, {?MODULE, try_recv_active, []}},
				   {options, [{active, true} | ClientOpts]}]),
        
    ssl_test_lib:check_result(Server, ok, Client, ok),
    
    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%--------------------------------------------------------------------
recv_active_once() ->
    [{doc,"Test recv on active (once) socket"}].

recv_active_once(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    Server = 
	ssl_test_lib:start_server([{node, ServerNode}, {port, 0}, 
				   {from, self()}, 
				   {mfa, {?MODULE, try_recv_active_once, []}},
				   {options,  [{active, once} | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = 
	ssl_test_lib:start_client([{node, ClientNode}, {port, Port}, 
				   {host, Hostname},
				   {from, self()}, 
				   {mfa, {?MODULE, try_recv_active_once, []}},
				   {options, [{active, once} | ClientOpts]}]),
        
    ssl_test_lib:check_result(Server, ok, Client, ok),
    
    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%--------------------------------------------------------------------
recv_active_n() ->
    [{doc,"Test recv on active (n) socket"}].

recv_active_n(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    Server =
	ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
				   {from, self()},
				   {mfa, {?MODULE, try_recv_active_once, []}},
				   {options,  [{active, 1} | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client =
	ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
				   {host, Hostname},
				   {from, self()},
				   {mfa, {?MODULE, try_recv_active_once, []}},
				   {options, [{active, 1} | ClientOpts]}]),

    ssl_test_lib:check_result(Server, ok, Client, ok),

    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).
%%--------------------------------------------------------------------
recv_timeout() ->
    [{doc,"Test ssl:recv timeout"}].

recv_timeout(Config) ->
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),

    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server =
	ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
				   {from, self()},
				   {mfa, {?MODULE, send_recv_result_timeout_server, []}},
				   {options, [{active, false} | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),

    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
					{host, Hostname},
					{from, self()},
					{mfa, {?MODULE,
					       send_recv_result_timeout_client, []}},
					{options, [{active, false} | ClientOpts]}]),

    ssl_test_lib:check_result(Client, ok, Server, ok),
    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%--------------------------------------------------------------------
recv_close() ->
    [{doc,"Special case of call error handling"}].
recv_close(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),

    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    Server  = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
					  {from, self()},
					  {mfa, {?MODULE, do_recv_close, []}},
					 {options, [{active, false} | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    {_Client, #sslsocket{} = SslSocket} = ssl_test_lib:start_client([return_socket,
									   {node, ClientNode}, {port, Port},
									   {host, Hostname},
									   {from, self()},
									   {mfa, {ssl_test_lib, no_result, []}},
									   {options, ClientOpts}]),
    ssl:close(SslSocket),
    ssl_test_lib:check_result(Server, ok).


%%--------------------------------------------------------------------
recv_no_active_msg() ->
    [{doc,"If we have a passive socket and do not call recv and peer closes we should no get"
      "receive an active message"}].
recv_no_active_msg(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),

    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    Server  = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
					  {from, self()},
					  {mfa, {?MODULE, no_recv_no_active, []}},
					 {options, [{active, false} | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
                                        {host, Hostname},
                                        {from, self()},
                                        {mfa, {ssl_test_lib, no_result, []}},
                                        {options, ClientOpts}]),
    ssl_test_lib:close(Client),
    ssl_test_lib:check_result(Server, ok).

%%--------------------------------------------------------------------
controlling_process() ->
    [{doc,"Test API function controlling_process/2"}].

controlling_process(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    ClientMsg = "Server hello",
    ServerMsg = "Client hello",
   
    Server = ssl_test_lib:start_server([
                                        {node, ServerNode}, {port, 0}, 
                                        {from, self()}, 
                                        {mfa, {?MODULE, 
                                               controlling_process_result, [self(),
                                                                            ServerMsg]}},
                                        {options, ServerOpts}]),
    Port = ssl_test_lib:inet_port(Server),
    {Client, CSocket} = ssl_test_lib:start_client([return_socket,
                                                   {node, ClientNode}, {port, Port}, 
                                                   {host, Hostname},
                                        {from, self()}, 
			   {mfa, {?MODULE, 
				  controlling_process_result, [self(),
							       ClientMsg]}},
			   {options, ClientOpts}]),
    
    ct:log("Testcase ~p, Client ~p  Server ~p ~n",
           [self(), Client, Server]),
    
    ServerMsg = ssl_test_lib:active_recv(CSocket, length(ServerMsg)),
    %% We do not have the TLS server socket but all messages form the client
    %% socket are now read, so ramining are form the server socket
    ClientMsg = ssl_active_recv(length(ClientMsg)),

    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).
%%--------------------------------------------------------------------
controller_dies() ->
    [{doc,"Test that the socket is closed after controlling process dies"}].
controller_dies(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    ClientMsg = "Hello server",
    ServerMsg = "Hello client",

    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0}, 
					{from, self()}, 
					{mfa, {?MODULE, 
					       controller_dies_result, [self(),
									ServerMsg]}},
					{options, ServerOpts}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port}, 
					{host, Hostname},
					{from, self()}, 
					{mfa, {?MODULE, 
					       controller_dies_result, [self(),
									    ClientMsg]}},
					{options, ClientOpts}]),

    ct:log("Testcase ~p, Client ~p  Server ~p ~n", [self(), Client, Server]),
    ct:sleep(?SLEEP), %% so that they are connected
    
    process_flag(trap_exit, true),

    %% Test that clients die
    exit(Client, killed),
    get_close(Client, ?LINE),

    %% Test that clients die when process disappear
    Server ! listen, 
    Tester = self(),
    Connect = fun(Pid) ->
		      {ok, Socket} = ssl:connect(Hostname, Port, ClientOpts),
		      %% Make sure server finishes and verification
		      %% and is in coonection state before
		      %% killing client
		      ct:sleep(?SLEEP),
		      Pid ! {self(), connected, Socket},
		      receive die_nice -> normal end
	      end,
    Client2 = spawn_link(fun() -> Connect(Tester) end),
    receive {Client2, connected, _Socket} ->  Client2 ! die_nice end,
    
    get_close(Client2, ?LINE),
    
    %% Test that clients die when the controlling process have changed 
    Server ! listen, 

    Client3 = spawn_link(fun() -> Connect(Tester) end),
    Controller = spawn_link(fun() -> receive die_nice -> normal end end),
    receive 
	{Client3, connected, Socket} ->  
	    ok = ssl:controlling_process(Socket, Controller),
	    Client3 ! die_nice 
    end,

    ct:log("Waiting on exit ~p~n",[Client3]),
    receive {'EXIT', Client3, normal} -> ok end,
    
    receive   %% Client3 is dead but that doesn't matter, socket should not be closed.
	Unexpected ->
	    ct:log("Unexpected ~p~n",[Unexpected]),
	    ct:fail({line, ?LINE-1})
    after 1000 ->
	    ok
    end,
    Controller ! die_nice,
    get_close(Controller, ?LINE),
    
    %% Test that servers die
    Server ! listen, 
    LastClient = ssl_test_lib:start_client([{node, ClientNode}, {port, Port}, 
					    {host, Hostname},
					    {from, self()}, 
					    {mfa, {?MODULE, 
						   controller_dies_result, [self(),
									    ClientMsg]}},
					    {options, ClientOpts}]),
    ct:sleep(?SLEEP), %% so that they are connected
    
    exit(Server, killed),
    get_close(Server, ?LINE),
    process_flag(trap_exit, false),
    ssl_test_lib:close(LastClient).
%%--------------------------------------------------------------------
controlling_process_transport_accept_socket() ->
    [{doc,"Only ssl:handshake and ssl:controlling_process is allowed for transport_accept:sockets"}].
controlling_process_transport_accept_socket(Config) when is_list(Config) ->
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server = ssl_test_lib:start_server_transport_control([{node, ServerNode}, 
                                                          {port, 0},
                                                          {from, self()},
                                                          {options, ServerOpts}]),
    Port = ssl_test_lib:inet_port(Server),
    
    _Client = ssl_test_lib:start_client_error([{node, ClientNode}, {port, Port},
                                              {host, Hostname},
                                              {from, self()},
                                              {options, ClientOpts}]),
    ssl_test_lib:check_result(Server, ok),
    ssl_test_lib:close(Server).

%%--------------------------------------------------------------------
close_with_timeout() ->
      [{doc,"Test normal (not downgrade) ssl:close/2"}].
close_with_timeout(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
					{from, self()},
					{mfa, {?MODULE, tls_close, []}},
					{options,[{active, false} | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
					{host, Hostname},
					{from, self()},
					{mfa, {?MODULE, tls_close, []}},
					{options, [{active, false} |ClientOpts]}]),

    ssl_test_lib:check_result(Server, ok, Client, ok).

%%--------------------------------------------------------------------
close_in_error_state() ->
    [{doc,"Special case of closing socket in error state"}].
close_in_error_state(Config) when is_list(Config) ->
    ServerOpts0 = ssl_test_lib:ssl_options(server_opts, Config),
    ServerOpts = [{cacertfile, "foo.pem"} | proplists:delete(cacertfile, ServerOpts0)],
    ClientOpts = ssl_test_lib:ssl_options(client_opts, Config),
    _ = spawn(?MODULE, run_error_server_close, [[self() | ServerOpts]]),
    receive
        {_Pid, Port} ->
            spawn_link(?MODULE, run_client_error, [[Port, ClientOpts]])
    end,
    receive
        ok ->
            ok;
        Other ->
            ct:fail(Other)
    end.

%%--------------------------------------------------------------------
call_in_error_state() ->
    [{doc,"Special case of call error handling"}].
call_in_error_state(Config) when is_list(Config) ->
    ServerOpts0 = ssl_test_lib:ssl_options(server_opts, Config),
    ClientOpts = ssl_test_lib:ssl_options(client_opts, Config),
    ServerOpts = [{cacertfile, "foo.pem"} | proplists:delete(cacertfile, ServerOpts0)],
    Pid = spawn(?MODULE, run_error_server, [[self() | ServerOpts]]),
    receive
        {Pid, Port} ->
            spawn_link(?MODULE, run_client_error, [[Port, ClientOpts]])
    end,
    receive
        {error, closed} ->
            ok;
        Other ->
            ct:fail(Other)
    end.
%%--------------------------------------------------------------------
close_transport_accept() ->
    [{doc,"Tests closing ssl socket when waiting on ssl:transport_accept/1"}].

close_transport_accept(Config) when is_list(Config) ->
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {_ClientNode, ServerNode, _Hostname} = ssl_test_lib:run_where(Config),

    Port = 0,
    Opts = [{active, false} | ServerOpts],
    {ok, ListenSocket} = rpc:call(ServerNode, ssl, listen, [Port, Opts]),
    spawn_link(fun() ->
			ct:sleep(?SLEEP),
			rpc:call(ServerNode, ssl, close, [ListenSocket])
	       end),
    case rpc:call(ServerNode, ssl, transport_accept, [ListenSocket]) of
	{error, closed} ->
	    ok;
	Other ->
	    exit({?LINE, Other})
    end.
%%--------------------------------------------------------------------
abuse_transport_accept_socket() ->
    [{doc,"Only ssl:handshake and ssl:controlling_process is allowed for transport_accept:sockets"}].
abuse_transport_accept_socket(Config) when is_list(Config) ->
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server = ssl_test_lib:start_server_transport_abuse_socket([{node, ServerNode}, 
                                                               {port, 0},
                                                               {from, self()},
                                                               {options, ServerOpts}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
                                        {host, Hostname},
                                        {from, self()},
                                        {mfa, {ssl_test_lib, no_result, []}},
                                        {options, ClientOpts}]),
    ssl_test_lib:check_result(Server, ok),
    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%--------------------------------------------------------------------

invalid_keyfile() ->
    [{doc,"Test what happens with an invalid key file"}].
invalid_keyfile(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    BadKeyFile = filename:join([proplists:get_value(priv_dir, Config), 
			      "badkey.pem"]),
    BadOpts = [{keyfile, BadKeyFile}| proplists:delete(keyfile, ServerOpts)],
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server = 
	ssl_test_lib:start_server_error([{node, ServerNode}, {port, 0}, 
					 {from, self()},
			    {options, BadOpts}]),

    Port = ssl_test_lib:inet_port(Server),

    Client =
	ssl_test_lib:start_client_error([{node, ClientNode}, 
			    {port, Port}, {host, Hostname},
			    {from, self()},  {options, ClientOpts}]),

    File = proplists:get_value(keyfile,BadOpts),    
    ssl_test_lib:check_result(Server,
                              {error,{options, {keyfile, File, {error,enoent}}}}, Client,
                              {error, closed}).

%%--------------------------------------------------------------------
honor_server_cipher_order() ->
    [{doc,"Test API honor server cipher order."}].
honor_server_cipher_order(Config) when is_list(Config) ->
     ClientCiphers = [#{key_exchange => dhe_rsa, 
                       cipher => aes_128_cbc, 
                       mac => sha,
                       prf => default_prf}, 
                     #{key_exchange => dhe_rsa, 
                       cipher => aes_256_cbc, 
                       mac => sha,
                       prf => default_prf}],
    ServerCiphers = [#{key_exchange => dhe_rsa, 
                       cipher => aes_256_cbc,   
                       mac =>sha,
                       prf => default_prf},
                     #{key_exchange => dhe_rsa, 
                       cipher => aes_128_cbc, 
                       mac => sha,
                       prf => default_prf}],
    honor_cipher_order(Config, true, ServerCiphers,
                       ClientCiphers, #{key_exchange => dhe_rsa,
                                        cipher => aes_256_cbc,
                                        mac => sha,
                                        prf => default_prf}).

%%--------------------------------------------------------------------
honor_client_cipher_order() ->
    [{doc,"Test API honor server cipher order."}].
honor_client_cipher_order(Config) when is_list(Config) ->
    ClientCiphers = [#{key_exchange => dhe_rsa, 
                       cipher => aes_128_cbc, 
                       mac => sha,
                       prf => default_prf}, 
                     #{key_exchange => dhe_rsa, 
                       cipher => aes_256_cbc, 
                       mac => sha,
                       prf => default_prf}],
    ServerCiphers = [#{key_exchange => dhe_rsa, 
                       cipher => aes_256_cbc,   
                       mac =>sha,
                       prf => default_prf},
                     #{key_exchange => dhe_rsa, 
                       cipher => aes_128_cbc, 
                       mac => sha,
                       prf => default_prf}],
    honor_cipher_order(Config, false, ServerCiphers,
                       ClientCiphers, #{key_exchange => dhe_rsa,
                                        cipher => aes_128_cbc,
                                        mac => sha,
                                        prf => default_prf}).

%%--------------------------------------------------------------------
ipv6() ->
    [{require, ipv6_hosts},
     {doc,"Test ipv6."}].
ipv6(Config) when is_list(Config) ->
    {ok, Hostname0} = inet:gethostname(),
    
    case lists:member(list_to_atom(Hostname0), ct:get_config(ipv6_hosts)) of
	true ->
	    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
	    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
	    {ClientNode, ServerNode, Hostname} = 
		ssl_test_lib:run_where(Config, ipv6),
	    Server = ssl_test_lib:start_server([{node, ServerNode}, 
				   {port, 0}, {from, self()}, 
				   {mfa, {ssl_test_lib, send_recv_result, []}},
				   {options,  
				    [inet6, {active, false} | ServerOpts]}]),
	    Port = ssl_test_lib:inet_port(Server), 
	    Client = ssl_test_lib:start_client([{node, ClientNode}, 
				   {port, Port}, {host, Hostname},
				   {from, self()}, 
				   {mfa, {ssl_test_lib, send_recv_result, []}},
				   {options, 
				    [inet6, {active, false} | ClientOpts]}]),
	    
	    ct:log("Testcase ~p, Client ~p  Server ~p ~n",
			       [self(), Client, Server]),
	    
	    ssl_test_lib:check_result(Server, ok, Client, ok),
	    
	    ssl_test_lib:close(Server),
	    ssl_test_lib:close(Client);
	false ->
	    {skip, "Host does not support IPv6"}
    end.

%%--------------------------------------------------------------------
der_input() ->
    [{doc,"Test to input certs and key as der"}].

der_input(Config) when is_list(Config) ->
    DataDir = proplists:get_value(data_dir, Config),
    DHParamFile = filename:join(DataDir, "dHParam.pem"),

    {status, _, _, StatusInfo} = sys:get_status(whereis(ssl_manager)),
    [_, _,_, _, Prop] = StatusInfo,
    State = ssl_test_lib:state(Prop),
    [CADb | _] = element(5, State),
    ct:sleep(?SLEEP*2), %%Make sure there is no outstanding clean cert db msg in manager
    Size = ets:info(CADb, size),
    ct:pal("Size ~p", [Size]),

    SeverVerifyOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ServerCert, ServerKey, ServerCaCerts, DHParams} = der_input_opts([{dhfile, DHParamFile} |
								       SeverVerifyOpts]),
    ClientVerifyOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    {ClientCert, ClientKey, ClientCaCerts, DHParams} = der_input_opts([{dhfile, DHParamFile} |
								       ClientVerifyOpts]),
    ServerOpts = [{verify, verify_peer}, {fail_if_no_peer_cert, true},
		  {dh, DHParams},
		  {cert, ServerCert}, {key, ServerKey}, {cacerts, ServerCaCerts}],
    ClientOpts = [{verify, verify_peer}, {fail_if_no_peer_cert, true},
		  {dh, DHParams},
		  {cert, ClientCert}, {key, ClientKey}, {cacerts, ClientCaCerts}],
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
					{from, self()},
					{mfa, {ssl_test_lib, send_recv_result, []}},
					{options, [{active, false} | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
					{host, Hostname},
					{from, self()},
					{mfa, {ssl_test_lib, send_recv_result, []}},
					{options, [{active, false} | ClientOpts]}]),

    ssl_test_lib:check_result(Server, ok, Client, ok),
    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client),
    %% Using only DER input should not increase file indexed DB 
    Size = ets:info(CADb, size).

%%--------------------------------------------------------------------
invalid_certfile() ->
    [{doc,"Test what happens with an invalid cert file"}].

invalid_certfile(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    BadCertFile = filename:join([proplists:get_value(priv_dir, Config), 
                                 "badcert.pem"]),
    ServerBadOpts = [{certfile, BadCertFile}| proplists:delete(certfile, ServerOpts)],
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),


    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    
    Server = 
	ssl_test_lib:start_server_error([{node, ServerNode}, {port, 0}, 
					 {from, self()},
					 {options, ServerBadOpts}]),

    Port = ssl_test_lib:inet_port(Server),

    Client =
	ssl_test_lib:start_client_error([{node, ClientNode}, 
					 {port, Port}, {host, Hostname},
					 {from, self()}, 
					 {options, ClientOpts}]),
    File = proplists:get_value(certfile, ServerBadOpts),
    ssl_test_lib:check_result(Server, {error,{options, {certfile, File, {error,enoent}}}}, 
			      Client, {error, closed}).
    

%%--------------------------------------------------------------------
invalid_cacertfile() ->
    [{doc,"Test what happens with an invalid cacert file"}].

invalid_cacertfile(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    BadCACertFile = filename:join([proplists:get_value(priv_dir, Config), 
                                 "badcacert.pem"]),
    ServerBadOpts = [{cacertfile, BadCACertFile}| proplists:delete(cacertfile, ServerOpts)],
    
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server0  = 
	ssl_test_lib:start_server_error([{node, ServerNode}, 
					 {port, 0}, {from, self()},
					 {options, ServerBadOpts}]),

    Port0 = ssl_test_lib:inet_port(Server0),
    

    Client0 =
	ssl_test_lib:start_client_error([{node, ClientNode}, 
					 {port, Port0}, {host, Hostname},
					 {from, self()}, 
					 {options, ClientOpts}]),

    File0 = proplists:get_value(cacertfile, ServerBadOpts),
    
    ssl_test_lib:check_result(Server0, {error, {options, {cacertfile, File0,{error,enoent}}}},
			      Client0, {error, closed}),
    
    File = File0 ++ "do_not_exit.pem",
    ServerBadOpts1 = [{cacertfile, File}|proplists:delete(cacertfile, ServerBadOpts)],
            
    Server1  = 
	ssl_test_lib:start_server_error([{node, ServerNode}, 
					 {port, 0}, {from, self()},
					 {options, ServerBadOpts1}]),

    Port1 = ssl_test_lib:inet_port(Server1),
    
    Client1 =
	ssl_test_lib:start_client_error([{node, ClientNode}, 
					 {port, Port1}, {host, Hostname},
					 {from, self()}, 
					 {options, ClientOpts}]),


    ssl_test_lib:check_result(Server1, {error, {options, {cacertfile, File,{error,enoent}}}},
			      Client1, {error, closed}),
    ok.

%%--------------------------------------------------------------------
new_options_in_handshake() ->
    [{doc,"Test that you can set ssl options in handshake/3 and not only in tcp upgrade"}].
new_options_in_handshake(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    Version = ssl_test_lib:protocol_version(Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Ciphers = [_, Cipher | _] = ssl:filter_cipher_suites(ssl:cipher_suites(all, Version), 
                                                         [{key_exchange,
                                                 fun(dhe_rsa) ->
                                                         true;
                                                    (ecdhe_rsa) ->
                                                         true;
                                                    (rsa) ->
                                                         false;
                                                    (_) ->
                                                         false
                                                 end
                                                }]),
    
    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0}, 
					{from, self()}, 
					{ssl_extra_opts, [{versions, [Version]},
							  {ciphers,[Cipher]}]}, %% To be set in handshake/3
					{mfa, {?MODULE, connection_info_result, []}},
					{options, ServerOpts}]),
    
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
					{host, Hostname},
					{from, self()}, 
					{mfa, {?MODULE, connection_info_result, []}},
					{options, [{ciphers, Ciphers} | ClientOpts]}]),
    
    ct:log("Testcase ~p, Client ~p  Server ~p ~n",
		       [self(), Client, Server]),

    ServerMsg = ClientMsg = {ok, {Version, Cipher}},
   
    ssl_test_lib:check_result(Server, ServerMsg, Client, ClientMsg),
    
    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%-------------------------------------------------------------------
max_handshake_size() ->
    [{doc,"Test that we can set max_handshake_size to max value."}].

max_handshake_size(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),  

    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0}, 
					{from, self()}, 
					{mfa, {ssl_test_lib, send_recv_result_active, []}},
					{options,  [{max_handshake_size, 8388607} |ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port}, 
					{host, Hostname},
					{from, self()}, 
					{mfa, {ssl_test_lib, send_recv_result_active, []}},
					{options, [{max_handshake_size, 8388607} | ClientOpts]}]),
 
    ssl_test_lib:check_result(Server, ok, Client, ok).
  

%%-------------------------------------------------------------------
options_not_proplist() ->
    [{doc,"Test what happens if an option is not a key value tuple"}].

options_not_proplist(Config) when is_list(Config) ->
    BadOption =  {client_preferred_next_protocols, 
		  client, [<<"spdy/3">>,<<"http/1.1">>], <<"http/1.1">>},
    {option_not_a_key_value_tuple, BadOption} =
	ssl:connect("twitter.com", 443, [binary, {active, false}, 
					 BadOption]).

%%-------------------------------------------------------------------
invalid_options() ->
    [{doc,"Test what happens when we give invalid options"}].
       
invalid_options(Config) when is_list(Config) -> 
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_verify_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    
    Check = fun(Client, Server, {versions, [sslv2, sslv3]} = Option) ->
		    ssl_test_lib:check_result(Server, 
					      {error, {options, {sslv2, Option}}}, 
					      Client,
					      {error, {options, {sslv2, Option}}});
	       (Client, Server, Option) ->
		    ssl_test_lib:check_result(Server, 
					      {error, {options, Option}}, 
					      Client,
					      {error, {options, Option}})
	    end,

    TestOpts = 
         [{versions, [sslv2, sslv3]}, 
          {verify, 4}, 
          {verify_fun, function},
          {fail_if_no_peer_cert, 0}, 
          {depth, four}, 
          {certfile, 'cert.pem'}, 
          {keyfile,'key.pem' }, 
          {password, foo},
          {cacertfile, ""}, 
          {dhfile,'dh.pem' },
          {ciphers, [{foo, bar, sha, ignore}]},
          {reuse_session, foo},
          {reuse_sessions, 0},
          {renegotiate_at, "10"},
          {mode, depech},
          {packet, 8.0},
          {packet_size, "2"},
          {header, a},
          {active, trice},
          {key, 'key.pem' }],

    TestOpts2 =
        [{[{anti_replay, '10k'}],
          %% anti_replay is a server only option but tested with client
          %% for simplicity
          {options,dependency,{anti_replay,{versions,['tlsv1.3']}}}},
         {[{cookie, false}],
          {options,dependency,{cookie,{versions,['tlsv1.3']}}}},
         {[{supported_groups, []}],
          {options,dependency,{supported_groups,{versions,['tlsv1.3']}}}},
         {[{use_ticket, [<<1,2,3,4>>]}],
          {options,dependency,{use_ticket,{versions,['tlsv1.3']}}}},
         {[{verify, verify_none}, {fail_if_no_peer_cert, true}],
          {options, incompatible,
                   {verify, verify_none},
                   {fail_if_no_peer_cert, true}}}],

    [begin
	 Server =
	     ssl_test_lib:start_server_error([{node, ServerNode}, {port, 0},
					{from, self()},
					{options, [TestOpt | ServerOpts]}]),
	 %% Will never reach a point where port is used.
	 Client =
	     ssl_test_lib:start_client_error([{node, ClientNode}, {port, 0},
					      {host, Hostname}, {from, self()},
					      {options, [TestOpt | ClientOpts]}]),
	 Check(Client, Server, TestOpt),
	 ok
     end || TestOpt <- TestOpts],

    [begin
         start_client_negative(Config, TestOpt, ErrorMsg),
         ok
     end || {TestOpt, ErrorMsg} <- TestOpts2],
    ok.

%%-------------------------------------------------------------------

default_reject_anonymous()->
    [{doc,"Test that by default anonymous cipher suites are rejected "}].
default_reject_anonymous(Config) when is_list(Config) ->
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    Version = ssl_test_lib:protocol_version(Config),
    TLSVersion = ssl_test_lib:tls_version(Version),
    
   [CipherSuite | _] = ssl_test_lib:ecdh_dh_anonymous_suites(TLSVersion),
    
    Server = ssl_test_lib:start_server_error([{node, ServerNode}, {port, 0},
					      {from, self()},
					      {options, ServerOpts}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client_error([{node, ClientNode}, {port, Port},
                                              {host, Hostname},
                                              {from, self()},
                                              {options,
                                               [{ciphers,[CipherSuite]} |
                                                ClientOpts]}]),

    ssl_test_lib:check_server_alert(Server, Client, insufficient_security).

%%-------------------------------------------------------------------
cb_info() ->
    [{doc,"Test that we can set cb_info."}].

cb_info(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    Protocol = proplists:get_value(protocol, Config, tls),
    CbInfo =
        case Protocol of
            tls ->
                {cb_info, {gen_tcp, tcp, tcp_closed, tcp_error}};
            dtls ->
                {cb_info, {gen_udp, udp, udp_closed, udp_error}}
        end,
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
                                        {from, self()},
                                        {mfa, {ssl_test_lib, send_recv_result_active, []}},
                                        {options,  [CbInfo | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),

    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
                                        {host, Hostname},
                                        {from, self()},
                                        {mfa, {ssl_test_lib, send_recv_result_active, []}},
                                        {options, [CbInfo | ClientOpts]}]),

    ssl_test_lib:check_result(Server, ok, Client, ok).

%%-------------------------------------------------------------------
log_alert() ->
    [{doc,"Test that we can set log_alert and that it translates to correct log_level" 
      " that has replaced this option"}].

log_alert(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),

    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
                                        {from, self()},
                                        {mfa, {ssl_test_lib, send_recv_result_active, []}},
                                        {options,  [{log_alert, true} | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    {Client, CSock} = ssl_test_lib:start_client([return_socket,
                                                 {node, ClientNode}, {port, Port},
                                                 {host, Hostname},
                                                 {from, self()},
                                                 {mfa, {ssl_test_lib, send_recv_result_active, []}},
                                                 {options, [{log_alert, false} | ClientOpts]}]),
    
    {ok, [{log_level, none}]} = ssl:connection_information(CSock, [log_level]),
    
    ssl_test_lib:check_result(Server, ok, Client, ok).


%%-------------------------------------------------------------------
%% Note that these test only test that the options are valid to set. As application data
%% is a stream you can not test that the send acctually splits it up as when it arrives
%% again at the user layer it may be concatenated. But COVER can show that the split up
%% code has been run.
   
rizzo_disabled() ->
     [{doc, "Test original beast mitigation disable option for SSL 3.0 and TLS 1.0"}].

rizzo_disabled(Config) ->
    ClientOpts = [{beast_mitigation, disabled} | ssl_test_lib:ssl_options(client_rsa_opts, Config)],
    ServerOpts =  [{beast_mitigation, disabled} | ssl_test_lib:ssl_options(server_rsa_opts, Config)],
    
    ssl_test_lib:basic_test(ClientOpts, ServerOpts, Config).
%%-------------------------------------------------------------------
rizzo_zero_n() ->
     [{doc, "Test zero_n beast mitigation option (same affect as original disable option) for SSL 3.0 and TLS 1.0"}].

rizzo_zero_n(Config) ->
    ClientOpts = [{beast_mitigation, zero_n} | ssl_test_lib:ssl_options(client_rsa_opts, Config)],
    ServerOpts =  [{beast_mitigation, zero_n} | ssl_test_lib:ssl_options(server_rsa_opts, Config)],
    
    ssl_test_lib:basic_test(ClientOpts, ServerOpts, Config).
%%-------------------------------------------------------------------
rizzo_one_n_minus_one () ->
     [{doc, "Test beast_mitigation option one_n_minus_one (same affect as default) for SSL 3.0 and TLS 1.0"}].

rizzo_one_n_minus_one (Config) ->
    ClientOpts = [{beast_mitigation, one_n_minus_one } | ssl_test_lib:ssl_options(client_rsa_opts, Config)],
    ServerOpts =  [{beast_mitigation, one_n_minus_one} | ssl_test_lib:ssl_options(server_rsa_opts, Config)],
    
    ssl_test_lib:basic_test(ClientOpts, ServerOpts, Config).

%%-------------------------------------------------------------------

supported_groups() ->
    [{doc,"Test the supported_groups option in TLS 1.3."}].

supported_groups(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),

    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
					{from, self()},
                                        {mfa, {ssl_test_lib, send_recv_result_active, []}},
                                        {options, [{supported_groups, [x448, x25519]} | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
					{host, Hostname},
                                        {from, self()},
                                        {mfa, {ssl_test_lib, send_recv_result_active, []}},
                                        {options, [{supported_groups,[x448]} | ClientOpts]}]),

    ssl_test_lib:check_result(Server, ok, Client, ok),

    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

%%--------------------------------------------------------------------
honor_client_cipher_order_tls13() ->
    [{doc,"Test API honor server cipher order in TLS 1.3."}].
honor_client_cipher_order_tls13(Config) when is_list(Config) ->
    ClientCiphers = [#{key_exchange => any,
                       cipher => aes_256_gcm,
                       mac => aead,
                       prf => sha384},
                     #{key_exchange => any,
                       cipher => aes_128_gcm,
                       mac => aead,
                       prf => sha256}],
    ServerCiphers = [#{key_exchange => any,
                       cipher => aes_128_gcm,
                       mac => aead,
                       prf => sha256},
                     #{key_exchange => any,
                       cipher => aes_256_gcm,
                       mac => aead,
                       prf => sha384}],
    honor_cipher_order(Config, false, ServerCiphers, ClientCiphers, #{key_exchange => any,
                                                                      cipher => aes_256_gcm,
                                                                      mac => aead,
                                                                      prf => sha384}).

%%--------------------------------------------------------------------
client_options_negative_version_gap() ->
    [{doc,"Test client options with faulty version gap."}].
client_options_negative_version_gap(Config) when is_list(Config) ->
    start_client_negative(Config, [{versions, ['tlsv1', 'tlsv1.3']}],
                          {options, missing_version, 
                           {'tlsv1.2', {versions,[tlsv1, 'tlsv1.3']}}}).

%%--------------------------------------------------------------------
client_options_negative_dependency_version() ->
    [{doc,"Test client options with faulty version dependency."}].
client_options_negative_dependency_version(Config) when is_list(Config) ->
    start_client_negative(Config, [{versions, ['tlsv1.1', 'tlsv1.2']},
                                   {session_tickets, manual}],
                          {options,dependency,
                           {session_tickets,{versions,['tlsv1.3']}}}).

%%--------------------------------------------------------------------
client_options_negative_dependency_stateless() ->
    [{doc,"Test client options with faulty 'session_tickets' option."}].
client_options_negative_dependency_stateless(Config) when is_list(Config) ->
    start_client_negative(Config, [{versions, ['tlsv1.2', 'tlsv1.3']},
                                   {anti_replay, '10k'},
                                   {session_tickets, manual}],
                          {options,dependency,
                           {anti_replay,{session_tickets,[stateless]}}}).


%%--------------------------------------------------------------------
client_options_negative_dependency_role() ->
    [{doc,"Test client options with faulty role."}].
client_options_negative_dependency_role(Config) when is_list(Config) ->
    start_client_negative(Config, [{versions, ['tlsv1.2', 'tlsv1.3']},
                                   {session_tickets, stateless}],
                          {options,role,
                           {session_tickets,{stateless,{client,[disabled,manual,auto]}}}}).

%%--------------------------------------------------------------------
client_options_negative_early_data() ->
    [{doc,"Test client option early_data."}].
client_options_negative_early_data(Config) when is_list(Config) ->
    start_client_negative(Config, [{versions, ['tlsv1.2']},
                                   {early_data, "test"}],
                          {options,dependency,
                           {early_data,{versions,['tlsv1.3']}}}),
    start_client_negative(Config, [{versions, ['tlsv1.2', 'tlsv1.3']},
                                   {early_data, "test"}],
                          {options,dependency,
                           {early_data,{session_tickets,[manual,auto]}}}),

    start_client_negative(Config, [{versions, ['tlsv1.2', 'tlsv1.3']},
                                   {session_tickets, stateful},
                                   {early_data, "test"}],
                          {options,role,
                           {session_tickets,
                            {stateful,{client,[disabled,manual,auto]}}}}),
    start_client_negative(Config, [{versions, ['tlsv1.2', 'tlsv1.3']},
                                   {session_tickets, disabled},
                                   {early_data, "test"}],
                          {options,dependency,
                           {early_data,{session_tickets,[manual,auto]}}}),

    start_client_negative(Config, [{versions, ['tlsv1.2', 'tlsv1.3']},
                                   {session_tickets, manual},
                                   {early_data, "test"}],
                          {options,dependency,
                           {early_data, use_ticket}}),
    start_client_negative(Config, [{versions, ['tlsv1.2', 'tlsv1.3']},
                                   {session_tickets, manual},
                                   {use_ticket, [<<"ticket">>]},
                                   {early_data, "test"}],
                          {options, type,
                           {early_data, {"test", not_binary}}}),
    %% All options are ok but there is no server
    start_client_negative(Config, [{versions, ['tlsv1.2', 'tlsv1.3']},
                                   {session_tickets, manual},
                                   {use_ticket, [<<"ticket">>]},
                                   {early_data, <<"test">>}],
                          econnrefused),

    start_client_negative(Config, [{versions, ['tlsv1.2', 'tlsv1.3']},
                                   {session_tickets, auto},
                                   {early_data, "test"}],
                          {options, type,
                           {early_data, {"test", not_binary}}}),
    %% All options are ok but there is no server
    start_client_negative(Config, [{versions, ['tlsv1.2', 'tlsv1.3']},
                                   {session_tickets, auto},
                                   {early_data, <<"test">>}],
                          econnrefused).

%%--------------------------------------------------------------------
server_options_negative_early_data() ->
    [{doc,"Test server option early_data."}].
server_options_negative_early_data(Config) when is_list(Config) ->
    start_server_negative(Config, [{versions, ['tlsv1.2']},
                                   {early_data, "test"}],
                          {options,dependency,
                           {early_data,{versions,['tlsv1.3']}}}),
    start_server_negative(Config, [{versions, ['tlsv1.2', 'tlsv1.3']},
                                   {early_data, "test"}],
                          {options,dependency,
                           {early_data,{session_tickets,[stateful,stateless]}}}),

    start_server_negative(Config, [{versions, ['tlsv1.2', 'tlsv1.3']},
                                   {session_tickets, manual},
                                   {early_data, "test"}],
                          {options,role,
                           {session_tickets,
                            {manual,{server,[disabled,stateful,stateless]}}}}),
    start_server_negative(Config, [{versions, ['tlsv1.2', 'tlsv1.3']},
                                   {session_tickets, disabled},
                                   {early_data, "test"}],
                          {options,dependency,
                           {early_data,{session_tickets,[stateful,stateless]}}}),

    start_server_negative(Config, [{versions, ['tlsv1.2', 'tlsv1.3']},
                                   {session_tickets, stateful},
                                   {early_data, "test"}],
                          {options,role,
                           {early_data,{"test",{server,[disabled,enabled]}}}}).

%%--------------------------------------------------------------------
server_options_negative_version_gap() ->
    [{doc,"Test server options with faulty version gap."}].
server_options_negative_version_gap(Config) when is_list(Config) ->
    start_server_negative(Config, [{versions, ['tlsv1', 'tlsv1.3']}],
                          {options, missing_version,
                           {'tlsv1.2', {versions,[tlsv1, 'tlsv1.3']}}}).

%%--------------------------------------------------------------------
server_options_negative_dependency_role() ->
    [{doc,"Test server options with faulty role."}].
server_options_negative_dependency_role(Config) when is_list(Config) ->
    start_server_negative(Config, [{versions, ['tlsv1.2', 'tlsv1.3']},
                                   {session_tickets, manual}],
                          {options,role,
                           {session_tickets,{manual,{server,[disabled,stateful,stateless]}}}}).

%%--------------------------------------------------------------------
honor_server_cipher_order_tls13() ->
    [{doc,"Test API honor server cipher order in TLS 1.3."}].
honor_server_cipher_order_tls13(Config) when is_list(Config) ->
    ClientCiphers = [#{key_exchange => any,
                       cipher => aes_256_gcm,
                       mac => aead,
                       prf => sha384},
                     #{key_exchange => any,
                       cipher => aes_128_gcm,
                       mac => aead,
                       prf => sha256}],
    ServerCiphers = [#{key_exchange => any,
                       cipher => aes_128_gcm,
                       mac => aead,
                       prf => sha256},
                     #{key_exchange => any,
                       cipher => aes_256_gcm,
                       mac => aead,
                       prf => sha384}],
    honor_cipher_order(Config, true, ServerCiphers,
                       ClientCiphers, #{key_exchange => any,
                                        cipher => aes_128_gcm,
                                        mac => aead,
                                        prf => sha256}).
%%--------------------------------------------------------------------
getstat() ->
    [{doc, "Test that you use ssl:getstat on a TLS socket"}].

getstat(Config) when is_list(Config) ->    
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    
    Port0 = ssl_test_lib:inet_port(ServerNode),
    {ok, ListenSocket} = ssl:listen(Port0, [ServerOpts]),
    {ok, _} = ssl:getstat(ListenSocket),
    ssl:close(ListenSocket),

    Server = ssl_test_lib:start_server([{node, ClientNode}, {port, 0},
					{from, self()},
                                        {mfa, {?MODULE, ssl_getstat, []}},
                                        {options, ServerOpts}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ServerNode}, {port, Port},
					{host, Hostname},
                                        {from, self()},
                                        {mfa, {?MODULE, ssl_getstat, []}},
                                        {options, ClientOpts}]),
    ssl_test_lib:check_result(Server, ok, Client, ok).

invalid_options_tls13() ->
    [{doc, "Test invalid options with TLS 1.3"}].
invalid_options_tls13(Config) when is_list(Config) ->
    TestOpts =
        [{{beast_mitigation, one_n_minus_one},
          {options, dependency,
           {beast_mitigation,{versions,[tlsv1]}}},
          common},

         {{next_protocols_advertised, [<<"http/1.1">>]},
          {options, dependency,
           {next_protocols_advertised,
            {versions,[tlsv1,'tlsv1.1','tlsv1.2']}}},
          server},

         {{client_preferred_next_protocols,
           {client, [<<"http/1.1">>]}},
          {options, dependency,
           {client_preferred_next_protocols,
            {versions,[tlsv1,'tlsv1.1','tlsv1.2']}}},
          client},

         {{client_renegotiation, false},
          {options, dependency,
           {client_renegotiation,
            {versions,[tlsv1,'tlsv1.1','tlsv1.2']}}},
          server
         },

         {{cookie, false},
          {option , server_only, cookie},
          client
         },

         {{padding_check, false},
          {options, dependency,
           {padding_check,{versions,[tlsv1]}}},
          common},

         {{psk_identity, "Test-User"},
          {options, dependency,
           {psk_identity,{versions,[tlsv1,'tlsv1.1','tlsv1.2']}}},
          common},

         {{user_lookup_fun,
           {fun ssl_test_lib:user_lookup/3, <<1,2,3>>}},
          {options, dependency,
           {user_lookup_fun,{versions,[tlsv1,'tlsv1.1','tlsv1.2']}}},
          common},

         {{reuse_session, fun(_,_,_,_) -> false end},
          {options, dependency,
           {reuse_session,
            {versions,[tlsv1,'tlsv1.1','tlsv1.2']}}},
          server},

         {{reuse_session, <<1,2,3,4>>},
          {options, dependency,
           {reuse_session,
            {versions,[tlsv1,'tlsv1.1','tlsv1.2']}}},
          client},

         {{reuse_sessions, true},
          {options, dependency,
           {reuse_sessions,
            {versions,[tlsv1,'tlsv1.1','tlsv1.2']}}},
          common},

         {{secure_renegotiate, false},
          {options, dependency,
           {secure_renegotiate,
            {versions,[tlsv1,'tlsv1.1','tlsv1.2']}}},
          common},

         {{srp_identity, false},
          {options, dependency,
           {srp_identity,
            {versions,[tlsv1,'tlsv1.1','tlsv1.2']}}},
          client}
        ],

    Fun = fun(Option, ErrorMsg, Type) ->
                  case Type of
                      server ->
                          start_server_negative(Config,
                                                [Option,{versions, ['tlsv1.3']}],
                                                ErrorMsg);
                      client ->
                          start_client_negative(Config,
                                                [Option,{versions, ['tlsv1.3']}],
                                                ErrorMsg);
                      common ->
                          start_server_negative(Config,
                                                [Option,{versions, ['tlsv1.3']}],
                                                ErrorMsg),
                          start_client_negative(Config,
                                                [Option,{versions, ['tlsv1.3']}],
                                                ErrorMsg)
                  end
          end,
    [Fun(Option, ErrorMsg, Type) || {Option, ErrorMsg, Type} <- TestOpts].

cookie() ->
    [{doc, "Test cookie extension in TLS 1.3"}].
cookie(Config) when is_list(Config) ->
    cookie_extension(Config, true),
    cookie_extension(Config, false).

warn_verify_none() ->
    [{doc, "Test that verify_none default generates warning."}].
warn_verify_none(Config) when is_list(Config)->
    ok = logger:add_handler(?MODULE,?MODULE,#{config=>self()}),
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),

    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
					{from, self()},
                                        {options, ServerOpts},
                                        {mfa, {ssl_test_lib, no_result, []}}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
                                        {from, self()},
                                        {host, Hostname},
	                                {options, ClientOpts},
					{mfa, {ssl_test_lib, no_result, []}}]),
    receive
        warning_generated ->
            ok = logger:remove_handler(?MODULE)
    after 500 ->
            ok = logger:remove_handler(?MODULE),
            ct:fail(no_warning)
    end,
    ssl_test_lib:close(Client),
    ssl_test_lib:close(Server).

suppress_warn_verify_none() ->
    [{doc, "Test that explicit verify_none suppresses warning."}].
suppress_warn_verify_none(Config) when is_list(Config)->
    ok = logger:add_handler(?MODULE,?MODULE,#{config=>self()}),

    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),

    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
                                        {from, self()},
                                        {options, ServerOpts},
					    {mfa, {ssl_test_lib, no_result, []}}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
                                        {from, self()},
				        {host, Hostname},
				        {options, [{verify, verify_none} | ClientOpts]},
			                {mfa, {ssl_test_lib, no_result, []}}]),
     receive
         warning_generated ->
	     ok = logger:remove_handler(?MODULE),
             ct:fail(warning)
     after 500 ->
	     ok = logger:remove_handler(?MODULE)
     end,
    ssl_test_lib:close(Client),
    ssl_test_lib:close(Server).

%%--------------------------------------------------------------------
check_random_nonce() ->
    [{doc,"Test random nonce - expecting 32B random for TLS1.3 and 4B UTC "
      "epoch with 28B random for older version"}].
check_random_nonce(Config) when is_list(Config) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    N = 10,
    F = fun (Id) -> establish_connection(Id,ServerNode, ServerOpts,
                                         ClientNode, ClientOpts,
                                         Hostname)
        end,
    ConnectionPairs = [F(Id) || Id <- lists:seq(1, N)],
    Randoms = lists:flatten([ssl_test_lib:get_result([Server, Client]) ||
                                {Server, Client} <- ConnectionPairs]),
    Deltas = [abs(FourBytes - SecsSince) ||
                 {_FromPid,
                  {_Id, {_, <<FourBytes:32, _/binary>>}, SecsSince}} <- Randoms],
    MeanDelta = lists:sum(Deltas) div N,
    case ?config(version, Config) of
        'tlsv1.3' ->
            %% 4B "random" expected since TLS1.3
            RndThreshold   = 10000,
            true = MeanDelta > RndThreshold;
        _ ->
            %% 4 epoch based bytes expected pre TLS1.3
            EpochThreshold = 10,
            true = MeanDelta < EpochThreshold
    end,
    [begin
         ssl_test_lib:close(Server),
         ssl_test_lib:close(Client)
     end || {Server, Client} <- ConnectionPairs].
%%--------------------------------------------------------------------
cipher_listing() ->
    [{doc, "Check that exclusive cipher for possible supported version adds up to all cipher " 
      "for the max version. Note that TLS-1.3 will contain two distinct sets of ciphers "
      "one for TLS-1.3 and one pre TLS-1.3"}].
cipher_listing(Config) when is_list(Config) ->
    Version = ssl_test_lib:protocol_version(Config, tuple),
    length_exclusive(Version) == length_all(Version).

%%--------------------------------------------------------------------

establish_connection(Id, ServerNode, ServerOpts, ClientNode, ClientOpts, Hostname) ->
    Server =
        ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
                                   {from, self()},
                                   {mfa, {?MODULE, get_connection_information,
                                          [Id, server_random]}},
                                   {options, [{verify, verify_peer} | ServerOpts]}]),

    ListenPort = ssl_test_lib:inet_port(Server),
    Client =
        ssl_test_lib:start_client([{node, ClientNode}, {port, ListenPort},
                                   {host, Hostname},
                                   {from, self()},
                                   {mfa, {?MODULE, get_connection_information,
                                          [Id, client_random]}},
                                   {options,  [{verify, verify_peer} |ClientOpts]}]),

    ct:log("Testcase ~p, Client ~p  Server ~p ~n",
           [self(), Client, Server]),
    {Server, Client}.

%%% Checker functions
get_connection_information(Socket, ConnectionId, InfoType) ->
    {ok, [ConnectionInfo]} = ssl:connection_information(Socket, [InfoType]),
    {ConnectionId, ConnectionInfo, secs_since_1970()}.
secs_since_1970() ->
    calendar:datetime_to_gregorian_seconds(
        calendar:universal_time()) - 62167219200.

connection_information_result(Socket) ->
    {ok, Info = [_ | _]} = ssl:connection_information(Socket),
    case  length(Info) > 3 of
	true -> 
	    %% At least one ssl_option() is set
	    ct:log("Info ~p", [Info]),
	    ok;
	false ->
	    ct:fail(no_ssl_options_returned)
    end.

secret_connection_info_result(Socket) ->
    {ok, [{protocol, Protocol}]} = ssl:connection_information(Socket, [protocol]),
    {ok, ConnInfo} = ssl:connection_information(Socket, [client_random, server_random, master_secret]),
    check_connection_info(Protocol, ConnInfo).

keylog_connection_info_result(Socket, KeepSecrets) ->
    {ok, [{protocol, Protocol}]} = ssl:connection_information(Socket, [protocol]),
    {ok, ConnInfo} = ssl:connection_information(Socket, [keylog]),
    check_keylog_info(Protocol, ConnInfo, KeepSecrets).

check_keylog_info('tlsv1.3', [{keylog, ["CLIENT_HANDSHAKE_TRAFFIC_SECRET"++_,_|_]=Keylog}], true) ->
    {ok, Keylog};
check_keylog_info('tlsv1.3', []=Keylog, false) ->
    {ok, Keylog};
check_keylog_info('tlsv1.2', [{keylog, ["CLIENT_RANDOM"++_]=Keylog}], _) ->
    {ok, Keylog};
check_keylog_info(NotSup, [], _) when NotSup == 'tlsv1.1'; NotSup == tlsv1; NotSup == 'dtlsv1.2'; NotSup == dtlsv1 ->
    {ok, []};
check_keylog_info(_, Unexpected, _) ->
    {unexpected, Unexpected}.

check_srp_in_connection_information(_Socket, _Username, client) ->
    ok;
check_srp_in_connection_information(Socket, Username, server) ->
    {ok, Info} = ssl:connection_information(Socket),
    ct:log("Info ~p~n", [Info]),
    case proplists:get_value(srp_username, Info, not_found) of
        Username ->
	        ok;
        not_found ->
            ct:fail(srp_username_not_found)
    end.

%% In TLS 1.3 the master_secret field is used to store multiple secrets from the key schedule and it is a tuple.
%% client_random and server_random are not used in the TLS 1.3 key schedule.
check_connection_info('tlsv1.3', [{client_random, ClientRand}, {master_secret, {master_secret, MasterSecret}}]) ->
    is_binary(ClientRand) andalso is_binary(MasterSecret);
check_connection_info('tlsv1.3', [{server_random, ServerRand}, {master_secret, {master_secret, MasterSecret}}]) ->
    is_binary(ServerRand) andalso is_binary(MasterSecret);
check_connection_info(_, [{client_random, ClientRand}, {server_random, ServerRand}, {master_secret, MasterSecret}]) ->
    is_binary(ClientRand) andalso is_binary(ServerRand) andalso is_binary(MasterSecret);
check_connection_info(_, _) ->
    false.

prf_verify_value(Socket, TlsVer, Expected, Algo) ->
    Ret = ssl:prf(Socket, <<>>, <<>>, [<<>>], 16),
    case TlsVer of
        sslv3 ->
            case Ret of
                {error, undefined} -> ok;
                _ ->
                    {error, {expected, {error, undefined},
                             got, Ret, tls_ver, TlsVer, prf_algorithm, Algo}}
            end;
        _ ->
            case Ret of
                {ok, Expected} -> ok;
                {ok, Val} -> {error, {expected, Expected, got, Val, tls_ver, TlsVer,
                                      prf_algorithm, Algo}}
            end
    end.
try_recv_active(Socket) ->
    ssl:send(Socket, "Hello world"),
    {error, einval} = ssl:recv(Socket, 11),
    ok.
try_recv_active_once(Socket) ->
    {error, einval} = ssl:recv(Socket, 11),
    ok.

controlling_process_result(Socket, Pid, Msg) ->
    ok = ssl:controlling_process(Socket, Pid),
    %% Make sure other side has evaluated controlling_process
    %% before message is sent
    ct:sleep(?SLEEP),
    ssl:send(Socket, Msg),
    no_result_msg.

controller_dies_result(_Socket, _Pid, _Msg) ->
    receive Result -> Result end.
send_recv_result_timeout_client(Socket) ->
    {error, timeout} = ssl:recv(Socket, 11, 500),
    {error, timeout} = ssl:recv(Socket, 11, 0),
    ssl:send(Socket, "Hello world"),
    receive
	Msg ->
	    io:format("Msg ~p~n",[Msg])
    after 500 ->
	    ok
    end,
    {ok, "Hello world"} = ssl:recv(Socket, 11, 500),
    ok.
send_recv_result_timeout_server(Socket) ->
    ssl:send(Socket, "Hello"),
    {ok, "Hello world"} = ssl:recv(Socket, 11),
    ssl:send(Socket, " world"),
    ok.

do_recv_close(Socket) ->
    {error, closed} = ssl:recv(Socket, 11),
    receive
	{_,{error,closed}} ->
	    error_extra_close_sent_to_user_process
    after 500 ->
	    ok
    end.

tls_close(Socket) ->
    ok = ssl_test_lib:send_recv_result(Socket),
    case ssl:close(Socket, 10000) of
        ok ->
            ok;
        {error, closed} ->
            ok;
        Other ->
            ct:fail(Other)
    end.

run_error_server_close([Pid | Opts]) ->
    {ok, Listen} = ssl:listen(0, Opts),
    {ok,{_, Port}} = ssl:sockname(Listen),
    Pid ! {self(), Port},
    {ok, Socket} = ssl:transport_accept(Listen),
    Pid ! ssl:close(Socket).

run_error_server([ Pid | Opts]) ->
    {ok, Listen} = ssl:listen(0, Opts),
    {ok,{_, Port}} = ssl:sockname(Listen),
    Pid ! {self(), Port},
    {ok, Socket} = ssl:transport_accept(Listen),
    Pid ! ssl:controlling_process(Socket, self()).

run_client_error([Port, Opts]) ->
    ssl:connect("localhost", Port, Opts).

no_recv_no_active(Socket) ->
    receive
        {ssl_closed, Socket} ->
            ct:fail(received_active_msg)
    after 5000 ->
            ok
    end.

connection_info_result(Socket) ->
    {ok, Info} = ssl:connection_information(Socket, [protocol, selected_cipher_suite]),
    {ok, {proplists:get_value(protocol, Info), proplists:get_value(selected_cipher_suite, Info)}}.

%%--------------------------------------------------------------------
%% Internal functions ------------------------------------------------
%%--------------------------------------------------------------------
prf_create_plan(TlsVer, _PRFs, Results) when TlsVer == tlsv1
                                             orelse TlsVer == 'tlsv1.1'
                                             orelse TlsVer == 'dtlsv1' ->
    Ciphers = prf_get_ciphers(TlsVer, default_prf),
    {_, Expected} = lists:keyfind(md5sha, 1, Results),
    [[{ciphers, Ciphers}, {expected, Expected}, {prf, md5sha}]];
prf_create_plan(TlsVer, PRFs, Results) when TlsVer == 'tlsv1.2' orelse TlsVer == 'dtlsv1.2' ->
    lists:foldl(
      fun(PRF, Acc) ->
              Ciphers = prf_get_ciphers(TlsVer, PRF),
              case Ciphers of
                  [] ->
                      ct:log("No ciphers for PRF algorithm ~p. Skipping.", [PRF]),
                      Acc;
                  Ciphers ->
                      {_, Expected} = lists:keyfind(PRF, 1, Results),
                      [[{ciphers, Ciphers}, {expected, Expected}, {prf, PRF}] | Acc]
              end
      end, [], PRFs).

prf_get_ciphers(TlsVer, PRF) ->
    PrfFilter = fun(Value) -> Value =:= PRF end,
    RSACertNoSpecialConf = fun(rsa) ->
                                   true;
                              (ecdhe_rsa) ->
                                   lists:member(ecdh, crypto:supports(public_keys));
                              (dhe_rsa) ->
                                   true;
                              (_) ->
                                   false
                           end,
    ssl:filter_cipher_suites(ssl:cipher_suites(default, TlsVer), [{key_exchange, RSACertNoSpecialConf},
                                                                  {prf, PrfFilter}]).

prf_run_test(_, TlsVer, [], _, Prf) ->
    ct:comment(lists:flatten(io_lib:format("cipher_list_empty Ver: ~p  PRF: ~p", [TlsVer, Prf])));
prf_run_test(Config, TlsVer, Ciphers, Expected, Prf) ->
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    BaseOpts = [{active, true}, {versions, [TlsVer]}, {ciphers, Ciphers}, {protocol, tls_or_dtls(TlsVer)}],
    ServerOpts = BaseOpts ++ proplists:get_value(server_rsa_opts, Config, []),
    ClientOpts = BaseOpts ++ proplists:get_value(client_rsa_opts, Config, []),
    Server = ssl_test_lib:start_server(
               [{node, ServerNode}, {port, 0}, {from, self()},
                {mfa, {?MODULE, prf_verify_value, [TlsVer, Expected, Prf]}},
                {options, ServerOpts}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client(
               [{node, ClientNode}, {port, Port},
                {host, Hostname}, {from, self()},
                {mfa, {?MODULE, prf_verify_value, [TlsVer, Expected, Prf]}},
                {options, ClientOpts}]),
    ssl_test_lib:check_result(Server, ok, Client, ok),
    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).


tls_or_dtls('dtlsv1') ->
    dtls;
tls_or_dtls('dtlsv1.2') ->
    dtls;
tls_or_dtls(_) ->
    tls.

active_n_common(S, N) ->
    ok = ssl:setopts(S, [{active,-N}]),
    receive
        {ssl_passive, S} -> ok
    after
        1000 ->
            error({error,ssl_passive_failure})
    end,
    [{active,false}] = ok(ssl:getopts(S, [active])),
    ok = ssl:setopts(S, [{active,0}]),
    receive
        {ssl_passive, S} -> ok
    after
        1000 ->
            error({error,ssl_passive_failure})
    end,
    ok = ssl:setopts(S, [{active,32767}]),
    {error,{options,_}} = ssl:setopts(S, [{active,1}]),
    {error,{options,_}} = ssl:setopts(S, [{active,-32769}]),
    ok = ssl:setopts(S, [{active,-32768}]),
    receive
        {ssl_passive, S} -> ok
    after
        1000 ->
            error({error,ssl_passive_failure})
    end,
    [{active,false}] = ok(ssl:getopts(S, [active])),
    ok = ssl:setopts(S, [{active,N}]),
    ok = ssl:setopts(S, [{active,true}]),
    [{active,true}] = ok(ssl:getopts(S, [active])),
    receive
        _ -> error({error,active_n})
    after
        0 ->
            ok
    end,
    ok = ssl:setopts(S, [{active,N}]),
    ok = ssl:setopts(S, [{active,once}]),
    [{active,once}] = ok(ssl:getopts(S, [active])),
    receive
        _ -> error({error,active_n})
    after
        0 ->
            ok
    end,
    {error,{options,_}} = ssl:setopts(S, [{active,32768}]),
    ok = ssl:setopts(S, [{active,false}]),
    [{active,false}] = ok(ssl:getopts(S, [active])),
    ok.

ok({ok,V}) -> V.

repeat(N, Fun) ->
    repeat(N, N, Fun).

repeat(N, T, Fun) when is_integer(N), N > 0 ->
    Fun(T-N),
    repeat(N-1, T, Fun);
repeat(_, _, _) ->
    ok.

get_close(Pid, Where) ->
    receive
	{'EXIT', Pid, _Reason} ->
	    receive
		{_, {ssl_closed, Socket}} ->
		    ct:log("Socket closed ~p~n",[Socket]);
		Unexpected ->
		    ct:log("Unexpected ~p~n",[Unexpected]),
		    ct:fail({line, ?LINE-1})
	    after 5000 ->
		    ct:fail({timeout, {line, ?LINE, Where}})
	    end;
	Unexpected ->
	    ct:log("Unexpected ~p~n",[Unexpected]),
	    ct:fail({line, ?LINE-1})
    after 5000 ->
	    ct:fail({timeout, {line, ?LINE, Where}})
    end.

ssl_active_recv(N) ->
    ssl_active_recv(N, []).

ssl_active_recv(0, Acc) ->
    Acc;
ssl_active_recv(N, Acc) ->
    receive 
	{ssl, _, Bytes} ->
            ssl_active_recv(N-length(Bytes),  Acc ++ Bytes)
    end.



honor_cipher_order(Config, Honor, ServerCiphers, ClientCiphers, Expected) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),

    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
					{from, self()},
					{mfa, {?MODULE, connection_info_result, []}},
					{options, [{ciphers, ServerCiphers}, {honor_cipher_order, Honor}
						   | ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
					{host, Hostname},
					{from, self()},
					{mfa, {?MODULE, connection_info_result, []}},
					{options, [{ciphers, ClientCiphers}
						   | ClientOpts]}]),

    Version = ssl_test_lib:protocol_version(Config),

    ServerMsg = ClientMsg = {ok, {Version, Expected}},

    ssl_test_lib:check_result(Server, ServerMsg, Client, ClientMsg),

    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

cookie_extension(Config, Cookie) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    Data = "123456789012345",  %% 15 bytes

    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),

    %% Trigger a HelloRetryRequest
    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
					{from, self()},
					{options, [{supported_groups, [x448,
                                                                       secp256r1,
                                                                       secp384r1]},
                                                   {cookie, Cookie}|ServerOpts]}]),
    Port = ssl_test_lib:inet_port(Server),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
					{host, Hostname},
					{from, self()},
					{options, ClientOpts}]),

    ok = ssl_test_lib:send(Client, Data),
    Data = ssl_test_lib:check_active_receive(Server, Data),

    ssl_test_lib:close(Server),
    ssl_test_lib:close(Client).

start_client_negative(Config, Options, Error) ->
    ClientOpts = ssl_test_lib:ssl_options(client_rsa_opts, Config),
    {ClientNode, ServerNode, Hostname} = ssl_test_lib:run_where(Config),
    Port = ssl_test_lib:inet_port(ServerNode),
    Client = ssl_test_lib:start_client([{node, ClientNode}, {port, Port},
					{host, Hostname},
					{from, self()},
                                        {return_error, econnrefused},
					{mfa, {?MODULE, connection_info_result, []}},
					{options, Options ++ ClientOpts}]),
    ct:pal("Actual: ~p~nExpected: ~p", [Client, {connect_failed, Error}]),
    {connect_failed, Error} = Client.

start_server_negative(Config, Options, Error) ->
    ServerOpts = ssl_test_lib:ssl_options(server_rsa_opts, Config),
    {_, ServerNode, _} = ssl_test_lib:run_where(Config),
    Server = ssl_test_lib:start_server([{node, ServerNode}, {port, 0},
					{from, self()},
					{mfa, {?MODULE, connection_info_result, []}},
					{options,  Options ++ ServerOpts}]),

    ct:pal("Actual: ~p~nExpected: ~p", [Server,Error]),
    Error = Server.

der_input_opts(Opts) ->
    Certfile = proplists:get_value(certfile, Opts),
    CaCertsfile = proplists:get_value(cacertfile, Opts),
    Keyfile = proplists:get_value(keyfile, Opts),
    Dhfile = proplists:get_value(dhfile, Opts),
    [{_, Cert, _}] = ssl_test_lib:pem_to_der(Certfile),
    [{Asn1Type, Key, _}]  = ssl_test_lib:pem_to_der(Keyfile),
    [{_, DHParams, _}]  = ssl_test_lib:pem_to_der(Dhfile),
    CaCerts =
	lists:map(fun(Entry) ->
			  {_, CaCert, _} = Entry,
			  CaCert
		  end, ssl_test_lib:pem_to_der(CaCertsfile)),
    {Cert, {Asn1Type, Key}, CaCerts, DHParams}.

ssl_getstat(Socket) ->
    ssl:send(Socket, "From Erlang to Erlang"),
    {ok, Stats} = ssl:getstat(Socket),
    List = lists:dropwhile(fun({_, 0}) ->
                                   true;
                              ({_, _}) ->
                                   false
                           end, Stats),
    case List of
        [] ->
            nok;
        _  ->
            ok
    end.

test_versions_for_option_based_on_sni('tlsv1.3') ->
    {'tlsv1.2', ['tlsv1.3', 'tlsv1.2']};
test_versions_for_option_based_on_sni('tlsv1.2') ->
    {'tlsv1.1', ['tlsv1.2', 'tlsv1.1']}.

protocol_version_check(Socket, Version) ->
    case ssl:connection_information(Socket, [protocol]) of
        {ok, [{protocol, Version}]} ->
            ok;
        Other ->
            ct:fail({expected, Version, got, Other})
    end.

log(#{msg:={report,_Report}},#{config:=Pid}) ->
    Pid ! warning_generated;
log(_,_) ->
    ok.

length_exclusive({3,_} = Version) ->
    length(exclusive_default_up_to_version(Version, [])) +
        length(exclusive_non_default_up_to_version(Version, []));
length_exclusive({254,_} = Version) ->
    length(dtls_exclusive_default_up_to_version(Version, [])) +
        length(dtls_exclusive_non_default_up_to_version(Version, [])).

length_all(Version) ->
    length(ssl:cipher_suites(all, Version)).

exclusive_default_up_to_version({3, 1} = Version, Acc) ->
    ssl:cipher_suites(exclusive, Version) ++ Acc;
exclusive_default_up_to_version({3, Minor} = Version, Acc) when Minor =< 4 ->
    Suites = ssl:cipher_suites(exclusive, Version),
    exclusive_default_up_to_version({3, Minor-1}, Suites ++ Acc).

dtls_exclusive_default_up_to_version({254, 255} = Version, Acc) ->
    ssl:cipher_suites(exclusive, Version) ++ Acc;
dtls_exclusive_default_up_to_version({254, 253} = Version, Acc) ->
    Suites = ssl:cipher_suites(exclusive, Version),
    dtls_exclusive_default_up_to_version({254, 255}, Suites ++ Acc).

exclusive_non_default_up_to_version({3, 1} = Version, Acc) ->
    exclusive_non_default_version(Version) ++ Acc;
exclusive_non_default_up_to_version({3, 4}, Acc) ->
    exclusive_non_default_up_to_version({3, 3}, Acc);
exclusive_non_default_up_to_version({3, Minor} = Version, Acc) when Minor =< 3 ->
    Suites = exclusive_non_default_version(Version),
    exclusive_non_default_up_to_version({3, Minor-1}, Suites ++ Acc).

dtls_exclusive_non_default_up_to_version({254, 255} = Version, Acc) ->
    dtls_exclusive_non_default_version(Version) ++ Acc;
dtls_exclusive_non_default_up_to_version({254, 253} = Version, Acc) ->
    Suites = dtls_exclusive_non_default_version(Version),
    dtls_exclusive_non_default_up_to_version({254, 255}, Suites ++ Acc).

exclusive_non_default_version({_, Minor}) ->
    tls_v1:psk_exclusive(Minor) ++
        tls_v1:srp_exclusive(Minor) ++
        tls_v1:rsa_exclusive(Minor) ++
        tls_v1:des_exclusive(Minor) ++
        tls_v1:rc4_exclusive(Minor).

dtls_exclusive_non_default_version(DTLSVersion) ->        
    {_,Minor} = ssl:tls_version(DTLSVersion),
    tls_v1:psk_exclusive(Minor) ++
        tls_v1:srp_exclusive(Minor) ++
        tls_v1:rsa_exclusive(Minor) ++ 
        tls_v1:des_exclusive(Minor).
