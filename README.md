# shellout

[![Hex Package](https://img.shields.io/hexpm/v/shellout?color=ffaff3&label=%F0%9F%93%A6)](https://hex.pm/packages/shellout)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3?label=%F0%9F%93%9A)](https://hexdocs.pm/shellout/)
[![License](https://img.shields.io/hexpm/l/shellout?color=ffaff3&label=%F0%9F%93%83)](https://hex.pm/packages/shellout)

A Gleam wrapper for [`Elixir.System.cmd/3`](https://hexdocs.pm/elixir/master/System.html#cmd/3)

## Usage

```gleam
import gleam/iterator
import shellout

try tuple(output, status) =
  shellout.cmd("ls", ["-lah"], [StderrToStdout(True)])

output
|> iterator.from_list
|> iterator.map(with: fn(line) { io.print(line) })
|> iterator.run

status
```

### As a dependency of your Mix project

Add shellout to `mix.exs`:

```elixir
{:shellout, "~> 0.1"},
```

Tooling improvements are in the works.
For now the following commands should work.

From your project's root dir:

```bash
$ mix deps.get
$ sh -c 'cd deps/shellout/ && mix deps.get && mix compile'
$ mix compile  # or mix escript.build, etc
```

## Test

```bash
$ mix eunit
```

## Notice

*`shellout.{cmd}` is intended as a short-term solution. Users should
favor `gleam_stdlib`'s `gleam/os.{cmd}` (or its equivalent), once it exists.*
