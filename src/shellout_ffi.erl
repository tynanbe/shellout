-module(shellout_ffi).

-export([os_command/4, os_exit/1, os_which/1, start_arguments/0]).

os_command(Command, Args, Dir, Opts) ->
    Which =
        case os_which(Command) of
            {error, _} ->
                os_which(filename:join(Dir, Command));
            WhichResult ->
                WhichResult
        end,
    {ExitCode, Output} =
        case Which of
            {error, WhichError} ->
                {1, WhichError};
            {ok, Executable} ->
                ExecutableChars = binary_to_list(Executable),
                LetBeStdout = maps:get(let_be_stdout, Opts, false),
                PortSettings = lists:merge([
                    [
                        {args, Args},
                        {cd, Dir},
                        eof,
                        exit_status,
                        hide,
                        in
                    ],
                    case maps:get(overlapped_stdio, Opts, false) of
                        true -> [overlapped_io];
                        _ -> []
                    end,
                    case LetBeStdout or maps:get(let_be_stderr, Opts, false) of
                        true -> [];
                        _ -> [stderr_to_stdout]
                    end,
                    case LetBeStdout of
                        true -> [{line, 99999999}];
                        _ -> [stream]
                    end
                ]),
                Port = open_port({spawn_executable, ExecutableChars}, PortSettings),
                {Status, OutputChars} = get_data(Port, []),
                case LetBeStdout of
                    true -> {Status, <<>>};
                    _ -> {Status, list_to_binary(OutputChars)}
                end
        end,
    case ExitCode of
        0 ->
            {ok, Output};
        2 when Output == <<>> ->
            DirError = list_to_binary(
                "The directory \"" ++
                    binary_to_list(Dir) ++
                    "\" does not exist\n"
            ),
            {error, {ExitCode, DirError}};
        _ ->
            {error, {ExitCode, Output}}
    end.

get_data(Port, SoFar) ->
    receive
        {Port, {data, {Flag, Bytes}}} ->
            io:format("~ts", [
                list_to_binary(
                    case Flag of
                        eol -> [Bytes, $\n];
                        noeol -> [Bytes]
                    end
                )
            ]),
            get_data(Port, [SoFar | Bytes]);
        {Port, {data, Bytes}} ->
            get_data(Port, [SoFar | Bytes]);
        {Port, eof} ->
            Port ! {self(), close},
            receive
                {Port, closed} ->
                    true
            end,
            receive
                {'EXIT', Port, _} ->
                    ok
                % force context switch
            after 1 ->
                ok
            end,
            ExitCode =
                receive
                    {Port, {exit_status, Code}} ->
                        Code
                end,
            {ExitCode, lists:flatten(SoFar)}
    end.

os_exit(Status) ->
    halt(Status).

os_which(Command) ->
    CommandChars = binary_to_list(Command),
    {Result, OutputChars} =
        case os:find_executable(CommandChars) of
            false ->
                case filelib:is_file(CommandChars) of
                    false ->
                        ExecutableError =
                            "command `" ++ CommandChars ++ "` not found\n",
                        {error, ExecutableError};
                    true ->
                        {ok, CommandChars}
                end;
            Executable ->
                {ok, Executable}
        end,
    {Result, list_to_binary(OutputChars)}.

start_arguments() ->
    lists:map(fun unicode:characters_to_binary/1, init:get_plain_arguments()).
