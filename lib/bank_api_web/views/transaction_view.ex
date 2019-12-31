defmodule BankApiWeb.TransactionView do
  use BankApiWeb, :view
  alias BankApiWeb.TransactionView

  def render("show.json", %{transaction: transaction}) do
    %{data: render_one(transaction, TransactionView, "transaction.json")}
  end

  def render("transaction.json", %{transaction: transaction}) do
    %{id: transaction.id, type: transaction.type, value: transaction.value}
  end
end
