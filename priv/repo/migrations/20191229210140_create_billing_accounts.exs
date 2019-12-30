defmodule BankApi.Repo.Migrations.CreateBillingAccounts do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS \"pgcrypto\";")

    create table(:billing_accounts) do
      add(:code, :uuid, null: false, default: fragment("gen_random_uuid()"))
      add(:balance, :decimal, null: false, default: 1000)
      add(:user_id, references(:users), null: false)

      timestamps()
    end

    create(
      constraint("billing_accounts", :balance_must_be_positive, check: "balance > 0")
    )

    create(index(:billing_accounts, [:user_id]))
    create(index(:billing_accounts, [:code]))
  end

  def down do
    drop(table(:billing_accounts))
  end
end
