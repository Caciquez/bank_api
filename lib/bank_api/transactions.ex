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
  @spec get_transaction!(number()) :: {:ok, Transaction.t()} | nil
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_transaction(map()) :: {:ok, Transaction.t()} | {:error, map()}
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @spec generate_report(map()) :: {[Transaction.t()], float()}
  def generate_report(%{"day" => day, "month" => month, "year" => year}) do
    query =
      from(
        t in Transaction,
        where:
          t.inserted_at > ago(^day, "day") and t.inserted_at > ago(^month, "month") and
            t.inserted_at > ago(^year, "year")
      )

    {
      Repo.aggregate(query, :sum, :value),
      Repo.all(query)
    }
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
             balance: calculate_withdraw(billing_account.balance, value)
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
             balance: calculate_deposit(billing_account.balance, value)
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
  defp transfer_operation(
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

  @spec validate_transfer_operation(map()) ::
          {:ok, Transaction.t()}
          | {:error, any}
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

  @spec validate_deposit_value(number()) :: {:ok, atom()} | {:error, atom()}
  defp validate_deposit_value(transaction_value)
       when transaction_value <= 0,
       do: {:error, :invalid_transaction_value}

  defp validate_deposit_value(transaction_value)
       when transaction_value > 0,
       do: {:ok, :valid}

  @spec validate_balance_value(number(), number()) :: {:ok, atom()} | {:error, atom()}
  defp validate_balance_value(balance_value, transaction_value)
       when transaction_value > balance_value,
       do: {:ok, :invalid_balance_value}

  defp validate_balance_value(balance_value, transaction_value)
       when balance_value > transaction_value,
       do: {:ok, :valid}

  @spec calculate_deposit(number(), number()) :: float()
  defp calculate_deposit(balance, value), do: Decimal.add(balance, Decimal.new(value))

  @spec calculate_deposit(number(), number()) :: float()
  defp calculate_withdraw(balance, value), do: Decimal.sub(balance, Decimal.new(value))
end
