defmodule BankApiWeb.UserControllerTest do
  use BankApiWeb.ConnCase, async: true

  @invalid_attrs %{email: nil, name: nil, password: nil}
  @attrs %{
    "name" => "John Doe",
    "email" => "john.doe@example.com",
    "email_confirmation" => "john.doe@example.com",
    "password" => "123456789",
    "password_confirmation" => "123456789"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create/2" do
    test "creates, and responds with a newly created user if attributes are valid", %{
      conn: conn
    } do
      conn = post(conn, Routes.user_path(conn, :create), user: @attrs)

      assert response = json_response(conn, 200)["data"]
    end

    test "returns an error when required params are nil", %{
      conn: conn
    } do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)

      assert %{
               "errors" => %{
                 "name" => ["Dado obrigatório"],
                 "password_confirmation" => ["Dado obrigatório"],
                 "email" => ["Dado obrigatório"],
                 "email_confirmation" => ["Dado obrigatório"],
                 "password" => ["Dado obrigatório"]
               }
             } ==
               json_response(conn, 422)
    end

    test "returns error when password confirmation is invalid", %{conn: conn} do
      user_attrs = %{
        name: "John Doe",
        email: "john.doe@example.com",
        email_confirmation: "john.doe@example.com",
        password: "tootleboop",
        password_confirmation: "tootleboo"
      }

      conn = post(conn, Routes.user_path(conn, :create), user: user_attrs)

      assert %{
               "errors" => %{
                 "password_confirmation" => ["Confirme sua senha corretamente"]
               }
             } ==
               json_response(conn, 422)
    end

    test "returns error when password length is invalid", %{conn: conn} do
      user_attrs = %{
        name: "John Doe",
        email: "john.doe@example.com",
        email_confirmation: "john.doe@example.com",
        password: "toot",
        password_confirmation: "toot"
      }

      conn = post(conn, Routes.user_path(conn, :create), user: user_attrs)

      assert %{
               "errors" => %{
                 "password" => ["Informe uma senha de 9 até 30 caracteres"]
               }
             } ==
               json_response(conn, 422)
    end

    test "returns error when email is invalid", %{conn: conn} do
      user_attrs = %{
        name: "John Doe",
        email: "john.do.example.br",
        email_confirmation: "john.do.example.br",
        password: "123456789",
        password_confirmation: "123456789"
      }

      conn = post(conn, Routes.user_path(conn, :create), user: user_attrs)

      assert %{"errors" => %{"email" => ["Formato inválido: deve possuir @ e .com"]}} ==
               json_response(conn, 422)
    end

    test "returns error when email already been taken", %{conn: conn} do
      insert(:user, email: "john.doe@example.com")

      user_attrs = %{
        name: "John Doe",
        email: "john.doe@example.com",
        email_confirmation: "john.doe@example.com",
        password: "123456789",
        password_confirmation: "123456789"
      }

      conn = post(conn, Routes.user_path(conn, :create), user: user_attrs)

      assert %{"errors" => %{"email" => ["E-mail já está em uso"]}} =
               json_response(conn, 422)
    end

    test "returns error when confirmation email doesnt match email", %{conn: conn} do
      user_attrs = %{
        name: "John Doe",
        email: "john.doe@example.com",
        email_confirmation: "john@example.com",
        password: "123456789",
        password_confirmation: "123456789"
      }

      conn = post(conn, Routes.user_path(conn, :create), user: user_attrs)

      assert %{"errors" => %{"email_confirmation" => ["Confirme seu email corretamente"]}} =
               json_response(conn, 422)
    end
  end

  describe "login/2" do
    setup %{conn: conn} do
      insert(:user, email: "john.doe@example.com", password: "123456789")
      {:ok, conn: put_req_header(conn, "accept", "application/json")}
    end

    test "authenticate user with success", %{conn: conn} do
      params = %{"email" => "john.doe@example.com", "password" => "123456789"}

      conn = post(conn, Routes.user_path(conn, :login, params))
      assert response = json_response(conn, 200)["data"]
    end

    test "returns error when password is invalid", %{conn: conn} do
      params = %{"email" => "john.doe@example.com", "password" => "qwertyuiop"}

      conn = post(conn, Routes.user_path(conn, :login, params))

      assert %{"error" => "Invalid Password"} == json_response(conn, 401)
    end

    test "returns error when email do not exist", %{conn: conn} do
      params = %{"email" => "Foo.bar@example.com", "password" => "qwertyuiop"}

      conn = post(conn, Routes.user_path(conn, :login, params))

      assert %{"error" => "Invalid Email"} == json_response(conn, 401)
    end
  end
end
