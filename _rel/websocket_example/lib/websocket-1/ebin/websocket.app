{application, 'websocket', [
	{description, "Cowboy Websocket example"},
	{vsn, "1"},
	{modules, ['container','dets_stug','lib_service','lib_service_app','lib_service_sup','misc_lib','pod','stug_service','stug_service_app','stug_service_sup','tcp_client','tcp_server','test_support','websocket_app','websocket_sup','ws_h','ws_h_org']},
	{registered, [websocket_sup]},
	{applications, [kernel,stdlib,cowboy]},
	{mod, {websocket_app, []}},
	{env, []}
]}.