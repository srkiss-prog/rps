defmodule RpsLive.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RpsLiveWeb.Telemetry,
      RpsLive.Repo,
      {DNSCluster, query: Application.get_env(:rps_live, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: RpsLive.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: RpsLive.Finch},
      # Start a worker by calling: RpsLive.Worker.start_link(arg)
      # {RpsLive.Worker, arg},
      # Start to serve requests, typically the last entry
      RpsLiveWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RpsLive.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RpsLiveWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
