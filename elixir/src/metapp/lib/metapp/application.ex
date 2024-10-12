defmodule Metapp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MetappWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Metapp.PubSub},
      # Start Finch
      {Finch, name: Metapp.Finch},
      # Start the Endpoint (http/https)
      MetappWeb.Endpoint
      # Start a worker by calling: Metapp.Worker.start_link(arg)
      # {Metapp.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Metapp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MetappWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
