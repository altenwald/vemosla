defmodule Vemosla.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      # remember change the version in rel/config.exs as well!
      version: "0.1.1",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      releases: releases()
    ]
  end

  defp releases do
    [
      vemosla: [
        applications: [
          vemosla: :permanent,
          vemosla_mail: :permanent,
          vemosla_web: :permanent,
          observer_cli: :permanent,
          logger_file_backend: :permanent
        ],
        steps: [:assemble]
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps/ folder.
  defp deps do
    [
      {:logger_file_backend, "~> 0.0", only: :prod},
      {:observer_cli, "~> 1.6", only: :prod},
      {:distillery, "~> 2.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  #
  # Aliases listed here are available only for this project
  # and cannot be accessed from applications inside the apps/ folder.
  defp aliases do
    [
      # run `mix setup` in all child apps
      setup: ["cmd mix setup"],
      "assets.compile": &compile_assets/1,
      "npm.install": &npm_install/1,
      release: [
        "local.hex --force",
        "local.rebar --force",
        "clean",
        "deps.get",
        "compile",
        "npm.install",
        "assets.compile",
        "phx.digest",
        "distillery.release --upgrade --env=prod"
      ]
    ]
  end

  defp compile_assets(_) do
    if File.dir?("apps/vemosla_web/priv/static"), do: File.rm_rf!("apps/vemosla_web/priv/static")
    webpack = "cd apps/vemosla_web/assets && node node_modules/webpack/bin/webpack.js"

    if Mix.env() != :prod do
      Mix.shell().cmd("#{webpack} --mode development")
    else
      Mix.shell().cmd("#{webpack} --mode production")
    end
  end

  defp npm_install(_) do
    Mix.shell().cmd("cd apps/vemosla_web/assets && npm i && npm rebuild node-sass")
  end
end
