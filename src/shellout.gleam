import gleam/int
import gleam/list
import gleam/map.{Map}
import gleam/result
import gleam/string

if erlang {
  import gleam/erlang
}

/// A list of tuples in which the first element of each tuple is a label and the
/// second element is a list of one or more number strings representing a
/// singular ANSI style.
///
/// ANSI styles are split into three categories, labeled `"display"`, `"color"`,
/// and `"background"`, primarily so a single color `Lookup` can work with both
/// foreground and background.
///
/// ## Examples
///
/// See the [`displays`](#displays) and [`colors`](#colors) constants, and the
/// [`Lookups`](#Lookups) type.
///
pub type Lookup =
  List(#(String, List(String)))

/// A list of tuples in which the first element of each tuple is a list of
/// [`Lookup`](#Lookup) labels and the second element is a [`Lookup`](#Lookup).
///
/// `Lookups` allow for customization, adding new styles to the specified
/// [`Lookup`](#Lookup) categories.
///
/// ## Examples
///
/// ```gleam
/// pub const lookups: Lookups = [
///   #(
///     ["color", "background"],
///     [
///       #("buttercup", ["252", "226", "174"]),
///       #("mint", ["182", "255", "234"]),
///       #("pink", ["255", "175", "243"]),
///     ],
///   ),
/// ]
/// ```
///
pub type Lookups =
  List(#(List(String), Lookup))

/// A map in which the keys are style categories, `"display"`, `"color"`, or
/// `"background"`, and the values are lists of style labels found within a
/// [`Lookup`](#Lookup).
///
/// ## Examples
///
/// See the [`display`](#display), [`color`](#color), and
/// [`background`](#background) functions.
///
pub type StyleFlags =
  Map(String, List(String))

/// A list of ANSI styles representing non-color display effects.
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

/// A list of ANSI styles representing the basic 16 terminal colors, 8 standard
/// and 8 bright.
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

/// Converts a list of `"display"` style labels into a
/// [`StyleFlags`](#StyleFlags).
///
/// ## Examples
///
/// ```gleam
/// > style(
/// >   "radical",
/// >   with: display(["bold", "italic", "tubular"]),
/// >   custom: [],
/// > )
/// "\e[1;3mradical\e[0m\e[K"
/// ```
///
pub fn display(values: List(String)) -> StyleFlags {
  map.from_list([#("display", values)])
}

/// Converts a list of `"color"` style labels into a
/// [`StyleFlags`](#StyleFlags).
///
/// ## Examples
///
/// ```gleam
/// > style(
/// >   "uh...",
/// >   with: color(["yellow", "brightgreen", "gnarly"]),
/// >   custom: [],
/// > )
/// "\e[33;92muh...\e[0m\e[K"
/// ```
///
pub fn color(values: List(String)) -> StyleFlags {
  map.from_list([#("color", values)])
}

/// Converts a list of `"background"` style labels into a
/// [`StyleFlags`](#StyleFlags).
///
/// ## Examples
///
/// ```gleam
/// > style(
/// >   "awesome",
/// >   with: background(["yellow", "brightgreen", "bodacious"]),
/// >   custom: [],
/// > )
/// "\e[43;102mawesome\e[0m\e[K"
/// ```
///
pub fn background(values: List(String)) -> StyleFlags {
  map.from_list([#("background", values)])
}

/// Applies ANSI styles to a string, resetting styling at the end.
///
/// If a style label isn't found within a [`Lookup`](#Lookup) associated with
/// the corresponding [`StyleFlags`](#StyleFlags) key's category, that label is
/// silently ignored.
///
/// ## Examples
///
/// ```gleam
/// > import gleam/map
/// > pub const lookups: Lookups = [
/// >   #(
/// >     ["color", "background"],
/// >     [
/// >       #("buttercup", ["252", "226", "174"]),
/// >       #("mint", ["182", "255", "234"]),
/// >       #("pink", ["255", "175", "243"]),
/// >     ],
/// >   ),
/// > ]
/// > style(
/// >   "cowabunga",
/// >   with: display(["bold", "italic", "awesome"])
/// >   |> map.merge(color(["pink", "righteous"]))
/// >   |> map.merge(background(["brightblack", "excellent"])),
/// >   custom: lookups,
/// > )
/// "\e[1;3;38;2;255;175;243;100mcowabunga\e[0m\e[K"
/// ```
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

/// Retrieves a list of strings corresponding to any extra arguments passed when
/// invoking a runtime—via `gleam run`, for example.
///
/// ## Examples
///
/// ```gleam
/// // $ gleam run -- pizza --order=5 --anchovies=false
/// > arguments()
/// ["pizza", "--order=5", "--anchovies=false"]
/// ```
///
/// ```gleam
/// // $ gleam run --target=javascript
/// > arguments()
/// []
/// ```
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
  fn do_arguments() -> List(String) {
    do_arguments_ffi()
		// This is a work around around a bug introduced in 0.26.0:
    |> list.filter(fn(arg) {
      arg != "--" && string.ends_with(arg, "/gleam.main.mjs") == False
    })
  }

  external fn do_arguments_ffi() -> List(String) =
    "./shellout_ffi.mjs" "start_arguments"
}

/// Options for controlling the behavior of [`command`](#command).
///
pub type CommandOpt {
  /// Don't capture the standard error stream, let it behave as usual.
  ///
  LetBeStderr
  /// Don't capture the standard output stream, let it behave as usual.
  ///
  /// When targeting Erlang, this option also implies `LetBeStderr`.
  ///
  /// When targeting JavaScript, this option also enables `SIGINT` (`Ctrl+C`) to
  /// pass through to the spawned process.
  ///
  LetBeStdout
  /// Overlap the standard input and output streams.
  ///
  /// This option is specific to the Windows platform and otherwise ignored;
  /// however, when targeting JavaScript, this option prevents the standard
  /// input stream from behaving as usual.
  ///
  OverlappedStdio
}

/// Results in any output captured from the given `executable` on success, or an
/// `Error` on failure.
///
/// An `Error` result wraps a tuple in which the first element is an OS error
/// status code and the second is a message about what went wrong (or an empty
/// string).
///
/// The `executable` is given `arguments` and run from within the given
/// `directory`.
///
/// Any number of [`CommandOpt`](#CommandOpt) options can be given to alter the
/// behavior of this function.
///
/// The standard error stream is by default redirected to the standard output
/// stream, and both are captured. When targeting JavaScript, anything captured
/// from the standard error stream is appended to anything captured from the
/// standard output stream.
///
/// The standard input stream is by default handled in
/// [raw mode](https://www.wikiwand.com/en/Terminal_mode) when targeting
/// JavaScript, allowing full interaction with the spawned process. When
/// targeting Erlang, however, it's always handled in
/// [cooked mode](https://www.wikiwand.com/en/Terminal_mode).
///
/// Note that while `shellout` aims for near feature parity between runtimes,
/// some discrepancies exist and are documented herein.
///
/// ## Examples
///
/// ```gleam
/// > command(run: "echo", with: ["-n", "Cool!"], in: ".", opt: [])
/// Ok("Cool!")
/// ```
///
/// ```gleam
/// > command(run: "echo", with: ["Cool!"], in: ".", opt: [LetBeStdout])
/// // Cool!
/// Ok("")
/// ```
///
/// ```gleam
/// // $ stat -c '%a %U %n' /tmp/dimension_x
/// // 700 root /tmp/dimension_x
/// > command(run: "ls", with: ["dimension_x"], in: "/tmp", opt: [])
/// Error(#(2, "ls: cannot open directory 'dimension_x': Permission denied\n"))
/// ```
///
/// ```gleam
/// > command(run: "dimension_X", with: [], in: ".", opt: [])
/// Error(#(1, "command `dimension_x` not found\n"))
/// ```
///
/// ```gleam
/// // $ ls -p
/// // gleam.toml  manifest.toml  src/  test/
/// > command(run: "echo", with: [], in: "dimension_x", opt: [])
/// Error(#(2, "The directory \"dimension_x\" does not exist\n"))
/// ```
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

/// Halts the runtime and passes the given `status` code to the operating
/// system.
///
/// A `status` code of `0` typically indicates success, while any other integer
/// represents an error.
///
/// ## Examples
///
/// ```gleam
/// // $ gleam run && echo "Pizza time!"
/// > exit(0)
/// // Pizza time!
/// ```
///
/// ```gleam
/// // $ gleam run || echo "Ugh, shell shock ..."
/// > exit(1)
/// // Ugh, shell shock ...
/// ```
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

/// Results in a path to the given `executable` on success, or an `Error` when
/// no such path is found.
///
/// ## Examples
///
/// ```gleam
/// > which("echo")
/// Ok("/sbin/echo")
/// ```
///
/// ```gleam
/// > which("./priv/party")
/// Ok("./priv/party")
/// ```
///
/// ```gleam
/// > which("dimension_x")
/// Error("command `dimension_x` not found")
/// ```
///
pub fn which(executable: String) -> Result(String, String) {
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
