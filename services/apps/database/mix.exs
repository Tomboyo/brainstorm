defmodule Database.MixProject do
  use Mix.Project

  def project, do: [
    app: :database,
    version: "0.1.0",
    build_path: "../../_build",
    config_path: "../../config/config.exs",
    deps_path: "../../deps",
    lockfile: "../../mix.lock",
    elixir: "~> 1.9",
    elixirc_paths: elixirc_paths(Mix.env()),
    start_permanent: Mix.env() == :prod,
    deps: deps()
  ]

  def elixirc_paths(:test), do: [ "lib", "test_support" ]
  def elixirc_paths(_), do: [ "lib" ]

  def application, do: [
    extra_applications: [:logger],
    mod: { Database.Application, [] }
  ]

  defp deps, do: [
    { :bolt_sips, "~> 1.5.1" },
    { :toml, "~> 0.5.2" },
    { :elixir_uuid, "~> 1.2.0" }
  ]
end
