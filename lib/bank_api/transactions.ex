defmodule BankApi.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias BankApi.Accounts
  alias BankApi.Accounts.BillingAccount
  alias BankApi.Repo
  alias BankApi.Transactions.Transaction
  alias Ecto.Multi

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{source: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction) do
    Transaction.changeset(transaction, %{})
  end

  @spec execute_transaction(map(), BankApi.Accounts.BillingAccount.t()) :: Transaction.t()
  def execute_transaction(
        %{"type" => "transfer", "value" => value} = transaction_params,
        %BillingAccount{} = source_billing_account
      ) do
    with {:ok, :valid} <- validate_balance_value(source_billing_account.balance, value),
         {:ok, :valid} <- validate_deposit_value(value),
         %BillingAccount{} = destination_billing_account <-
           Accounts.get_billing_account_by_code(
             transaction_params["destination_billing_account_code"]
           ),
         {:ok, %Transaction{} = transaction} <-
           transfer_operation(
             source_billing_account,
             destination_billing_account,
             transaction_params
           ) do
      {:ok, transaction}
    else
      error -> error
    end
  end

  def execute_transaction(
        %{"type" => "withdraw", "value" => value} = transaction_params,
        %BillingAccount{} = billing_account
      ) do
    with {:ok, :valid} <- validate_balance_value(billing_account.balance, value),
         {:ok, %BillingAccount{}} <-
           Accounts.update_billing_account(billing_account, %{
             balance:
               Decimal.sub(
                 billing_account.balance,
                 Decimal.new(value)
               )
           }) do
      new_transaction_attrs =
        Map.merge(transaction_params, %{
          "source_billing_account_id" => billing_account.id,
          "destination_billing_account_id" => billing_account.id
        })

      create_transaction(new_transaction_attrs)
    else
      error -> error
    end
  end

  def execute_transaction(
        %{"type" => "deposit", "value" => value} = transaction_params,
        %BillingAccount{} = billing_account
      ) do
    with {:ok, :valid} <- validate_deposit_value(value),
         {:ok, %BillingAccount{}} <-
           Accounts.update_billing_account(billing_account, %{
             balance:
               Decimal.add(
                 billing_account.balance,
                 Decimal.new(value)
               )
           }) do
      new_transaction_attrs =
        Map.merge(transaction_params, %{
          "destination_billing_account_id" => billing_account.id
        })

      create_transaction(new_transaction_attrs)
    else
      error -> error
    end
  end

  @spec transfer_operation(
          BillingAccount.t(),
          BillingAccount.t(),
          map()
        ) ::
          {:ok, Transaction.t()}
          | {:error, any}
  def transfer_operation(
        source_billing_account,
        destination_billing_account,
        transaction_params
      ) do
    source_account_changeset =
      BillingAccount.changeset(source_billing_account, %{
        balance:
          Decimal.sub(
            source_billing_account.balance,
            Decimal.new(transaction_params["value"])
          )
      })

    destination_account_changeset =
      BillingAccount.changeset(destination_billing_account, %{
        balance:
          Decimal.add(
            destination_billing_account.balance,
            Decimal.new(transaction_params["value"])
          )
      })

    Multi.new()
    |> Multi.update(:source_billing_account, source_account_changeset)
    |> Multi.update(:destination_billing_account, destination_account_changeset)
    |> Multi.run(:transaction, fn _, _ ->
      new_transaction_params =
        Map.merge(transaction_params, %{
          "destination_billing_account_id" => destination_billing_account.id,
          "source_billing_account_id" => source_billing_account.id
        })

      create_transaction(new_transaction_params)
    end)
    |> Repo.transaction()
    |> validate_transfer_operation()
  end

  defp validate_transfer_operation(transaction) do
    case transaction do
      {:ok,
       %{
         destination_billing_account: %BillingAccount{} = _destination_billing_account,
         source_billing_account: %BillingAccount{} = _source_billing_account,
         transaction: %Transaction{} = transaction
       }} ->
        {:ok, transaction}

      {:error, _failed_operation, failed_value, _changes_done} ->
        {:error, failed_value}
    end
  end

  defp validate_deposit_value(transaction_value)
       when transaction_value <= 0,
       do: {:error, :invalid_transaction_value}

  defp validate_deposit_value(transaction_value)
       when transaction_value > 0,
       do: {:ok, :valid}

  defp validate_balance_value(balance_value, transaction_value)
       when transaction_value > balance_value,
       do: {:ok, :invalid_balance_value}

  defp validate_balance_value(balance_value, transaction_value)
       when balance_value > transaction_value,
       do: {:ok, :valid}
end
