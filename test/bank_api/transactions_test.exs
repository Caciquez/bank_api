defmodule BankApi.TransactionsTest do
  use BankApi.DataCase

  alias BankApi.Transactions

  describe "transactions" do
    alias BankApi.Transactions.Transaction

    @valid_attrs %{type: "some type", value: "120.5"}
    @update_attrs %{type: "some updated type", value: "456.7"}
    @invalid_attrs %{type: nil, value: nil}

    def transaction_fixture(attrs \\ %{}) do
      {:ok, transaction} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Transactions.create_transaction()

      transaction
    end

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Transactions.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Transactions.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      assert {:ok, %Transaction{} = transaction} =
               Transactions.create_transaction(@valid_attrs)

      assert transaction.type == "some type"
      assert transaction.value == Decimal.new("120.5")
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()

      assert {:ok, %Transaction{} = transaction} =
               Transactions.update_transaction(transaction, @update_attrs)

      assert transaction.type == "some updated type"
      assert transaction.value == Decimal.new("456.7")
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Transactions.update_transaction(transaction, @invalid_attrs)

      assert transaction == Transactions.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Transactions.delete_transaction(transaction)

      assert_raise Ecto.NoResultsError, fn ->
        Transactions.get_transaction!(transaction.id)
      end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Transactions.change_transaction(transaction)
    end
  end
end
