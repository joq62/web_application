all:
	@test -d deps || rebar get-deps	
	rebar compile
	cd web_service; make
