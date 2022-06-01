import gleam/int
import gleam/list
import gleam/map.{Map}
import gleam/result
import gleam/string

if erlang {
  import gleam/erlang
}

/// TODO
///
pub type Lookup =
  List(#(String, List(String)))

/// TODO
///
pub type Lookups =
  List(#(List(String), Lookup))

/// TODO
///
pub type StyleFlags =
  Map(String, List(String))

/// TODO
///
pub const displays: Lookup = [
  #("reset", ["0"]),
  #("bold", ["1"]),
  #("dim", ["2"]),
  #("italic", ["3"]),
  #("underline", ["4"]),
  #("blink", ["5"]),
  #("fastblink", ["6"]),
  #("reverse", ["7"]),
  #("hide", ["8"]),
  #("strike", ["9"]),
  #("normal", ["22"]),
  #("noitalic", ["23"]),
  #("nounderline", ["24"]),
  #("noblink", ["25"]),
  #("noreverse", ["27"]),
  #("nohide", ["28"]),
  #("nostrike", ["29"]),
]

/// TODO
///
pub const colors: Lookup = [
  #("black", ["30"]),
  #("red", ["31"]),
  #("green", ["32"]),
  #("yellow", ["33"]),
  #("blue", ["34"]),
  #("magenta", ["35"]),
  #("cyan", ["36"]),
  #("white", ["37"]),
  #("default", ["39"]),
  #("brightblack", ["90"]),
  #("brightred", ["91"]),
  #("brightgreen", ["92"]),
  #("brightyellow", ["93"]),
  #("brightblue", ["94"]),
  #("brightmagenta", ["95"]),
  #("brightcyan", ["96"]),
  #("brightwhite", ["97"]),
]

/// TODO
///
pub fn display(values: List(String)) -> StyleFlags {
  map.from_list([#("display", values)])
}

/// TODO
///
pub fn color(values: List(String)) -> StyleFlags {
  map.from_list([#("color", values)])
}

/// TODO
///
pub fn background(values: List(String)) -> StyleFlags {
  map.from_list([#("background", values)])
}

/// TODO
///
pub fn style(
  string: String,
  with flags: StyleFlags,
  custom lookups: Lookups,
) -> String {
  ["display", "color", "background"]
  |> list.map(with: fn(flag) {
    try strings = map.get(flags, flag)
    lookups
    |> list.filter_map(with: fn(item) {
      let #(keys, lookup) = item
      keys
      |> list.find(one_that: fn(key) { key == flag })
      |> result.map(with: fn(_) { lookup })
    })
    |> list.flatten
    |> do_style(strings, flag)
    |> Ok
  })
  |> result.values
  |> list.flatten
  |> string.join(with: ";")
  |> escape(string)
}

if erlang {
  fn escape(code: String, string: String) -> String {
    string.concat(["\e[", code, "m", string, "\e[0m\e[K"])
  }
}

if javascript {
  external fn escape(String, String) -> String =
    "./shellout_ffi.mjs" "escape"
}

type Style {
  Name(String)
  Rgb(List(String))
}

type StyleAcc {
  StyleAcc(styles: List(Style), rgb_counter: Int)
}

fn do_style(lookup: Lookup, strings: List(String), flag: String) -> List(String) {
  let lookup =
    case flag {
      "display" -> map.from_list(displays)
      "color" -> map.from_list(colors)
      "background" ->
        colors
        |> map.from_list
        |> map.map_values(with: fn(_key, code) {
          assert [code] = code
          assert Ok(code) = int.parse(code)
          [int.to_string(code + 10)]
        })
    }
    |> map.merge(from: map.from_list(lookup))

  let acc = StyleAcc(styles: [], rgb_counter: 0)
  let acc =
    strings
    |> list.fold(
      from: acc,
      with: fn(acc, item) {
        case int.parse(item) {
          Ok(int) -> {
            let item =
              int
              |> int.clamp(min: 0, max: 255)
              |> int.to_string
            let rgb_counter = acc.rgb_counter
            case rgb_counter < 3 {
              True if rgb_counter > 0 -> {
                let [Rgb(values), ..styles] = acc.styles
                StyleAcc(
                  styles: [Rgb([item, ..values]), ..styles],
                  rgb_counter: rgb_counter + 1,
                )
              }
              _ -> StyleAcc(styles: [Rgb([item]), ..acc.styles], rgb_counter: 1)
            }
          }
          _ -> StyleAcc(styles: [Name(item), ..acc.styles], rgb_counter: 0)
        }
      },
    )

  let prepare_rgb = fn(strings) {
    let new_strings =
      "0"
      |> list.repeat(times: 3 - list.length(strings))
      |> list.append(strings, _)
    let code = case flag {
      "color" -> "38"
      _ -> "48"
    }
    [code, "2", ..new_strings]
  }

  acc.styles
  |> list.reverse
  |> list.filter_map(with: fn(style) {
    case style {
      Name(string) ->
        lookup
        |> map.get(string)
        |> result.map(with: fn(strings) {
          case list.length(strings) > 1 {
            False -> strings
            True -> prepare_rgb(strings)
          }
        })
      Rgb(strings) ->
        strings
        |> list.reverse
        |> prepare_rgb
        |> Ok
    }
  })
  |> list.flatten
}

/// TODO
///
pub fn arguments() -> List(String) {
  do_arguments()
}

if erlang {
  fn do_arguments() -> List(String) {
    erlang.start_arguments()
  }
}

if javascript {
  external fn do_arguments() -> List(String) =
    "./shellout_ffi.mjs" "start_arguments"
}

/// TODO
///
pub type CommandOpt {
  // TODO
  LetBeStderr
  // TODO
  // Implies LetBeStderr with the Erlang target.
  LetBeStdout
  // TODO
  OverlappedStdio
}

/// TODO
///
/// By default, `stdout` is captured, and `stderr` is redirested to `stdin`.
///
/// With the JavaScript target, `stdin` is handled in
/// [raw mode](https://www.wikiwand.com/en/Terminal_mode). With the Erlang
/// target `stdin` is always handled in
/// [cooked mode](https://www.wikiwand.com/en/Terminal_mode).
///
/// Note that while `shellout` aims for near feature parity between compilation
/// targets, more advanced configurations are possible by using Node.js's
/// [`child_process`](https://nodejs.org/api/child_process.html) functions
/// directly.
///
pub fn command(
  run executable: String,
  with arguments: List(String),
  in directory: String,
  opt options: List(CommandOpt),
) -> Result(String, #(Int, String)) {
  options
  |> list.map(with: fn(opt) { #(opt, True) })
  |> map.from_list
  |> do_command(executable, arguments, directory, _)
}

if erlang {
  external fn do_command(
    String,
    List(String),
    String,
    Map(CommandOpt, Bool),
  ) -> Result(String, #(Int, String)) =
    "shellout_ffi" "os_command"
}

if javascript {
  external fn do_command(
    String,
    List(String),
    String,
    Map(CommandOpt, Bool),
  ) -> Result(String, #(Int, String)) =
    "./shellout_ffi.mjs" "os_command"
}

/// TODO
///
pub fn exit(status: Int) -> Nil {
  do_exit(status)
}

if erlang {
  external fn do_exit(status: Int) -> Nil =
    "erlang" "halt"
}

if javascript {
  external fn do_exit(status: Int) -> Nil =
    "" "process.exit"
}

/// TODO
///
pub fn which(executable: String) {
  do_which(executable)
}

if erlang {
  external fn do_which(String) -> Result(String, String) =
    "shellout_ffi" "os_which"
}

if javascript {
  external fn do_which(String) -> Result(String, String) =
    "./shellout_ffi.mjs" "os_which"
}
