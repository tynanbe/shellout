//// A Gleam wrapper for [`Elixir.System.cmd/3`](https://hexdocs.pm/elixir/master/System.html#cmd/3)
////

import gleam/atom
import gleam/dynamic.{Dynamic, atom, int, list, string}
import gleam/function
import gleam/list
import gleam/result
import gleam/string

pub type CmdOpt {
  Into(List(Nil))
  Cd(String)
  Env(List(tuple(String, String)))
  Arg0(String)
  StderrToStdout(Bool)
  Parallelism(Bool)
}

pub type CmdResult =
  Result(tuple(List(String), Int), String)

/// Executes the given `command` with `args`.
///
/// `command` is expected to be an executable available in PATH unless an
/// absolute path is given.
///
/// `args` must be a `List(String)` which the executable will receive as its
/// arguments as is. This means that:
/// - environment variables will not be interpolated
/// - wildcard expansion will not happen
/// - arguments do not need to be escaped or quoted for shell safety
///
/// This function returns a `Result`, where `success` is a
/// `tuple(List(String), Int)` containing a `List` of lines collected from
/// stdout, and the command exit status.
///
/// ## Examples
///
///    > shellout.cmd("printf", ["%s\n", "hi"], [])
///    Ok(tuple(["hi\n"], 0))
///
///    > let options = [Env([tuple("MIX_ENV", "test")])]
///    > shellout.cmd("printf", ["%s\n", "hi"], options)
///    Ok(tuple(["hi\n"], 0))
///
///    > shellout.cmd("", [], [StderrToStdout(True)])
///    Error("Error: Could not execute ``\n`` does not exist")
///
/// ## Options
///
/// - `Cd(String)` - the directory to run the command in
/// - `Env(List(tuple(String, String)))` - Tuples contain environment key-value
/// `String`s. The child process inherits all environment variables from its
/// parent process, the Gleam application, except those overwritten or cleared
/// using this option. Specify a value of `Nil` to clear (unset) an environment
/// variable, which is useful for preventing credentials passed to the
/// application from leaking into child processes.
/// - `Arg0(String)` - sets the command arg0
/// - `StderrToStdout(Bool)` - redirects stderr to stdout when `True`
/// - `Parallelism(Bool)` - when `True`, the VM will schedule port tasks to
/// improve parallelism in the system. If set to `False`, the VM will try to
/// perform commands immediately, improving latency at the expense of
/// parallelism. The default can be set on system startup by passing the "+spp"
/// argument to `--erl`.
///
/// *Documentation adapted from [`Elixir.System.cmd/3`](https://hexdocs.pm/elixir/master/System.html#cmd/3)*
///
pub fn cmd(
  bin command: String,
  args args: List(String),
  opts opts: List(CmdOpt),
) -> CmdResult {
  cmd_decoder(command, args, opts)
}

fn cmd_decoder(command, args, opts) -> CmdResult {
  let opts =
    opts
    |> list.append([Into([])])

  let default_error = tuple(
    atom.create_from_string("error"),
    atom.create_from_string("nil"),
  )

  fn() {
    external_cmd(command, args, opts)
    |> dynamic.typed_tuple2(
      fn(list) {
        list
        |> dynamic.typed_list(string)
      },
      int,
    )
  }
  |> function.rescue
  |> result.map_error(fn(exception) {
    let exception =
      exception
      |> dynamic.from
      |> dynamic.typed_tuple2(atom, atom)
      |> result.unwrap(or: default_error)

    let tuple(_type, reason) = exception
    let reason = case atom.to_string(reason) {
      "argument_error" -> "Invalid arguments given"
      "system_limit" -> "All Erlang emulator ports are in use"
      "enomem" -> "Not enough memory"
      "eagain" -> "No operating system processes available"
      "enametoolong" -> "Command name is too long"
      "emfile" -> "No available file descriptors"
      "enfile" -> "File table is full"
      "eacces" -> string.concat(["`", command, "` is not executable"])
      "enoent" -> string.concat(["`", command, "` does not exist"])
      _ -> "Unknown error"
    }

    string.concat(["Error: Could not execute `", command, "`\n", reason])
  })
  |> result.flatten
}

external fn external_cmd(String, List(String), List(CmdOpt)) -> Dynamic =
  "Elixir.System" "cmd"
