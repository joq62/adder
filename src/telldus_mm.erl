%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(telldus_mm).
 


%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("telldus/src/telldus_local.hrl").
%% --------------------------------------------------------------------

%% External exports
-compile(export_all).

%-export([load_start_node/3,stop_unload_node/3
%	]).


%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: switches
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
vaermdo_main_kitchen_heater_1(on)->
    rpc:call(node(),telldus,switch,[on,?vaermdo_main_kitchen_heater_1]);
vaermdo_main_kitchen_heater_1(off)->
    rpc:call(node(),telldus,switch,[off,?vaermdo_main_kitchen_heater_1]);
vaermdo_main_kitchen_heater_1(read)->
    rpc:call(node(),telldus,switch,[read,?vaermdo_main_kitchen_heater_1]);
vaermdo_main_kitchen_heater_1(X)->
    {error,[?MODULE,?LINE,'unmatched signal',X]}.


%% --------------------------------------------------------------------
%% Function: temp
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
%filter_events(Key

    
