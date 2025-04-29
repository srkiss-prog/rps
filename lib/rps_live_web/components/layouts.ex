defmodule RpsLiveWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use RpsLiveWeb, :controller` and
  `use RpsLiveWeb, :live_view`.
  """
  use RpsLiveWeb, :html

  embed_templates "layouts/*"
end
