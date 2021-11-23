defmodule DocusignEx.Mixfile do
  use Mix.Project

  def project do
    [
      app: :docusign_ex,
      version: "2.0.0",
      elixir: "~> 1.9",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:mojito, "~> 0.7.10"},
      {:jason, "~> 1.2"},
      {:mock, "~> 0.3.7", only: :test},
      {:excoveralls, "~> 0.13.3", only: :test}
    ]
  end

  defp aliases do
    [
      ci: ["format --check-formatted", "test --cover"]
    ]
  end
end
