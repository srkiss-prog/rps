defmodule RpsLiveWeb.RPSLiveTest do
  use RpsLiveWeb.ConnCase

  import Phoenix.LiveViewTest
  import RpsLive.GameFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_rps(_) do
    rps = rps_fixture()
    %{rps: rps}
  end

  describe "Index" do
    setup [:create_rps]

    test "lists all games", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/games")

      assert html =~ "Listing Games"
    end

    test "saves new rps", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/games")

      assert index_live |> element("a", "New Rps") |> render_click() =~
               "New Rps"

      assert_patch(index_live, ~p"/games/new")

      assert index_live
             |> form("#rps-form", rps: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#rps-form", rps: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/games")

      html = render(index_live)
      assert html =~ "Rps created successfully"
    end

    test "updates rps in listing", %{conn: conn, rps: rps} do
      {:ok, index_live, _html} = live(conn, ~p"/games")

      assert index_live |> element("#games-#{rps.id} a", "Edit") |> render_click() =~
               "Edit Rps"

      assert_patch(index_live, ~p"/games/#{rps}/edit")

      assert index_live
             |> form("#rps-form", rps: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#rps-form", rps: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/games")

      html = render(index_live)
      assert html =~ "Rps updated successfully"
    end

    test "deletes rps in listing", %{conn: conn, rps: rps} do
      {:ok, index_live, _html} = live(conn, ~p"/games")

      assert index_live |> element("#games-#{rps.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#games-#{rps.id}")
    end
  end

  describe "Show" do
    setup [:create_rps]

    test "displays rps", %{conn: conn, rps: rps} do
      {:ok, _show_live, html} = live(conn, ~p"/games/#{rps}")

      assert html =~ "Show Rps"
    end

    test "updates rps within modal", %{conn: conn, rps: rps} do
      {:ok, show_live, _html} = live(conn, ~p"/games/#{rps}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Rps"

      assert_patch(show_live, ~p"/games/#{rps}/show/edit")

      assert show_live
             |> form("#rps-form", rps: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#rps-form", rps: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/games/#{rps}")

      html = render(show_live)
      assert html =~ "Rps updated successfully"
    end
  end
end
