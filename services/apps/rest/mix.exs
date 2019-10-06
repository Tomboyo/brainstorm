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
    start_permanent: Mix.env() == :prod,
    deps: deps()
  ]

  def application, do: [
    extra_applications: [:logger],
    mod: {Rest.Application, []}
  ]

  defp deps, do: [
    { :plug_cowboy, "~> 2.1.0" },
    { :jason, "~> 1.1.2" }
  ]
end
