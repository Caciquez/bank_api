defmodule BankApi.TransactionsTest do
  use BankApi.DataCase

  alias BankApi.Transactions
  alias BankApi.Transactions.Transaction

  @valid_attrs %{type: "deposit", value: "120.5"}
  @invalid_attrs %{type: nil, value: nil}

  describe "get_transaction/1" do
    test "returns the transaction with given id when it exists" do
      transaction = insert(:deposit)

      assert found_transaction = Transactions.get_transaction!(transaction.id)

      assert found_transaction.id == transaction.id
      assert found_transaction.value == transaction.value
      assert found_transaction.type == transaction.type
    end

    test "returns Ecto error if the  transaction with given id doesnt exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Transactions.get_transaction!(1)
      end
    end
  end

  describe "create_transaction/1" do
    test "creates transaction with valid data" do
      assert {:ok, %Transaction{} = transaction} =
               Transactions.create_transaction(@valid_attrs)

      assert transaction.type == "deposit"
      assert transaction.value == Decimal.new("120.5")
    end

    test "does not create a Transaction when required data are blank" do
      assert {:error, changeset} = Transactions.create_transaction(%{})
      assert %{type: ["Dado obrigatório"]} = errors_on(changeset)
      assert %{value: ["Dado obrigatório"]} = errors_on(changeset)
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_transaction(@invalid_attrs)
    end
  end

  describe "execute_transaction/2 for withdraws" do
    test "executes transaction with success when data is valid" do
      billing_account = insert(:billing_account)

      withdraw_params = %{
        "value" => 300,
        "source_billing_account_code" => billing_account.code,
        "type" => "withdraw"
      }

      assert {:ok, %Transaction{} = transaction} =
               Transactions.execute_transaction(withdraw_params, billing_account)

      assert transaction.type == withdraw_params["type"]
      assert transaction.value == Decimal.new(withdraw_params["value"])
    end

    test "returns error when transanction value greater than balance" do
      billing_account = insert(:billing_account)

      withdraw_params = %{
        "value" => 30_000,
        "source_billing_account_code" => billing_account.code,
        "type" => "withdraw"
      }

      assert_raise Ecto.ConstraintError, fn ->
        Transactions.execute_transaction(withdraw_params, billing_account)
      end
    end
  end

  describe "execute_transaction/2 for deposits" do
    test "executes transaction with success when data is valid" do
      billing_account = insert(:billing_account)

      deposit_params = %{
        "value" => 3000,
        "source_billing_account_code" => billing_account.code,
        "type" => "deposit"
      }

      assert {:ok, %Transaction{} = transaction} =
               Transactions.execute_transaction(deposit_params, billing_account)

      assert transaction.type == deposit_params["type"]
      assert transaction.value == Decimal.new(deposit_params["value"])
    end

    test "returns error when transanction value is lower than 0" do
      billing_account = insert(:billing_account)

      withdraw_params = %{
        "value" => -1000,
        "source_billing_account_code" => billing_account.code,
        "type" => "deposit"
      }

      assert {:error, :invalid_transaction_value} ==
               Transactions.execute_transaction(withdraw_params, billing_account)
    end
  end

  describe "execute_transaction/2 for transfer" do
    test "create_transaction/1 with valid data creates a transaction" do
      source_billing_account = insert(:billing_account)
      destination_billig_account = insert(:billing_account)

      transfer_params = %{
        "value" => 500,
        "source_billing_account_code" => source_billing_account.code,
        "destination_billing_account_code" => destination_billig_account.code,
        "type" => "transfer"
      }

      assert {:ok, %Transaction{} = transaction} =
               Transactions.execute_transaction(transfer_params, source_billing_account)

      assert transaction.type == transfer_params["type"]
      assert transaction.value == Decimal.new(transfer_params["value"])
    end

    test "create_transaction/1 with greater value than available" do
      source_billing_account = insert(:billing_account)
      destination_billig_account = insert(:billing_account)

      transfer_params = %{
        "value" => 30_000,
        "source_billing_account_code" => source_billing_account.code,
        "destination_billing_account_code" => destination_billig_account.code,
        "type" => "transfer"
      }

      assert_raise Ecto.ConstraintError, fn ->
        Transactions.execute_transaction(transfer_params, source_billing_account)
      end
    end
  end
end
