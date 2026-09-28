defmodule Payrails.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/your-org/payrails_ex"

  def project do
    [
      app: :payrails_ex,
      version: @version,
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "PayrailsEx",
      description: "Elixir SDK for the Payrails API",
      source_url: @source_url,
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets, :ssl, :crypto, :public_key],
      mod: {Payrails.Application, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.35", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "Payrails",
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
