defmodule Authorizer do
  @moduledoc """
  Documentation for `Authorizer`.
  """
  use Application
  alias Authorizer.Account

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Authorizer.DynamicSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @spec run(map()) :: map()
  def run(event)

  def run(%{account: account}) do
    violations = Authorizer.Account.Checker.verify(account, [])

    with true <- Enum.empty?(violations),
         {:ok, account_pid} <- create_account(account) do
      account = Account.state(account_pid)
      %Output{account_state: account, violations: violations}
    end
  end

  def run(%{transaction: transaction} = _event) do
    _violations = Authorizer.Transaction.Checker.verify(transaction, [])

    %{}
  end

  defp create_account(account) do
    account_attrs = [
      active_card: account["active-card"],
      available_limit: account["available-limit"]
    ]
    DynamicSupervisor.start_child(Authorizer.DynamicSupervisor, {Account, account_attrs})
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
