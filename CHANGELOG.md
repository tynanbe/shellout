# Changelog

## v1.0.0 - 2022-06-01

- Complete rewrite!
- The new `shellout` module gains the `CommandOpt`, `Lookup`, `Lookups`, and
  `StyleFlags` types, along with the `colors` and `displays` constants and the
  following functions for all compilation targets: `arguments`, `background`,
  `color`, `command`, `display`, `exit`, `style`, `which`.
- New `shellout_ffi` modules for Erlang and JavaScript.

## v0.1.1 - 2021-01-26

- Documentation update.

## v0.1.0 - 2021-01-25

- Initial release!
- The `shellout` module gains the `CmdOpt` and `CmdResult` types, along with the
  `cmd` function, a thin wrapper of `Elixir.System.cmd/3`.
