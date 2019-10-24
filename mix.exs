defmodule GenHttp.MixProject do
  use Mix.Project

  def project do
    [
      app: :gen_http,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod:
        {GenHttp.Application,
         [
           hosts: [
             #             "example.com": [port: 443, pool: 100],
             #             "anotherhost.org": [port: 443, pool: 100]
             localhost: [port: 4000, pool: 200]
           ]
         ]}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_stage, "~> 0.14"},
      {:castore, "~> 0.1.0"},
      {:mint, "~> 0.2.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
