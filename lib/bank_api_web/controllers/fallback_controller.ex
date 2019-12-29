defmodule BankApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use BankApiWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(BankApiWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(BankApiWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, "invalid password"}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Invalid Password"})
  end

  def call(conn, nil) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "Invalid Email"})
  end
end
