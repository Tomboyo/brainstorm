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
    start_permanent: Mix.env() == :prod,
    deps: deps()
  ]

  def application, do: [
    extra_applications: [:logger],
    mod: { Database.Application, [] }
  ]

  defp deps, do: [
    { :bolt_sips, "~> 1.5.1" },
    { :toml, "~> 0.5.2" }
  ]
end
