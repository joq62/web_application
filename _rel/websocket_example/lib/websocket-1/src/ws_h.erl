%%% -------------------------------------------------------------------
%%% Author  : joq erlang
%%% Created : 
%%% Description :  
%%% websocket handler 
%%% Implemements Interface for StugKontroller
%%% Design principles
%%% > Only one @ the time
%%% > Timeout after inactive one min 
%%% > All state information are externalized
%%% 
%%% -------------------------------------------------------------------
-module(ws_h). 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("common_macros.hrl").

%% --------------------------------------------------------------------
-define(CALLBACK,stug_service).

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).


%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

init(Req, Opts) ->
	{cowboy_websocket, Req, Opts}.

%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

websocket_init(State) ->
    io:format("Session started ~p~n",[{?MODULE,?LINE, application:start(?CALLBACK),State}]),
   % application:start(?CALLBACK),
  %  Self=self(),
    Reply=?CALLBACK:init_callback(),
    {reply, {text, Reply},State}.

%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

websocket_handle({text, Data}, State) ->
    io:format("text ~p~n",[{?MODULE,?LINE,Data,State}]),
    Reply=?CALLBACK:text(Data),
    Response=case Reply of
		 {reply, Msg}->
		     {reply, {text, Msg}, State};
		 ok->
		     {ok, State}
	     end,
    Response.

%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

websocket_info(Info, State) ->
     Response=case Info of
		 {reply, Msg}->
		     {reply, {text, Msg}, State};
		 ok->
		     {ok, State}
	     end,
    Response.
