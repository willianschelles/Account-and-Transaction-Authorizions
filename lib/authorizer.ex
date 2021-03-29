defmodule Authorizer do
  @moduledoc """
  Documentation for `Authorizer`.
  """
  use Application
  alias Authorizer.{Account, Transaction}

  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_type, _args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Authorizer.DynamicSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @spec run(map()) :: map()
  def run(operation)

  def run(%{account: account}) do
    violations = Authorizer.Account.Checker.verify(account, [])

    {:ok, account_pid} =
      if Enum.empty?(violations) do
        create_account(account)
      else
        {:ok, get_account_pid()}
      end

    account = Account.state(account_pid)
    %Output{account: account, violations: violations}
  end

  def run(%{transaction: transaction}) do
    # move to "subscriber"
    account_pid = get_account_pid()
    transaction = build_transaction(transaction, account_pid)
    violations = Authorizer.Transaction.Checker.verify(transaction, [])

    if Enum.empty?(violations),
      do: execute_transaction(transaction)

    account = Account.state(account_pid)

    %Output{
      account: %Account{
        active_card: account.active_card,
        available_limit: account.available_limit
      },
      violations: violations
    }
  end

  defp create_account(account) do
    account_attrs = [
      active_card: account["active-card"],
      available_limit: account["available-limit"]
    ]

    DynamicSupervisor.start_child(Authorizer.DynamicSupervisor, {Account, account_attrs})
  end

  defp execute_transaction(%Transaction{} = transaction) do
    current_available_limit = Account.get(transaction.account_pid, :available_limit)
    new_available_limit = current_available_limit - transaction.amount
    Account.update(transaction.account_pid, :available_limit, new_available_limit)
    Account.update(transaction.account_pid, :transactions, transaction)
  end

  defp get_account_pid() do
    [{_, account_pid, _, _}] = DynamicSupervisor.which_children(Authorizer.DynamicSupervisor)
    account_pid
  end

  defp build_transaction(transaction, account_pid) do
    %Transaction{
      merchant: transaction["merchant"],
      amount: transaction["amount"],
      time: transaction["time"],
      account_pid: account_pid
    }
  end
end
