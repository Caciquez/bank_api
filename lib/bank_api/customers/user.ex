defmodule BankApi.Customers.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankApi.Accounts.BillingAccount
  alias BankApi.Customers.User

  @registration_required_fields ~w(name email email_confirmation password password_confirmation)a

  schema "users" do
    field(:name, :string, null: false)
    field(:email, :string, null: false)
    field(:email_confirmation, :string, virtual: true)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    field(:encrypted_password, :string, null: false)

    has_many(:billing_accounts, BillingAccount)

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @registration_required_fields)
    |> validate_required(@registration_required_fields, message: "Dado obrigatório")
    |> validate_email()
    |> validate_password()
  end

  defp validate_email(changeset) do
    changeset
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:email,
      max: 60,
      message: "Não pode conter mais do que 60 caracteres"
    )
    |> validate_format(:email, ~r/@/, message: "Formato inválido: deve possuir @ e .com")
    |> validate_confirmation(:email, message: "Confirme seu email corretamente")
    |> unique_constraint(:email, message: "E-mail já está em uso")
  end

  defp validate_password(changeset) do
    changeset
    |> validate_length(:password,
      min: 9,
      max: 30,
      message: "Informe uma senha de 9 até 30 caracteres"
    )
    |> validate_confirmation(:password, message: "Confirme sua senha corretamente")
    |> encrypt_password()
  end

  defp encrypt_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :encrypted_password, Bcrypt.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end
end
