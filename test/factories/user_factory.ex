defmodule BankApi.UserFactory do
  alias BankApi.Customers.User
  alias Faker.{Internet, StarWars}

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %User{
          email: Internet.email(),
          name: "#{StarWars.character()} #{StarWars.character()}",
          encrypted_password: Bcrypt.hash_pwd_salt("123456789")
        }
      end
    end
  end
end
