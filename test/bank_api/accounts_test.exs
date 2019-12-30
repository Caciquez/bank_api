defmodule BankApi.AccountsTest do
  use BankApi.DataCase

  alias BankApi.Accounts

  describe "billing_accounts" do
    alias BankApi.Accounts.BillingAccount

    @valid_attrs %{balance: "1000", code: "some code"}
    @update_attrs %{balance: "456.7", code: "some updated code"}
    @invalid_attrs %{balance: nil, code: nil}

    def billing_account_fixture(attrs \\ %{}) do
      {:ok, billing_account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_billing_account()

      billing_account
    end

    test "get_billing_account!/1 returns the billing_account with given id" do
      billing_account = billing_account_fixture()
      assert Accounts.get_billing_account!(billing_account.id) == billing_account
    end

    test "create_billing_account/1 with valid data creates a billing_account" do
      assert {:ok, %BillingAccount{} = billing_account} =
               Accounts.create_billing_account(@valid_attrs)

      assert billing_account.balance == Decimal.new("120.5")
      assert billing_account.code == "some code"
    end

    test "create_billing_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_billing_account(@invalid_attrs)
    end

    test "update_billing_account/2 with valid data updates the billing_account" do
      billing_account = billing_account_fixture()

      assert {:ok, %BillingAccount{} = billing_account} =
               Accounts.update_billing_account(billing_account, @update_attrs)

      assert billing_account.balance == Decimal.new("456.7")
      assert billing_account.code == "some updated code"
    end

    test "update_billing_account/2 with invalid data returns error changeset" do
      billing_account = billing_account_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_billing_account(billing_account, @invalid_attrs)

      assert billing_account == Accounts.get_billing_account!(billing_account.id)
    end
  end
end
