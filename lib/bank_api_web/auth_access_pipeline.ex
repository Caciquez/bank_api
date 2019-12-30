defmodule BankApi.Guardian.AuthAccessPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :bank_api,
    module: BankApi.Guardian,
    error_handler: BankApi.AuthErrorHandler

  plug(Guardian.Plug.VerifyHeader, realm: "Bearer")
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
end

defmodule BankApi.AuthErrorHandler do
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @spec auth_error(Plug.Conn.t(), {atom(), atom()}, list()) :: Plug.Conn.t()
  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{error: to_string(type)})
    send_resp(conn, 401, body)
  end
end
