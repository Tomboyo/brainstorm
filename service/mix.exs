defmodule Service.MixProject do
  use Mix.Project

  def project do
    [
      app: :service,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application, do: [
    #extra_applications: [:logger]
    mod: { Service.Application, [] }
  ]

  defp deps, do: [
    { :plug_cowboy, "~> 2.1.0" },
    { :jason, "~> 1.1.2" }
  ]
end
