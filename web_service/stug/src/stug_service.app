%% This is the application resource file (.app file) for the 'base'
%% application.
{application, stug_service,
[{description, "stug_service  " },
{vsn, "1.0.0" },
{modules, 
	  [stug_service_app,stug_service_sup,stug_service]},
{registered,[stug_service]},
{applications, [kernel,stdlib]},
{mod, {stug_service_app,[]}},
{start_phases, []}
]}.
