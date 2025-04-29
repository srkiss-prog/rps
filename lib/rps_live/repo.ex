defmodule RpsLive.Repo do
  use Ecto.Repo,
    otp_app: :rps_live,
    adapter: Ecto.Adapters.Postgres
end
