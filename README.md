# shellout

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

## Test

```bash
$ mix eunit
```

## Notice

*`shellout.{cmd}` is intended as a short-term solution. Users should
favor `gleam_stdlib`'s `gleam/os.{cmd}` (or its equivalent), once it exists.*
