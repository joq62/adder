%% This is the application resource file (.app file) for the 'base'
%% application.
{application, telldus,
[{description, "Tellstick to control switch and sensord " },
{vsn, "1.0.0" },
{modules, 
	  [telldus_app,telldus_sup,telldus,telldus_mm,telldus_lib]},
{registered,[telldus]},
{applications, [kernel,stdlib]},
{mod, {telldus_app,[]}},
{start_phases, []}
]}.
