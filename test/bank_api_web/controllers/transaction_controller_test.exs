defmodule BankApiWeb.TransactionControllerTest do
  use BankApiWeb.ConnCase

  alias BankApi.Guardian

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{token}")

    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create/2" do
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

  describe "show/2" do
    test "renders transaction data if it exists", %{conn: conn} do
      transaction = insert(:deposit)

      conn = get(conn, Routes.transaction_path(conn, :show, transaction.id))

      assert transaction_attrs = json_response(conn, 200)["data"]
    end

    test "renders error when transaction doesnt exists", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        get(conn, Routes.transaction_path(conn, :show, 1))
      end
    end
  end

  describe "report/2" do
    test "returns report of existing transactions by date", %{conn: conn} do
      insert(:deposit)
      insert(:withdraw)
      insert(:transfer)

      report_params = %{
        "day" => 10,
        "month" => 12,
        "year" => 2019
      }

      conn = post(conn, Routes.transaction_path(conn, :report), report_params)

      assert transaction_attrs = json_response(conn, 200)["report_data"]
    end
  end
end
