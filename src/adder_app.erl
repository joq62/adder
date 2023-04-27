%%%-------------------------------------------------------------------
%% @doc adder public API
%% @end
%%%-------------------------------------------------------------------

-module(adder_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    adder_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
