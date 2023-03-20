defmodule Ui.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ui,
      version: "0.1.3",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {Ui.Application, []}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ace, path: "/home/ejc/projects/elixir/Ace"},
      {:raxx, "~> 1.1.0"},
      {:jason, "~> 1.0"},
      {:raxx_view, path: "../raxx/extensions/raxx_view"},
      {:raxx_logger, "~> 0.2.2"},
      {:raxx_static, "~> 0.8.3"},
      {:raxx_session, "~> 0.2.0"},
      {:exsync, "~> 0.2.4", only: :dev}
    ]
  end

  defp aliases() do
    []
  end
end
