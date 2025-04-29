defmodule RpsLiveWeb.Login do
  use RpsLiveWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, name: "", error: nil, login_success: nil)}
  end

  def handle_event("submit", %{"name" => name}, socket) do
    case validate_name(name) do
      :ok ->
        fingerprint = generate_fingerprint(socket)

        {:noreply, assign(socket,
          login_success: %{name: name, fp: fingerprint},
          error: nil
        )}

      {:error, message} ->
        {:noreply, assign(socket, error: message, login_success: nil)}
    end
  end

  defp generate_fingerprint(socket) do
    "#{socket.id}-#{:crypto.strong_rand_bytes(4) |> Base.encode16()}"
  end

  defp validate_name(name) do
    name = String.trim(name)

    cond do
      String.length(name) < 3 ->
        {:error, "Name must be at least 3 characters long."}

      String.length(name) > 100 ->
        {:error, "Name must be at most 100 characters long."}

      not Regex.match?(~r/^[a-zA-Z0-9]+$/, name) ->
        {:error, "Name must be alphanumeric (only letters and numbers allowed)."}

      true ->
        :ok
    end
  end
end
