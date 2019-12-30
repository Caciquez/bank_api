defmodule BankApi.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add(:type, :string, null: false)
      add(:value, :decimal, null: false)

      add(:source_billing_account_id, references(:billing_accounts, on_delete: :nothing))

      add(
        :destination_billing_account_id,
        references(:billing_accounts, on_delete: :nothing)
      )

      timestamps()
    end

    create(index(:transactions, [:source_billing_account_id]))
    create(index(:transactions, [:destination_billing_account_id]))
  end
end
