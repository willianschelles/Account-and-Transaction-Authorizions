defmodule Authorizer.Transaction.Checker do
  alias Authorizer.Transaction

  @spec verify(Transaction.t(), list()) :: list()
  def verify(%Transaction{} = _transaction, violations) do
    violations
    |> initialized_account()
  end

  defp initialized_account(violations) do
    %{active: active_accounts} = DynamicSupervisor.count_children(Authorizer.DynamicSupervisor)

    if active_accounts == 0,
      do: append_violation(violations, "account-not-initialized"),
      else: []
  end

  defp append_violation(violations, violation), do: List.insert_at(violations, -1, violation)
end
