import gleam/map
import gleam/string
import gleeunit
import gleeunit/should
import shellout.{LetBeStderr, LetBeStdout, Lookups}

pub fn main() {
  gleeunit.main()
}

const message = "Howdy!"

const lookups: Lookups = [
  #(
    ["color", "background"],
    [
      #("buttercup", ["252", "226", "174"]),
      #("mint", ["182", "255", "234"]),
      #("pink", ["255", "175", "243"]),
    ],
  ),
]

pub fn arguments_test() {
  shellout.arguments()
  |> should.equal([])
}

pub fn command_test() {
  let echo = shellout.command(run: "echo", with: [message], in: ".", opt: _)

  assert Ok(output) = echo([])
  output
  |> should.not_equal("")

  assert Ok(new_output) = echo([LetBeStderr])
  new_output
  |> should.equal(output)

  assert Error(#(status, message)) =
    shellout.command(run: "", with: [], in: ".", opt: [LetBeStdout])
  status
  |> should.not_equal(0)
  should_be_without_stdout(message)

  assert Error(#(status, message)) =
    shellout.command(run: "dimension_x", with: [], in: ".", opt: [])
  status
  |> should.equal(1)
  message
  |> should.not_equal("")

  assert Error(#(status, message)) =
    shellout.command(run: "echo", with: [], in: "dimension_x", opt: [])
  status
  |> should.equal(2)
  message
  |> should.not_equal("")
}

if erlang {
  // Erlang ports can't separate stderr from stdout; it's all or nothing
  fn should_be_without_stdout(message) {
    message
    |> should.equal("")
  }
}

if javascript {
  fn should_be_without_stdout(message) {
    message
    |> should.not_equal("")
  }
}

pub fn style_test() {
  let styled =
    message
    |> shellout.style(with: shellout.background(["yellow"]), custom: [])
  styled
  |> string.starts_with(message)
  |> should.be_false
  styled
  |> string.ends_with(message)
  |> should.be_false

  let styled =
    message
    |> shellout.style(
      with: shellout.display(["bold", "italic"])
      |> map.merge(shellout.color(["pink"]))
      |> map.merge(shellout.background(["brightblack"])),
      custom: lookups,
    )
  styled
  |> string.starts_with(message)
  |> should.be_false
  styled
  |> string.ends_with(message)
  |> should.be_false
}

pub fn which_test() {
  "echo"
  |> shellout.which
  |> should.be_ok

  ""
  |> shellout.which
  |> should.be_error
}
