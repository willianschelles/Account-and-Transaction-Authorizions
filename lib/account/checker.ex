defmodule Authorizer.Account.Checker do
  def verify(_account, violations) do
    violations
    |> account_limit()
  end

  @account_limit_violation "account-already-initialized"
  defp account_limit(violations) do
    %{active: active_accounts} = DynamicSupervisor.count_children(Authorizer.DynamicSupervisor)

    if active_accounts == 0,
      do: [],
      else: List.insert_at(violations, -1, @account_limit_violation)
  end
end
