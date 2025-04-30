defmodule RpsLiveWeb.Rps do
  use RpsLiveWeb, :live_view

  @choices [:rock, :paper, :scissors]
  @initial_timer 19
  @restart_timer 3

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        authenticated?: false,
        auth_timeout_ref: nil,
        name: nil,
        fingerprint: nil,
        user_choice: nil,
        cpu_choice: nil,
        result: nil,
        loading: false,
        spinner_emoji: "🧠",
        bounce_count: 0,
        countdown: nil,
        timer: nil,
        timer_running: false,
        restart_timer: nil,
        choice_enabled: false,
        score: %{player: 0, draw: 0, cpu: 0}
      )




    if connected?(socket) do
      # Start a short timer (2 seconds) to wait for auth
      ref = Process.send_after(self(), :auth_timeout, 2000)
      {:ok, assign(socket, auth_timeout_ref: ref)}
    else
      {:ok, socket}
    end
  end


  def handle_event("auth", %{"name" => name, "fp" => fp}, socket) do
    if valid_name?(name) and valid_fp?(fp) do
      if socket.assigns.auth_timeout_ref do
        Process.cancel_timer(socket.assigns.auth_timeout_ref)
      end

      socket =
        assign(socket,
          authenticated?: true,
          auth_timeout_ref: nil,
          name: name,
          fingerprint: fp,
          timer: @initial_timer,
          timer_running: true,
          user_choice: nil,
          cpu_choice: nil,
          result: nil,
          loading: false,
          spinner_emoji: "🧠",
          bounce_count: 0,
          countdown: nil,
          restart_timer: nil,
          choice_enabled: true,
        )

      Process.send_after(self(), :tick, 1000)

      {:noreply, socket}
    else
      {:noreply, redirect(socket, to: "/")}
    end
  end

  def handle_info(:auth_timeout, socket) do
    if socket.assigns.authenticated? == false do
      {:noreply, redirect(socket, to: "/")}
    else
      {:noreply, socket}
    end
  end


  # Simple validations
  defp valid_name?(name), do: String.length(name) >= 3 and String.length(name) <= 13 and name =~ ~r/^[a-zA-Z0-9]+$/
  defp valid_fp?(fp), do: String.length(fp) > 5




  def handle_event("choose", %{"choice" => choice}, socket) do
    user_choice = String.to_existing_atom(choice)

    socket =
      socket
      |> assign(
        user_choice: user_choice,
        cpu_choice: nil,
        result: nil,
        loading: true,
        bounce_count: 0,
        countdown: nil,
        timer_running: false,
        choice_enabled: false  # DISABLE after choice
      )


    # Start bouncing animation
    Process.send_after(self(), :bounce, 300)

    {:noreply, socket}
  end


  def handle_info(:bounce, socket) do
    if socket.assigns.bounce_count < 5 do
      # keep bouncing
      Process.send_after(self(), :bounce, 300)
      {:noreply, update(socket, :bounce_count, &(&1 + 1))}
    else
      # Done bouncing -> show result
      cpu_choice = Enum.random(@choices)
      result = determine_winner(socket.assigns.user_choice, cpu_choice)
      score = update_score(socket.assigns.score, result)


      socket =
        assign(socket,
          cpu_choice: cpu_choice,
          result: result,
          loading: false,
          countdown: nil,
          timer_running: false,
          restart_timer: nil,
          score: score
        )

      # First return {:noreply, socket}
      # Then schedule countdown after 1 second
      Process.send_after(self(), :start_restart_countdown, 1000)

      {:noreply, socket}
    end
  end




  def handle_info(:start_restart_countdown, socket) do
    socket =
      assign(socket,
        restart_timer: @restart_timer
      )

    Process.send_after(self(), :restart_tick, 1000)

    {:noreply, socket}
  end




  def handle_info(:tick, socket) do
  cond do
    socket.assigns.timer_running == false ->
      # If timer is stopped (during bouncing, game over, etc.), do nothing
      {:noreply, socket}

    socket.assigns.timer > 0 ->
      # Decrease timer
      Process.send_after(self(), :tick, 1000)
      {:noreply, update(socket, :timer, &(&1 - 1))}

    true ->
      # Timer reached 0 ➔ Game over!
      {:noreply,
        assign(socket,
          result: :timeout,
          user_choice: nil,
          cpu_choice: nil,
          loading: false,
          countdown: nil,
          timer_running: false,
          choice_enabled: false
        )}
    end
  end





  def handle_info(:restart_tick, socket) do
    cond do
      socket.assigns.restart_timer && socket.assigns.restart_timer > 1 ->
        Process.send_after(self(), :restart_tick, 1000)
        {:noreply, update(socket, :restart_timer, &(&1 - 1))}

      socket.assigns.restart_timer == 1 ->


        Process.send_after(self(), :tick, 1000)

        {:noreply, reset_game(socket)}

      true ->
        {:noreply, socket}
    end
  end


  defp reset_game(socket) do
    assign(socket,
      user_choice: nil,
      cpu_choice: nil,
      result: nil,
      loading: false,
      spinner_emoji: "🧠",
      bounce_count: 0,
      countdown: nil,
      timer: @initial_timer,
      timer_running: true,
      restart_timer: nil,
      choice_enabled: true
    )
    end


  defp choice_to_emoji(:rock), do: "🪨"
  defp choice_to_emoji(:paper), do: "📄"
  defp choice_to_emoji(:scissors), do: "✂️"
  defp choice_to_emoji(_), do: "❓"


  defp determine_winner(choice, choice), do: :draw
  defp determine_winner(:rock, :scissors), do: :user
  defp determine_winner(:paper, :rock), do: :user
  defp determine_winner(:scissors, :paper), do: :user
  defp determine_winner(_, _), do: :cpu

  defp update_score(score, :user), do: %{score | player: score.player + 1}
  defp update_score(score, :cpu), do: %{score | cpu: score.cpu + 1}
  defp update_score(score, :draw), do: %{score | draw: score.draw + 1}
  defp update_score(score, _), do: score

end
