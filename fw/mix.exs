defmodule Fw.MixProject do
  use Mix.Project

  @app :fw
  @version "0.1.7"
  @all_targets [:rpi0]

  def project do [
      app: @app,
      version: @version,
      elixir: "~> 1.12",
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      aliases: [loadconfig: [&bootstrap/1]],
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Fw.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.7", runtime: false},
      {:shoehorn, "~> 0.7"},
      {:toolshed, "~> 0.2"},
      {:ring_logger, "~> 0.8"},
      {:logger_file_backend, "~> 0.0.12"},
      {:ui, path: "../ui"},
      {:lights, path: "../lights"},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.11.4", targets: @all_targets},
      {:nerves_pack, "~> 0.6.0", targets: @all_targets},
      {:busybox, "~> 0.1.5", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi0, "~> 1.17.1", runtime: false, targets: :rpi0},
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod
    ]
  end
end
