defmodule BankApi.CustomersTest do
  use BankApi.DataCase, async: true

  alias BankApi.Customers
  alias BankApi.Customers.User

  @invalid_attrs %{email: nil, name: nil, password: nil}
  @attrs %{
    "name" => "John Doe",
    "email" => "john.doe@example.com",
    "email_confirmation" => "john.doe@example.com",
    "password" => "123456789",
    "password_confirmation" => "123456789"
  }

  describe "create_user/1" do
    test "creates a user when data is valid" do
      assert {:ok, %User{} = user} = Customers.create_user(@attrs)
      assert user.email == @attrs["email"]
      assert user.name == @attrs["name"]
    end

    test "does not create a user when required data are blank" do
      assert {:error, changeset} = Customers.create_user(%{})
      assert %{name: ["Dado obrigatório"]} = errors_on(changeset)
      assert %{email: ["Dado obrigatório"]} = errors_on(changeset)
      assert %{email_confirmation: ["Dado obrigatório"]} = errors_on(changeset)
      assert %{password: ["Dado obrigatório"]} = errors_on(changeset)
      assert %{password_confirmation: ["Dado obrigatório"]} = errors_on(changeset)
    end

    test "user with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customers.create_user(@invalid_attrs)
    end

    test "does not create a user when email is too long" do
      assert {:error, changeset} =
               @attrs
               |> Map.merge(%{"email" => "#{String.duplicate("a", 60)}@gmail.com"})
               |> Customers.create_user()

      assert %{email: ["Não pode conter mais do que 60 caracteres"]} =
               errors_on(changeset)
    end

    test "does not create a user when email format is invalid" do
      assert {:error, changeset} =
               @attrs
               |> Map.merge(%{
                 "email" => "foogmail.com",
                 "email_confirmation" => "foogmail.com"
               })
               |> Customers.create_user()

      assert %{email: ["Formato inválido: deve possuir @ e .com"]} = errors_on(changeset)
    end

    test "does not create a user when email already exists" do
      insert(:user, email: "tootleboop@gmail.com")

      assert {:error, changeset} =
               @attrs
               |> Map.merge(%{
                 "email" => "tootleboop@gmail.com",
                 "email_confirmation" => "tootleboop@gmail.com"
               })
               |> Customers.create_user()

      assert %{email: ["E-mail já está em uso"]} = errors_on(changeset)
    end

    test "does not create a user when email confirmation does not macth" do
      assert {:error, changeset} =
               @attrs
               |> Map.merge(%{"email_confirmation" => "foo@bar.com"})
               |> Customers.create_user()

      assert %{email_confirmation: ["Confirme seu email corretamente"]} =
               errors_on(changeset)
    end

    test "does not create a user when password is too short" do
      assert {:error, changeset} =
               @attrs
               |> Map.merge(%{"password" => "1234"})
               |> Customers.create_user()

      assert %{password: ["Informe uma senha de 9 até 30 caracteres"]} =
               errors_on(changeset)
    end

    test "does not create a user when password confirmation does not macth" do
      assert {:error, changeset} =
               @attrs
               |> Map.merge(%{"password_confirmation" => "foo"})
               |> Customers.create_user()

      assert %{password_confirmation: ["Confirme sua senha corretamente"]} =
               errors_on(changeset)
    end
  end

  describe "get_user!/1" do
    test "returns the user with given id" do
      user = insert(:user)

      assert Customers.get_user!(user.id) == user
    end
  end

  describe "get_user_by_email/1" do
    test "returns a single user by email" do
      user = insert(:user, email: "john.doe@example.com")

      assert Customers.get_user_by_email("john.doe@example.com") == user
      assert Customers.get_user_by_email("JOHN.DOE@EXAMPLE.COM") == user
    end

    test "returns nil when user not found" do
      assert Customers.get_user_by_email("joh@example.com") == nil
    end
  end
end
