defmodule CalculatorLv.Repo do
  use Ecto.Repo,
    otp_app: :calculator_lv,
    adapter: Ecto.Adapters.Postgres
end
