defmodule BankApi.Guardian do
  use Guardian, otp_app: :bank_api

  alias BankApi.Customers
  alias BankApi.Customers.User

  def subject_for_token(%User{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => id}) do
    {:ok, Customers.get_user!(id)}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
