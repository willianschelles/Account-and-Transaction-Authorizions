defmodule Transaction do
  @moduledoc """
  Documentation for `Transaction`.
  """
  use Agent

  @type t :: %Transaction{
          merchant: String.t(),
          amount: integer(),
          time: DateTime
        }
  defstruct [:merchant, :amount, :time]
end
