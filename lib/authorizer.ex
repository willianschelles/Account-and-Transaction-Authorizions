defmodule Authorizer do
  @moduledoc """
  Documentation for `Authorizer`.
  """
  use Application
  alias Authorizer.Account

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Authorizer.DynamicSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @spec process(map()) :: map()
  def process(event)

  def process(%{account: account} = _event) do
    _violations = Authorizer.Account.Checker.verify(account, [])

    # if violations == [] do
    #   {:ok, account_pid} =
    #     DynamicSupervisor.start_child(
    #       Authorizer.DynamicSupervisor,
    #       {Account, account_attrs}
    #     )
    # end

    %{}
  end

  def process(%{"transaction" => transaction} = _event) do
    _violations = Authorizer.Transaction.Checker.verify(transaction, [])

    %{}
  end

  # defp execute_operation(operation_type, operation, violations)

  # defp execute_operation("account", account, []) do
  #   account_attrs = [active_card: account.active_card, available_limit: account.available_limit]
  #   Supervisor.count_children(account_ipid)
  #   children = [
  #     Supervisor.child_spec({Account, account_attrs}, id: :my_worker_1)
  #   ]

  #   {:ok, account_ipid} = Supervisor.start_link(children, strategy: :one_for_one)
  # end
end
