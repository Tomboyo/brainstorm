defmodule Services.MixProject do
  use Mix.Project

  def project, do: [
    apps_path: "apps",
    version: "0.1.0",
    start_permanent: Mix.env() == :prod,
    deps: deps(),
    releases: releases()
  ]

  defp deps, do: [
    { :dialyxir, "~> 1.0.0-rc.3" }
  ]

  defp releases, do: [
    default: [
      applications: [
        database: :permanent,
        rest:     :permanent
      ],
      include_executables_for: [:unix]
    ]
  ]

end
