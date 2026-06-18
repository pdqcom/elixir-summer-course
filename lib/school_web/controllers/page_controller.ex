defmodule SchoolWeb.PageController do
  use SchoolWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
