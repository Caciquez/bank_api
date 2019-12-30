defmodule BankApi.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankApi.Accounts.BillingAccount
  alias BankApi.Transactions.Transaction

  @required_fields ~w(type value)a
  @optional_fields ~w(source_billing_account_id destination_billing_account_id)a

  defmodule Type do
    @moduledoc """
    Enum for an transaction type.
    """

    use Exnumerator, values: ["deposit", "withdraw", "transfer"]
  end

  schema "transactions" do
    field(:type, Type, null: false)
    field(:value, :decimal, null: false)
    belongs_to(:source_billing_account, BillingAccount)
    belongs_to(:destination_billing_account, BillingAccount)

    timestamps()
  end

  @doc false
  def changeset(%Transaction{} = transaction, attrs) do
    transaction
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
