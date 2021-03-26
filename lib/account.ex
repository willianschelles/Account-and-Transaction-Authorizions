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

  @spec create(keyword()) :: {:error, any} | {:ok, pid}
  @doc """
  Starts a new account in a separated process (keeping state, not shared memory).
  """
  def create(state) do
    active_card = Keyword.get(state, :active_card)
    available_limit = Keyword.get(state, :available_limit)

    Agent.start_link(
      fn ->
        %Account{active_card: active_card, available_limit: available_limit}
      end,
      name: Account
    )
  end
end
