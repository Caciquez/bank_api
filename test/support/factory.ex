defmodule BankApi.Factory do
  @moduledoc """
  Factory module
  """

  use ExMachina.Ecto, repo: BankApi.Repo

  use BankApi.{
    UserFactory,
    BillingAccountFactory,
    TransactionFactory
  }
end
