defmodule Authorizer.Transaction do
  @moduledoc """
  Documentation for `Transaction`.
  """
  use Agent

  @type t :: %__MODULE__{
          merchant: String.t(),
          amount: integer(),
          time: DateTime
        }
  defstruct [:merchant, :amount, :time]
end
