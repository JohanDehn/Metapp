defmodule MetappWeb.MetuiController do
  use MetappWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
