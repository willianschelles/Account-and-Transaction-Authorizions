defmodule Output do
  @type t :: %__MODULE__{
          account: Authorizer.Account.t(),
          violations: list(String.t())
        }
  defstruct [:account, violations: []]
end
