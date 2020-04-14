%%% -------------------------------------------------------------------
%%% Author  : Joq Erlang
%%% Description : test application calc
%%%  
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(stug_service). 

-behaviour(gen_server). 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("common_macros.hrl").
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------
-record(state,{}).

%% Definitions 
-define(DETS_FILE,dets_stug).
%% --------------------------------------------------------------------




-export([init_callback/0,
	 text/1
	]).

-export([start/0,
	 stop/0,
	 ping/0,
	 get_state/0
	]).

%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================

%% Asynchrounus Signals



%% Gen server functions

start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).



%%-----------------------------------------------------------------------
text(Data)->
    gen_server:call(?MODULE, {text,Data},infinity).

init_callback()->
    gen_server:call(?MODULE, {init_callback},infinity).

ping()->
    gen_server:call(?MODULE, {ping},infinity).

get_state()->
    gen_server:call(?MODULE, {get_state},infinity).    


%%-----------------------------------------------------------------------

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
%
%% --------------------------------------------------------------------
init([]) ->
    ok=application:start(lib_service),
    case dets_stug:dets_exists() of
	false->
	    {ok,init}=dets_stug:init(set),
	    dets_stug:set(element,"off"),
	    dets_stug:set(lampor,"off"),
	    dets_stug:set(session_list,[]);
	true->
	    dets_stug:set(session_list,[])
    end,
    {ok, #state{}}.
%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (aterminate/2 is called)
%% --------------------------------------------------------------------
handle_call({init_callback}, {Pid,_}, State) ->
    Ref=erlang:monitor(process,Pid),
    io:format("~p~n",[{?MODULE,?LINE,time(),dets_stug:get(session_list),Pid,Ref}]),
    Reply=case dets_stug:get(session_list) of
	      []->
		  Cmd="init",
		  ElementStatus=dets_stug:get(element),
		  LamporStatus=dets_stug:get(lampor),
		  io:format("ElementStatus,LamporStatus ~p~n",[{?MODULE,?LINE,ElementStatus,LamporStatus}]),
		  Value="element,"++ElementStatus++",lampor,"++LamporStatus++",innetemp,20,utetemp,-3,Welcome",
		  io:format("Value ~p~n",[{?MODULE,?LINE,Value}]),
		  dets_stug:set(session_list,[{Pid,Ref}]),
		  list_to_binary(Cmd++","++Value);
	      SessionList->
		  Cmd="init",
		  ElementStatus=dets_stug:get(element),
		  LamporStatus=dets_stug:get(lampor),
		  Value="element,"++ElementStatus++",lampor,"++LamporStatus++",innetemp,20,utetemp,-3,Wait-someone in",
		  dets_stug:set(session_list,lists:reverse([{Pid,Ref}|SessionList])),
		  list_to_binary(Cmd++","++Value)
	  end,		  
    {reply, Reply, State};


handle_call({text, <<"element_clicked">>}, {Pid,_}, State) ->
    [{ActivePid,_}|T]=dets_stug:get(session_list),
    Reply=case ActivePid=:=Pid of
	      true->
		  Status=dets_stug:get(element),
		  case Status of
		      "off"->
			  Cmd="set",
			  Value="element,on",
			  dets_stug:set(element,"on"),
			  [P!{reply,list_to_binary(Cmd++","++Value)}||{P,_}<-T],
			  {reply,list_to_binary(Cmd++","++Value)};
		      "on"->
			  Cmd="set",
			  Value="element,off",
			  dets_stug:set(element,"off"),
			  [P!{reply,list_to_binary(Cmd++","++Value)}||{P,_}<-T],
			  {reply,list_to_binary(Cmd++","++Value)}
		  end;
	      false->
		  ok
	  end,
    {reply, Reply,State};

handle_call({text, <<"lampor_clicked">>}, {Pid,_}, State) ->
   [{ActivePid,_}|T]=dets_stug:get(session_list),
    Reply=case ActivePid=:=Pid of
	      true->
		  Status=dets_stug:get(lampor),
		  case Status of
		      "off"->
			  Cmd="set",
			  Value="lampor,on",
			  dets_stug:set(lampor,"on"),
			  [P!{reply,list_to_binary(Cmd++","++Value)}||{P,_}<-T],
			  {reply,list_to_binary(Cmd++","++Value)};
		      "on"->
			  Cmd="set",
			  Value="lampor,off",
			  dets_stug:set(lampor,"off"),
			  [P!{reply,list_to_binary(Cmd++","++Value)}||{P,_}<-T],
			  {reply,list_to_binary(Cmd++","++Value)}
		  end;
	      false->
		  ok
	  end,
    {reply, Reply,State};


handle_call({text, <<"avsluta_clicked">>}, _From, State) ->
    Cmd="quit",
    Value=" ",
    Reply={reply,list_to_binary(Cmd++","++Value)},
    io:format("Avsluta ~p~n",[{?MODULE,?LINE,Reply}]),
    {reply, Reply, State};


handle_call({ping}, _From, State) ->
    Reply={pong,node(),?MODULE},
    {reply, Reply, State};

handle_call({get_state}, _From, State) ->
     Reply=State,
    {reply, Reply, State};

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
    io:format("unmatched match cast ~p~n",[{?MODULE,?LINE,Msg}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({'DOWN',Ref,process,Pid,normal}, State) ->
    SessionList=dets_stug:get(session_list),
   % [{ActivePid,_}|T]
    NewSessionList=lists:keydelete(Pid,1,SessionList),
    dets_stug:set(session_list,NewSessionList),
    %case ActivePid=:=Pid of
%	true->
	   % [{NewActivePid,_}|T2]=T,
	   % send welcoem info to websocket
    io:format(" info = ~p~n",[{time(),?MODULE,?LINE,'DOWN',Ref,process,Pid,normal,NewSessionList}]),
    {noreply, State};

handle_info(Info, State) ->
    io:format("unmatched match info ~p~n",[{?MODULE,?LINE,Info}]),
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
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Internal functions
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

