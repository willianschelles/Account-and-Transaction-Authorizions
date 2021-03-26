defmodule Account do
  @moduledoc """
  Documentation for `Account`.
  """
  use Agent

  @type t :: %Account{
          active_card: boolean(),
          available_limit: integer()
        }
  defstruct active_card: nil, available_limit: nil
end
