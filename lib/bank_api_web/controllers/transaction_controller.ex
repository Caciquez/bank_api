defmodule BankApiWeb.TransactionController do
  use BankApiWeb, :controller

  alias BankApi.Accounts
  alias BankApi.Accounts.BillingAccount
  alias BankApi.Transactions
  alias BankApi.Transactions.Transaction

  action_fallback(BankApiWeb.FallbackController)

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
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

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    transaction = Transactions.get_transaction!(id)
    render(conn, "show.json", transaction: transaction)
  end

  @spec report(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def report(conn, report_params) do
    {total_transaction_value, transactions} = Transactions.generate_report(report_params)

    conn
    |> put_status(200)
    |> json(%{
      report_data: %{
        transactions: transactions,
        total_value: total_transaction_value
      }
    })
  end
end
