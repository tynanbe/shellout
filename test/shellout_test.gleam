import gleam/map
import gleam/string
import gleeunit
import gleeunit/should
import shellout.{Lookups}

pub fn main() {
  gleeunit.main()
}

pub fn command_test() {
  assert Ok(output) = shellout.command(run: "echo", with: [], in: ".", opt: [])
  output
  |> should.not_equal("")

  assert Error(#(status, _message)) =
    shellout.command(run: "", with: [""], in: ".", opt: [])
  status
  |> should.not_equal(0)
}

pub const lookups: Lookups = [
  #(
    ["color", "background"],
    [
      #("buttercup", ["252", "226", "174"]),
      #("mint", ["182", "255", "234"]),
      #("pink", ["255", "175", "243"]),
    ],
  ),
]

pub fn style_test() {
  let message = "Howdy!"
  let styled =
    message
    |> shellout.style(
      with: map.merge(
        shellout.color(["pink"]),
        shellout.display(["bold", "italic"]),
      ),
      custom: lookups,
    )
  styled
  |> string.starts_with(message)
  |> should.be_false
  styled
  |> string.ends_with(message)
  |> should.be_false
}
