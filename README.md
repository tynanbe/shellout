# shellout 🐢

[![Hex Package](https://img.shields.io/hexpm/v/shellout?color=ffaff3&label=%F0%9F%93%A6)](https://hex.pm/packages/shellout)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3?label=%F0%9F%93%9A)](https://hexdocs.pm/shellout/)
[![License](https://img.shields.io/hexpm/l/shellout?color=ffaff3&label=%F0%9F%93%83)](https://github.com/tynanbe/shellout/blob/main/LICENSE)
[![Build](https://img.shields.io/github/workflow/status/tynanbe/shellout/CI?color=ffaff3&label=%E2%9C%A8)](https://github.com/tynanbe/shellout/actions)

A Gleam library for cross-platform shell operations.

## Usage

```gleam
import gleam/io
import gleam/map
import shellout.{Lookups}

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
  let result =
    shellout.arguments()
    |> shellout.command(run: "ls", with: _, in: ".", opt: [])

  let status = case result {
    Ok(output) -> {
      io.print(output)
      0
    }
    Error(#(status, message)) -> {
      message
      |> shellout.style(
        with: map.merge(
          shellout.color(["pink"]),
          shellout.display(["bold", "italic"]),
        ),
        custom: lookups,
      )
      |> io.print
      status
    }
  }

  shellout.exit(status)
}
```

You can test the example above on the command line!

```shell
> gleam run -- -lah
# ..
> gleam run -- --lah
# ..
> gleam run --target=javascript -- -lah
# ..
> gleam run --target=javascript -- --lah
# ..
```

### As a dependency of your Gleam project

Add `shellout` to `gleam.toml`:

```toml
[dependencies]
shellout = "~> 1.0"
```

### As a dependency of your Mix project

Add `shellout` to `mix.exs`:

```elixir
{:shellout, "~> 1.0"},
```

### As a dependency of your Rebar3 project

Add `shellout` to `rebar.config`:

```erlang
{deps, [
  {shellout, "1.0.0"}
]}.
```