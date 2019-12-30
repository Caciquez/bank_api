defmodule BankApiWeb.TransactionControllerTest do
  use BankApiWeb.ConnCase, async: true

  alias BankApi.Guardian

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{token}")

    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create transaction" do
    test "renders transaction when data is valid", %{conn: conn} do
      billing_account = insert(:billing_account)

      transaction_attrs = %{
        "value" => 300,
        "source_billing_account_code" => billing_account.code,
        "type" => "deposit"
      }

      conn =
        post(conn, Routes.transaction_path(conn, :create), transaction: transaction_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.transaction_path(conn, :show, id))

      assert transaction_attrs = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      transaction_attrs = %{
        "value" => -100,
        "source_billing_account_code" => "bc444263-79c2-4ebc-af1f-106df3c610bf",
        "type" => "deposit"
      }

      conn =
        post(conn, Routes.transaction_path(conn, :create), transaction: transaction_attrs)

      assert json_response(conn, 404)["errors"] != %{}
    end
  end
end
