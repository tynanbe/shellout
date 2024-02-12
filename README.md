# shellout 🐢

[![Hex Package](https://img.shields.io/hexpm/v/shellout?color=ffaff3&label&labelColor=2f2f2f&logo=data:image/svg+xml;base64,PHN2ZyByb2xlPSJpbWciIHZpZXdCb3g9IjAgMCAyNCAyNCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cGF0aCBmaWxsPSIjZmVmZWZjIiBkPSJNIDYuMjgzMiwxLjU5OTYgOS4yODMyLDYuNzk0OSBIIDE0LjcwNTEgTCAxNy43MDUxLDEuNTk5NiBaIE0gMTguMTQwNywxLjg0MzggbCAtMyw1LjE5NzMgMi43MTQ5LDQuNjk5MiBoIDYgeiBNIDUuODUzNSwxLjg1NTUgMC4xNDQ1LDExLjc0MDIgSCA2LjE0NDUgTCA4Ljg1MTYsNy4wNDg4IFogTSAwLjE0NDUsMTIuMjQwMiA1Ljg1MzUsMjIuMTI3IDguODUxNiwxNi45MzM2IDYuMTQ0NSwxMi4yNDAyIFogbSAxNy43MTEsMCAtMi43MTQ5LDQuNzAxMiAzLDUuMTk1MyA1LjcxNDksLTkuODk2NSB6IE0gOS4yODMyLDE3LjE4NzUgNi4yODUyLDIyLjM4MDkgSCAxNy43MDMyIEwgMTQuNzA1MSwxNy4xODc1IFoiLz48L3N2Zz4K)](https://hex.pm/packages/shellout)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3?label&labelColor=2f2f2f&logo=data:image/svg+xml;base64,PHN2ZyByb2xlPSJpbWciIHZpZXdCb3g9IjAgMCAyNiAyOCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cGF0aCBmaWxsPSIjZmVmZWZjIiBkPSJNMjUuNjA5IDcuNDY5YzAuMzkxIDAuNTYyIDAuNSAxLjI5NyAwLjI4MSAyLjAxNmwtNC4yOTcgMTQuMTU2Yy0wLjM5MSAxLjMyOC0xLjc2NiAyLjM1OS0zLjEwOSAyLjM1OWgtMTQuNDIyYy0xLjU5NCAwLTMuMjk3LTEuMjY2LTMuODc1LTIuODkxLTAuMjUtMC43MDMtMC4yNS0xLjM5MS0wLjAzMS0xLjk4NCAwLjAzMS0wLjMxMyAwLjA5NC0wLjYyNSAwLjEwOS0xIDAuMDE2LTAuMjUtMC4xMjUtMC40NTMtMC4wOTQtMC42NDEgMC4wNjMtMC4zNzUgMC4zOTEtMC42NDEgMC42NDEtMS4wNjIgMC40NjktMC43ODEgMS0yLjA0NyAxLjE3Mi0yLjg1OSAwLjA3OC0wLjI5Ny0wLjA3OC0wLjY0MSAwLTAuOTA2IDAuMDc4LTAuMjk3IDAuMzc1LTAuNTE2IDAuNTMxLTAuNzk3IDAuNDIyLTAuNzE5IDAuOTY5LTIuMTA5IDEuMDQ3LTIuODQ0IDAuMDMxLTAuMzI4LTAuMTI1LTAuNjg4LTAuMDMxLTAuOTM4IDAuMTA5LTAuMzU5IDAuNDUzLTAuNTE2IDAuNjg4LTAuODI4IDAuMzc1LTAuNTE2IDEtMiAxLjA5NC0yLjgyOCAwLjAzMS0wLjI2Ni0wLjEyNS0wLjUzMS0wLjA3OC0wLjgxMiAwLjA2My0wLjI5NyAwLjQzOC0wLjYwOSAwLjY4OC0wLjk2OSAwLjY1Ni0wLjk2OSAwLjc4MS0zLjEwOSAyLjc2Ni0yLjU0N2wtMC4wMTYgMC4wNDdjMC4yNjYtMC4wNjMgMC41MzEtMC4xNDEgMC43OTctMC4xNDFoMTEuODkxYzAuNzM0IDAgMS4zOTEgMC4zMjggMS43ODEgMC44NzUgMC40MDYgMC41NjIgMC41IDEuMjk3IDAuMjgxIDIuMDMxbC00LjI4MSAxNC4xNTZjLTAuNzM0IDIuNDA2LTEuMTQxIDIuOTM4LTMuMTI1IDIuOTM4aC0xMy41NzhjLTAuMjAzIDAtMC40NTMgMC4wNDctMC41OTQgMC4yMzQtMC4xMjUgMC4xODctMC4xNDEgMC4zMjgtMC4wMTYgMC42NzIgMC4zMTMgMC45MDYgMS4zOTEgMS4wOTQgMi4yNSAxLjA5NGgxNC40MjJjMC41NzggMCAxLjI1LTAuMzI4IDEuNDIyLTAuODkxbDQuNjg4LTE1LjQyMmMwLjA5NC0wLjI5NyAwLjA5NC0wLjYwOSAwLjA3OC0wLjg5MSAwLjM1OSAwLjE0MSAwLjY4OCAwLjM1OSAwLjkyMiAwLjY3MnpNOC45ODQgNy41Yy0wLjA5NCAwLjI4MSAwLjA2MyAwLjUgMC4zNDQgMC41aDkuNWMwLjI2NiAwIDAuNTYyLTAuMjE5IDAuNjU2LTAuNWwwLjMyOC0xYzAuMDk0LTAuMjgxLTAuMDYzLTAuNS0wLjM0NC0wLjVoLTkuNWMtMC4yNjYgMC0wLjU2MiAwLjIxOS0wLjY1NiAwLjV6TTcuNjg4IDExLjVjLTAuMDk0IDAuMjgxIDAuMDYzIDAuNSAwLjM0NCAwLjVoOS41YzAuMjY2IDAgMC41NjItMC4yMTkgMC42NTYtMC41bDAuMzI4LTFjMC4wOTQtMC4yODEtMC4wNjMtMC41LTAuMzQ0LTAuNWgtOS41Yy0wLjI2NiAwLTAuNTYyIDAuMjE5LTAuNjU2IDAuNXoiPjwvcGF0aD48L3N2Zz4K)](https://hexdocs.pm/shellout/)
[![License](https://img.shields.io/hexpm/l/shellout?color=ffaff3&label&labelColor=2f2f2f&logo=data:image/svg+xml;base64,PHN2ZyB2ZXJzaW9uPSIxLjEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjM0IiBoZWlnaHQ9IjI4IiB2aWV3Qm94PSIwIDAgMzQgMjgiPgo8cGF0aCBmaWxsPSIjZmVmZWZjIiBkPSJNMjcgN2wtNiAxMWgxMnpNNyA3bC02IDExaDEyek0xOS44MjggNGMtMC4yOTcgMC44NDQtMC45ODQgMS41MzEtMS44MjggMS44Mjh2MjAuMTcyaDkuNWMwLjI4MSAwIDAuNSAwLjIxOSAwLjUgMC41djFjMCAwLjI4MS0wLjIxOSAwLjUtMC41IDAuNWgtMjFjLTAuMjgxIDAtMC41LTAuMjE5LTAuNS0wLjV2LTFjMC0wLjI4MSAwLjIxOS0wLjUgMC41LTAuNWg5LjV2LTIwLjE3MmMtMC44NDQtMC4yOTctMS41MzEtMC45ODQtMS44MjgtMS44MjhoLTcuNjcyYy0wLjI4MSAwLTAuNS0wLjIxOS0wLjUtMC41di0xYzAtMC4yODEgMC4yMTktMC41IDAuNS0wLjVoNy42NzJjMC40MjItMS4xNzIgMS41MTYtMiAyLjgyOC0yczIuNDA2IDAuODI4IDIuODI4IDJoNy42NzJjMC4yODEgMCAwLjUgMC4yMTkgMC41IDAuNXYxYzAgMC4yODEtMC4yMTkgMC41LTAuNSAwLjVoLTcuNjcyek0xNyA0LjI1YzAuNjg4IDAgMS4yNS0wLjU2MiAxLjI1LTEuMjVzLTAuNTYyLTEuMjUtMS4yNS0xLjI1LTEuMjUgMC41NjItMS4yNSAxLjI1IDAuNTYyIDEuMjUgMS4yNSAxLjI1ek0zNCAxOGMwIDMuMjE5LTQuNDUzIDQuNS03IDQuNXMtNy0xLjI4MS03LTQuNXYwYzAtMC42MDkgNS40NTMtMTAuMjY2IDYuMTI1LTExLjQ4NCAwLjE3Mi0wLjMxMyAwLjUxNi0wLjUxNiAwLjg3NS0wLjUxNnMwLjcwMyAwLjIwMyAwLjg3NSAwLjUxNmMwLjY3MiAxLjIxOSA2LjEyNSAxMC44NzUgNi4xMjUgMTEuNDg0djB6TTE0IDE4YzAgMy4yMTktNC40NTMgNC41LTcgNC41cy03LTEuMjgxLTctNC41djBjMC0wLjYwOSA1LjQ1My0xMC4yNjYgNi4xMjUtMTEuNDg0IDAuMTcyLTAuMzEzIDAuNTE2LTAuNTE2IDAuODc1LTAuNTE2czAuNzAzIDAuMjAzIDAuODc1IDAuNTE2YzAuNjcyIDEuMjE5IDYuMTI1IDEwLjg3NSA2LjEyNSAxMS40ODR6Ij48L3BhdGg+Cjwvc3ZnPgo=)](https://github.com/tynanbe/shellout/blob/main/LICENSE)
[![Build](https://img.shields.io/github/actions/workflow/status/tynanbe/shellout/ci.yml?branch=main&color=ffaff3&label&labelColor=2f2f2f&logo=github-actions&logoColor=fefefc)](https://github.com/tynanbe/shellout/actions)

A Gleam library for cross-platform shell operations.

<br>

## Usage

### Example

• In `my_project/src/my_project.gleam`

```gleam
import gleam/dict
import gleam/io
import gleam/result
import shellout.{type Lookups}

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

pub fn main() {
  shellout.arguments()
  |> shellout.command(run: "ls", in: ".", opt: [])
  |> result.map(with: fn(output) {
    io.print(output)
    0
  })
  |> result.map_error(with: fn(detail) {
    let #(status, message) = detail
    let style =
      shellout.display(["bold", "italic"])
      |> dict.merge(from: shellout.color(["pink"]))
      |> dict.merge(from: shellout.background(["brightblack"]))
    message
    |> shellout.style(with: style, custom: lookups)
    |> io.print_error
    status
  })
  |> result.unwrap_both
  |> shellout.exit
}
```

### 🐚 You can test the above example with your shell!

• In your terminal

```shell
> cd my_project
> gleam run -- -lah
# ..
> gleam run -- --lah
# ..
> gleam run --target=javascript -- -lah
# ..
> gleam run --target=javascript -- --lah
# ..
```

<br>

## Installation

### As a dependency of your Gleam project

• Add `shellout` to `gleam.toml`

```shell
gleam add shellout
```

### As a dependency of your Mix project

• Add `shellout` to `mix.exs`

```elixir
defp deps do
  [
    {:shellout, "~> 1.6"},
  ]
end
```

### As a dependency of your Rebar3 project

• Add `shellout` to `rebar.config`

```erlang
{deps, [
  {shellout, "1.6.0"}
]}.
```
