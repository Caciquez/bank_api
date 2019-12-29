defmodule BankApiWeb.UserController do
  use BankApiWeb, :controller

  alias BankApi.Customers
  alias BankApi.Customers.User
  alias BankApi.Guardian

  action_fallback(BankApiWeb.FallbackController)

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Customers.create_user(user_params),
         {:ok, token, _} <-
           Guardian.encode_and_sign(user) do
      render(conn, "show.json", user: Map.put(user, :token, token))
    end
  end

  @spec login(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def login(conn, %{"email" => email, "password" => password}) do
    with %User{} = user <- Customers.get_user_by_email(email),
         {:ok, _user} <- Bcrypt.check_pass(user, password),
         {:ok, token, _} <- Guardian.encode_and_sign(user) do
      render(conn, "show.json", user: Map.put(user, :token, token))
    end
  end
end
