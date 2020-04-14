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
-module(ws_h_org). 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("common_macros.hrl").

%% --------------------------------------------------------------------
-record(loop_state,{lampor,element,temp}).

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
    io:format("Session started ~p~n",[{?MODULE,?LINE,State}]),
    LState=#loop_state{ lampor="off",element="off",temp="20"},
    Pid=spawn(fun()->loop(LState) end),
%	erlang:start_timer(1000, self(), <<"Hello!">>),
   
    Cmd="init",
    Value="element,off,lampor,off,innetemp,20,utetemp,-3",
    Reply=list_to_binary(Cmd++","++Value),
    NewState=[{pid,Pid},{element,"off"},{lampor,"off"}],
    {reply, {text, Reply}, NewState}.
%	{ok, [{pid,Pid},{element,"off"}]}.

%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

websocket_handle({text, <<"init">>}, State) ->
    io:format("Init ~p~n",[{?MODULE,?LINE,State}]),
    {element,Status}=lists:keyfind(element,1,State),
    {Reply,NewState} = case Status of
		"off"->
		   % NewState=lists:keyreplace(element, 1, State, {element,"on"}),
		    Cmd="set",
		    Value="element,on",
		    {list_to_binary(Cmd++","++Value),
		     lists:keyreplace(element, 1, State, {element,"on"})};
		"on"->
		  %  NewState=lists:keyreplace(element, 1, State, {element,"off"}),
		    Cmd="set",
		    Value="element,off",
		    {list_to_binary(Cmd++","++Value),
		     lists:keyreplace(element, 1, State, {element,"off"})}
	    end,
    io:format("element, Msg ~p~n",[{?MODULE,?LINE,elemet_clicked,Reply}]),
    {reply, {text, Reply}, NewState};

websocket_handle({text, <<"element_clicked">>}, State) ->
    {element,Status}=lists:keyfind(element,1,State),
    {Reply,NewState} = case Status of
		"off"->
		   % NewState=lists:keyreplace(element, 1, State, {element,"on"}),
		    Cmd="set",
		    Value="element,on",
		    {list_to_binary(Cmd++","++Value),
		     lists:keyreplace(element, 1, State, {element,"on"})};
		"on"->
		  %  NewState=lists:keyreplace(element, 1, State, {element,"off"}),
		    Cmd="set",
		    Value="element,off",
		    {list_to_binary(Cmd++","++Value),
		     lists:keyreplace(element, 1, State, {element,"off"})}
	    end,
    io:format("element, Msg ~p~n",[{?MODULE,?LINE,elemet_clicked,Reply}]),
    {reply, {text, Reply}, NewState};

websocket_handle({text, <<"lampor_clicked">>}, State) ->
    {lampor,Status}=lists:keyfind(lampor,1,State),
    {Reply,NewState} = case Status of
		"off"->
		   % NewState=lists:keyreplace(lampor, 1, State, {lampor,"on"}),
		    Cmd="set",
		    Value="lampor,on",
		    {list_to_binary(Cmd++","++Value),
		     lists:keyreplace(lampor, 1, State, {lampor,"on"})};
		"on"->
		  %  NewState=lists:keyreplace(lampor, 1, State, {lampor,"off"}),
		    Cmd="set",
		    Value="lampor,off",
		    {list_to_binary(Cmd++","++Value),
		     lists:keyreplace(lampor, 1, State, {lampor,"off"})}
	    end,
    io:format("lampor, Msg ~p~n",[{?MODULE,?LINE,lampor_clicked,Reply}]),
    {reply, {text, Reply}, NewState};

websocket_handle({text, <<"avsluta_clicked">>}, State) ->
    Cmd="quit",
    Value=" ",
    Reply=list_to_binary(Cmd++","++Value),
    io:format("Avsluta ~p~n",[{?MODULE,?LINE,Reply}]),
    {reply, {text, Reply}, State};
   
websocket_handle(Data, State) ->
    io:format("Data =  ~p~n",[{?MODULE,?LINE,Data}]),
    {ok, State}.

%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

websocket_info({timeout, _Ref, Msg}, State) ->
	erlang:start_timer(1000, self(), <<"How' you doin'?">>),
	{reply, {text, Msg}, State};
websocket_info(Info, State) ->
    io:format("Info ~p~n",[{?MODULE,?LINE,Info}]),
	{ok, State}.


loop(State)->
    NewState=receive
		 {Pid,{element_clicked}}->
		     case State#loop_state.element of
			 "off"->
			     Pid!{self(),"on"},
			     State#loop_state{element="on"};
			 "on" ->
			     Pid!{self(),"off"},
			     State#loop_state{element="off"}
		     end;
		 {Pid,{lamport_clicked}}->
		     case State#loop_state.lampor of
			 "off"->
			     Pid!{self(),"on"},
			     State#loop_state{lampor="on"};
			 "on" ->
			     Pid!{self(),"off"},
			     State#loop_state{lampor="off"}
		     end
	     end,
    loop(NewState).
