%% service_info
%% Information of the servie
-record(state, {dns_info,dns_addr}).
%%

-define(SWITCH_CMD_DELAY,3*1000).

%% Commands
-define(OSCMD_RESTART,"sudo /etc/init.d/telldusd restart").
-define(OSCMD_SWITCH_ON(Id),"tdtool --on "++Id).
-define(OSCMD_SWITCH_OFF(Id),"tdtool --off "++Id).


%% Each instance of telldus needs to have a specific configuration file
%% that transaltes logical request to tellstick commands
%% NodeId: Node vaermdo_main_rp1
%% Services: must be added to a unique josca file per node tha manage the telldus
%% vaermdo_main_kitchen_heater_1
%% vaermdo_main_livingroom_heater_1
%% vaermdo_main_hallway_lamp_1
%% vaermdo_main_entrance_lamp_1
%% vaermdo_main_livingroom_temp
%% vaermdo_outdoor_temp
%% 
%% Information of the servie

-define(vaermdo_main_kitchen_heater_1,"4").
%-define(vaermdo_main_livingroom_heater_1,"5").
%-define(vaermdo_main_livingroom_temp,"137").
