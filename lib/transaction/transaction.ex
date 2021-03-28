defmodule Authorizer.Transaction do
  @moduledoc """
  Documentation for `Transaction`.
  """
  use Agent

  @type t :: %__MODULE__{
          merchant: String.t(),
          amount: integer(),
          time: DateTime.t(),
          account_pid: pid()
        }
  defstruct [:merchant, :amount, :time, :account_pid]
end
