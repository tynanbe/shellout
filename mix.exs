defmodule Shellout.MixProject do
  use Mix.Project

  def project do
    [
      app: :shellout,
      version: "0.1.0",
      description: "A Gleam wrapper for Elixir.System.cmd/3",
      package: %{
        files: [
          "gleam.toml",
          "LICENSE",
          "mix.exs",
          "NOTICE",
          "README.md",
          "src",
        ],
        licenses: ["Apache-2.0"],
        links: %{
          "GitHub" => "https://github.com/tynanbe/shellout",
        },
      },
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      erlc_paths: ["src", "gen"],
      compilers: [:gleam | Mix.compilers()],
      deps: deps(),
      preferred_cli_env: [eunit: :test],
    ]
  end

  def application do
    [
      extra_applications: [:logger],
    ]
  end

  defp deps do
    [
      {:gleam_stdlib, "~> 0.13"},
      {:mix_eunit, "~> 0.3"},
      {:mix_gleam, "~> 0.1"},
    ]
  end
end
