defmodule BankApi.Accounts.BillingAccount do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankApi.Customers.User

  @registration_required_fields ~w(balance user_id)a

  schema "billing_accounts" do
    field(:balance, :decimal, null: false, default: 1000)
    field(:code, Ecto.UUID, null: false)
    field(:user_id, :id)

    belongs_to(:users, User)

    timestamps()
  end

  @doc false
  def changeset(billing_account, attrs) do
    billing_account
    |> cast(attrs, @registration_required_fields)
    |> validate_required(@registration_required_fields, message: "Dado obrigatório")
  end
end
