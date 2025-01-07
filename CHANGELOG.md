# Changelog

## Unreleased

- The environment of launched processes can now be customized using the
  `SetEnvironment` variant of `CommandOpt`.

## v1.6.0 - 2024-02-12

- Shellout now supports `gleam_stdlib` v1.0.
- Shellout now requires Gleam v0.34 or later.

## v1.5.0 - 2023-12-19

- Shellout now requires Gleam v0.33 or later.

## v1.4.0 - 2023-08-29

- Shellout now requires Gleam v0.30 or later.
- Shellout no longer depends on `gleam_erlang`.

## v1.3.0 - 2023-05-29

- Shellout now requires Gleam v0.29 or later.
- Shellout now supports `gleam_stdlib` v0.28.

## v1.2.0 - 2023-03-02

- Shellout now requires Gleam v0.27 or later.

## v1.1.1 - 2023-03-01

- Fixed a bug where `command` did not behave as expected with the Deno
  JavaScript runtime.
- Fixed a bug where `start_arguments` did not behave as expected with the Deno
  JavaScript runtime.

## v1.1.0 - 2023-02-08

- Shellout now supports the Deno JavaScript runtime (v1.30 or later).

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
