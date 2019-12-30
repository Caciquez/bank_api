defmodule BankApiWeb.TransactionView do
  use BankApiWeb, :view
  alias BankApiWeb.TransactionView

  def render("index.json", %{transactions: transactions}) do
    %{data: render_many(transactions, TransactionView, "transaction.json")}
  end

  def render("show.json", %{transaction: transaction}) do
    %{data: render_one(transaction, TransactionView, "transaction.json")}
  end

  def render("transaction.json", %{transaction: transaction}) do
    %{id: transaction.id, type: transaction.type, value: transaction.value}
  end
end
