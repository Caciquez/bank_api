defmodule BankApi.AccountsTest do
  use BankApi.DataCase, async: true

  alias BankApi.Accounts
  alias BankApi.Accounts.BillingAccount
  alias BankApi.Customers.User
  alias BankApi.Repo

  @valid_attrs %{balance: "1000"}
  @update_attrs %{balance: "456.7"}
  @invalid_attrs %{balance: nil, code: nil}

  describe "create_billing_account/1" do
    test "creates with valid data creates a billing_account" do
      user = insert(:user)

      assert {:ok, %BillingAccount{} = billing_account} =
               Accounts.create_billing_account(
                 Map.merge(@valid_attrs, %{user_id: user.id})
               )

      assert billing_account.balance == Decimal.new("1000")
    end

    test "does not create billing account with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_billing_account(@invalid_attrs)
    end

    test "does not create a billing account when required data are blank" do
      assert {:error, changeset} = Accounts.create_billing_account(%{})
      assert %{user_id: ["Dado obrigatório"]} = errors_on(changeset)
    end
  end

  describe "get_billing_account!/1" do
    test "returns the billing_account with given id" do
      billing_account = insert(:billing_account)

      assert billing_account.id
             |> Accounts.get_billing_account!()
             |> Repo.preload([:user]) ==
               billing_account
    end
  end

  describe "update_billing_account/2" do
    test "updates billing_account when data is valid" do
      billing_account = insert(:billing_account)

      assert {:ok, %BillingAccount{} = updated_billing_account} =
               Accounts.update_billing_account(billing_account, @update_attrs)

      assert updated_billing_account.balance == Decimal.new("456.7")
    end

    test "doesnt update billing_account with when data is invalid and returns error changeset" do
      billing_account = insert(:billing_account)

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_billing_account(billing_account, @invalid_attrs)

      assert billing_account ==
               billing_account.id
               |> Accounts.get_billing_account!()
               |> Repo.preload([:user])
    end
  end

  describe "get_billing_account_by_code/1" do
    test "returns billing_account if code exists" do
      billing_account = insert(:billing_account)

      assert billing_account.id ==
               Accounts.get_billing_account_by_code(billing_account.code).id
    end

    test "return error if billing_acount with code doesnt exist" do
      assert {:error, :not_found} =
               Accounts.get_billing_account_by_code(
                 "bc444263-79c2-4ebc-af1f-106df3c610bf"
               )
    end
  end

  describe "create_user_and_billing_account/1" do
    test "returns if transaction occurs with success" do
      user_attrs = %{
        "name" => "John Doe",
        "email" => "john.doe@example.com",
        "email_confirmation" => "john.doe@example.com",
        "password" => "123456789",
        "password_confirmation" => "123456789"
      }

      {:ok, billing_account, user} = Accounts.create_user_and_billing_account(user_attrs)
      assert %BillingAccount{} = billing_account
      assert %User{} = user
    end

    test "returns error and failed_value when transaction fails" do
      assert {:error, %Ecto.Changeset{} = failed_value} =
               Accounts.create_user_and_billing_account(%{})
    end
  end
end
