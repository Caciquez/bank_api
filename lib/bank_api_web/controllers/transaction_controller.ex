defmodule BankApiWeb.TransactionController do
  use BankApiWeb, :controller

  alias BankApi.Accounts
  alias BankApi.Accounts.BillingAccount
  alias BankApi.Customers.User
  alias BankApi.Guardian.Plug
  alias BankApi.Transactions
  alias BankApi.Transactions.Transaction

  action_fallback(BankApiWeb.FallbackController)

  def index(conn, _params) do
    transactions = Transactions.list_transactions()
    render(conn, "index.json", transactions: transactions)
  end

  def create(conn, %{"transaction" => transaction_params}) do
    with %BillingAccount{} = billing_account <-
           Accounts.get_billing_account_by_code(
             transaction_params["source_billing_account_code"]
           ),
         {:ok, %Transaction{} = transaction} <-
           Transactions.execute_transaction(transaction_params, billing_account) do
      conn
      |> put_status(:created)
      |> render("show.json", transaction: transaction)
    end
  end

  def show(conn, %{"id" => id}) do
    transaction = Transactions.get_transaction!(id)
    render(conn, "show.json", transaction: transaction)
  end
end
