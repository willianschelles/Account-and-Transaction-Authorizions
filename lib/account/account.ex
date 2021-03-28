defmodule Authorizer.Account do
  @moduledoc """
  Documentation for `Account`.
  """
  use Agent

  @type t :: %__MODULE__{
          active_card: boolean(),
          available_limit: integer(),
          transactions: list(Authorizer.Transactions.t())
        }
  defstruct [:active_card, :available_limit, transactions: []]

  @spec start_link(keyword()) :: {:error, any} | {:ok, pid}
  @doc """
  Starts a new account in a separated process (keeping state, not shared memory).
  """
  def start_link(state) do
    account_id = Keyword.get(state, :name)
    active_card = Keyword.get(state, :active_card)
    available_limit = Keyword.get(state, :available_limit)

    Agent.start_link(
      fn ->
        %__MODULE__{active_card: active_card, available_limit: available_limit}
      end,
      name: account_id || __MODULE__
    )
  end

  @spec get(pid(), atom()) :: boolean() | integer()
  def get(pid, key) do
    Agent.get(pid, &Map.get(&1, key))
  end

  @spec update(pid(), atom(), boolean() | integer()) :: :ok
  def update(pid, key, value) do
    Agent.update(pid, &Map.put(&1, key, value))
  end

  @spec get_and_update(pid(), atom(), any()) :: any
  def get_and_update(pid, key, value) do
    Agent.get_and_update(pid, fn state ->
      transactions = List.insert_at(state.transactions, -1, value)
      new_state = Map.put(state, :transactions, transactions)
      {state, new_state}
    end)
  end
end
