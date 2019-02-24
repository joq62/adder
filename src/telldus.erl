%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : 
%%% Interface to telldus deamon 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(telldus).
-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("telldus/src/telldus_local.hrl").

-include("../include/tcp.hrl").
-include("../include/dns.hrl").
-include("../include/data.hrl").
-include("../include/dns_data.hrl").
%% --------------------------------------------------------------------


%% External exports
-export([restart/0,
	 get_all_info/0,
	 switch/2,
	 get_sensor_value/1,
	 tick/0
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
start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).

heart_beat()->
    gen_server:call(?MODULE, {heart_beat},5000).


tick()->
    gen_server:cast(?MODULE, {tick}).
restart()->
      gen_server:call(?MODULE, {restart},infinity).  
get_all_info()->
    gen_server:call(?MODULE, {get_all_info},infinity).

switch(on,Id)->
    gen_server:call(?MODULE, {switch,on,Id},infinity);
switch(off,Id)->
    gen_server:call(?MODULE, {switch,off,Id},infinity).

get_sensor_value(Id)->
    gen_server:call(?MODULE, {get_sensor_value,Id},infinity).
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
%% --------------------------------------------------------------------
init([]) ->
    io:format(" ~p~n",[{?MODULE,?LINE, os:cmd(?OSCMD_RESTART)}]),
    timer:sleep(?SWITCH_CMD_DELAY),
    {ok,MyIp}=application:get_env(ip_addr),
    {ok,Port}=application:get_env(port),
  %  {ok,ApplicationId}=application:get_env(application_id),
    {ok,DnsIp}=application:get_env(dns_ip_addr),
    {ok,DnsPort}=application:get_env(dns_port),
    {ok,ExportedServices}=application:get_env(exported_services),

    
    DnsInfo=[#dns_info{time_stamp="not_initiaded_time_stamp",
			service_id = ServiceId,
			ip_addr=MyIp,
			port=Port
		       }||ServiceId<-ExportedServices],
    spawn(fun()-> local_heart_beat(?HEARTBEAT_INTERVAL) end), 
    io:format(" ~p~n",[{?MODULE,started}]),
    {ok, #state{dns_info=DnsInfo,dns_addr={dns,DnsIp,DnsPort}}}.  

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call({restart}, _From, State) ->
    Reply=case os:cmd(?OSCMD_RESTART) of
	      []->
		  ok;
	      Err->
		  {error,[?MODULE,?LINE,Err]}
	  end,
    {reply, Reply, State};

handle_call({switch,on,Id}, _From, State) ->
    io:format("switch,on,Id ~p~n",[{?MODULE,?LINE, Id}]),
    Reply=os:cmd(?OSCMD_SWITCH_ON(Id)),
    timer:sleep(?SWITCH_CMD_DELAY),
    {reply, Reply, State};

handle_call({switch,off,Id}, _From, State) ->
    io:format("switch,off,Id ~p~n",[{?MODULE,?LINE, Id}]),
    Reply=os:cmd(?OSCMD_SWITCH_OFF(Id)),
    timer:sleep(?SWITCH_CMD_DELAY),
    {reply, Reply, State};

handle_call({get_sensor_value,Id}, _From, State) ->
    Reply=glurk,
 %   Pid_ctrl=self(),
 %   Pid_sensor=spawn(fun()->read_sensor(Id,Pid_ctrl) end),
 %   receive
%	{Pid_sensor,{Temp}}->
%	    Reply=Temp
 %   after ?INDOOR_TEMP_TIMOUT->
%	    Reply= "No temp info"
 %   end,    
    {reply, Reply, State};


handle_call({heart_beat},_, State) ->
    {dns,DnsIp,DnsPort}=State#state.dns_addr,
    [if_dns:cast("dns",{dns,dns_register,[DnsInfo]},{DnsIp,DnsPort})||DnsInfo<-State#state.dns_info],
    {reply,ok, State};

handle_call({stop}, _From, State) ->
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
    io:format("unmatched match cast ~p~n",[{Msg,?MODULE,time()}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(_Info, State) ->
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

read_sensor(SensorName,Pid)->
    Reply=glurk,
  %  io:format("read_sensor ~p~n",[{time(),?MODULE,?LINE}]),
   % {ok,Str}=?CALL_TELLDUS({get_all_info}),
 %   Str=os:cmd("tdtool --list"),
  %  P1=string:str(Str,SensorName),   
  %  S1=string:substr(Str,P1,string:len(SensorName)+15),
   % [_Sensor,ActualTemp,_Hum]=string:tokens(S1,"\n\t "),
   % S11=string:tokens(ActualTemp,"."),
   % [Temp|_R]=S11,
    %io:format("Temp ~p~n",[{time(),?MODULE,?LINE,Temp}]),
   % Pid!{self(),{Temp}}.
    ok.
%% --------------------------------------------------------------------
%% Function: tick/1
%% Description:if needed creates dets file with name ?MODULE, and
%% initates the debase
%% Returns: non
%% --------------------------------------------------------------------
local_heart_beat(Interval)->
%    io:format(" ~p~n",[{?MODULE,?LINE}]),
    timer:sleep(100),
    ?MODULE:heart_beat(),
    timer:sleep(Interval),

    spawn(fun()-> local_heart_beat(Interval) end).
%% --------------------------------------------------------------------
%% Function: tick/1
%% Description:if needed creates dets file with name ?MODULE, and
%% initates the debase
%% Returns: non
%% --------------------------------------------------------------------

