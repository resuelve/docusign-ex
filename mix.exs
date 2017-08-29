defmodule DocusignEx.Mixfile do
  use Mix.Project

  def project do
    [app: :docusign_ex,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger, :httpoison]]
  end

  defp deps do
    [
      {:httpoison,    "~> 0.11.1"},
      {:poison,       "~> 2.1 or ~> 3.1"},
      {:exprintf,     github: "parroty/exprintf"},
      {:excoveralls,  "~> 0.6.3", only: :test},
      {:credo, "~> 0.8.6", only: :test}
    ]
  end
end
