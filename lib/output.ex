defmodule Output do
  @type t :: %__MODULE__{
          account_state: Authorizer.Account.t(),
          violations: list(String.t())
        }
  defstruct [:account_state, violations: []]
end
