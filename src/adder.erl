%%% -------------------------------------------------------------------
%%% Author  : Joq Erlang
%%% Description : test application calc
%%%  
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(adder).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("../interface/if_kubelet.hrl").
-include("../interface/if_monitor.hrl").

-include("adder/src/adder_local.hrl").

-include("../include/tcp.hrl").
-include("../include/dns.hrl").
-include("../include/data.hrl").
-include("../include/dns_data.hrl").
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------




-export([add/2,crash/0
	]).

-export([start/0,
	 stop/0,
	 heart_beat/0
	]).

%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================

%% Asynchrounus Signals



%% Gen server functions

start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).



%%-----------------------------------------------------------------------
heart_beat()->
    gen_server:call(?MODULE, {heart_beat},5000).



add(A,B)->
    gen_server:call(?MODULE, {add,A,B},infinity).

crash()->
    gen_server:call(?MODULE, {crash},infinity).

%%-----------------------------------------------------------------------


%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------
init([]) ->
    spawn(fun()-> local_heart_beat(?HEARTBEAT_INTERVAL) end), 
    io:format("Service ~p~n",[{?MODULE, 'started ',?LINE}]),
    kubelet:send("kubelet",?Register(atom_to_list(?MODULE))),
    {ok, #state{}}.   
    
%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (aterminate/2 is called)
%% --------------------------------------------------------------------

handle_call({add,A,B}, _From, State) ->
    {ok,App}=application:get_application(),
    AppLogMsg={atom_to_list(App),?MODULE,?LINE,{info,7,['request add ',A,B]}},
    Reply=kubelet:log(AppLogMsg),
   % Reply=rpc:call(node(),adder_lib,add,[A,B]),
    AppLogMsg={atom_to_list(App),?MODULE,?LINE,{info,7,['result  add ',A,B," = ", Reply]}},
    {reply, Reply, State};

handle_call({crash}, _From, State) ->
    A=0,
    Reply=1/A,
    {reply, Reply, State};


handle_call({heart_beat},_, State) ->
    kubelet:send("kubelet",?Register(atom_to_list(?MODULE))),   
    {reply,ok, State};

handle_call({stop}, _From, State) ->
    kubelet:send("kubelet",?DeRegister(atom_to_list(?MODULE))),  
    io:format("stop ~p~n",[{?MODULE,?LINE}]),
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------



handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{?MODULE,?LINE,Msg}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info({tcp_closed,_Port}, State) ->
  %  io:format("unmatched signal ~p~n",[{?MODULE,?LINE,tcp,Port,binary_to_term(Bin)}]),
    {noreply, State};

handle_info({tcp,_Port,_Bin}, State) ->
  %  io:format("unmatched signal ~p~n",[{?MODULE,?LINE,tcp,Port,binary_to_term(Bin)}]),
    {noreply, State};


handle_info(Info, State) ->
    io:format("unmatched match info ~p~n",[{?MODULE,?LINE,Info}]),
    {noreply, State}.


%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Internal functions
%% --------------------------------------------------------------------
    

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
local_heart_beat(Interval)->
%    io:format(" ~p~n",[{?MODULE,?LINE}]),
    timer:sleep(100),
    ?MODULE:heart_beat(),
    timer:sleep(Interval),
    spawn(fun()-> local_heart_beat(Interval) end).
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

