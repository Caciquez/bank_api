defmodule BankApiWeb.Router do
  use BankApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :authenticated do
    plug(BankApi.Guardian.AuthAccessPipeline)
  end

  scope "/api/v1", BankApiWeb do
    pipe_through(:api)

    post("/register", UserController, :create)
    post("/auth", UserController, :login)
  end
end
