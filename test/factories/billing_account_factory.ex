defmodule BankApi.BillingAccountFactory do
  alias BankApi.Accounts.BillingAccount
  alias Faker.UUID

  defmacro __using__(_opts) do
    quote do
      def billing_account_factory do
        %BillingAccount{
          balance: 1000,
          code: UUID.v4(),
          user_id: build(:user).id
        }
      end
    end
  end
end
