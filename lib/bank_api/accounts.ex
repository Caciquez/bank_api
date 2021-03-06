defmodule BankApi.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false
  alias BankApi.Accounts.BillingAccount
  alias BankApi.Customers.User
  alias BankApi.Repo
  alias Ecto.Multi

  @doc """
  Gets a single billing_account.

  Raises `Ecto.NoResultsError` if the Billing account does not exist.

  ## Examples

      iex> get_billing_account!(123)
      %BillingAccount{}

      iex> get_billing_account!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_billing_account!(number()) :: {:ok, BillingAccount.t()} | {:error, any}
  def get_billing_account!(id), do: Repo.get!(BillingAccount, id)

  @doc """
  Creates a billing_account.

  ## Examples

      iex> create_billing_account(%{field: value})
      {:ok, %BillingAccount{}}

      iex> create_billing_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_billing_account(map()) :: {:ok, BillingAccount.t()} | {:error, any}
  def create_billing_account(attrs \\ %{}) do
    %BillingAccount{}
    |> BillingAccount.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a billing_account.

  ## Examples

      iex> update_billing_account(billing_account, %{field: new_value})
      {:ok, %BillingAccount{}}

      iex> update_billing_account(billing_account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_billing_account(BillingAccount.t(), map()) ::
          {:ok, BillingAccount.t()} | {:error, any}
  def update_billing_account(%BillingAccount{} = billing_account, attrs) do
    billing_account
    |> BillingAccount.changeset(attrs)
    |> Repo.update()
  end

  @spec get_billing_account_by_code(charlist()) ::
          {:error, :not_found} | BillingAccount.t()
  def get_billing_account_by_code(code) do
    query = from(ba in BillingAccount, where: ba.code == ^code)

    case Repo.one(query) do
      %BillingAccount{} = billing_account ->
        billing_account

      _ ->
        {:error, :not_found}
    end
  end

  @spec create_user_and_billing_account(map()) ::
          {:error, any} | {:ok, BillingAccount.t(), User.t()}
  def create_user_and_billing_account(user_params) do
    Multi.new()
    |> Multi.insert(:user, User.changeset(%User{}, user_params))
    |> Multi.merge(fn %{user: user} ->
      billing_acount_user_relation_multi(user.id)
    end)
    |> Repo.transaction()
    |> validate_user_billing_account_transaction()
  end

  @spec billing_acount_user_relation_multi(number()) :: Multi.t()
  defp billing_acount_user_relation_multi(user_id) do
    Multi.new()
    |> Multi.insert(
      :billing_account,
      BillingAccount.changeset(
        %BillingAccount{},
        %{user_id: user_id}
      )
    )
  end

  @spec billing_acount_user_relation_multi(Multi.t()) ::
          {:ok, BillingAccount.t(), User.t()} | {:error, any}
  defp validate_user_billing_account_transaction(transaction) do
    case transaction do
      {:ok, %{billing_account: billing_account, user: user}} ->
        {:ok, billing_account, user}

      {:error, _failed_operation, failed_value, _changes_done} ->
        {:error, failed_value}
    end
  end
end
