defmodule BankApi.TransactionFactory do
  alias BankApi.Transactions.Transaction

  defmacro __using__(_opts) do
    quote do
      def transfer_factory do
        %Transaction{
          value: 10_000,
          source_billing_account: insert(:billing_account),
          destination_billing_account: insert(:billing_account),
          type: "transfer"
        }
      end

      def withdraw_factory do
        %Transaction{
          value: 10_000,
          source_billing_account: insert(:billing_account),
          destination_billing_account: insert(:billing_account),
          type: "withdraw"
        }
      end

      def deposit_factory do
        %Transaction{
          value: 10_000,
          destination_billing_account: insert(:billing_account),
          type: "deposit"
        }
      end
    end
  end
end
