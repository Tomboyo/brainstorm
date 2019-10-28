defmodule Rest.MixProject do
  use Mix.Project

  def project, do: [
    app: :rest,
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

  def elixirc_paths(:test), do: [ "test/support", "lib" ]
  def elixirc_paths(_), do: [ "lib" ]

  def application, do: [
    extra_applications: [:logger],
    mod: {Rest.Application, []}
  ]

  defp deps, do: [
    { :plug_cowboy, "~> 2.1.0" },
    { :jason, "~> 1.1.2" },
    { :database, in_umbrella: true }
  ]
end
