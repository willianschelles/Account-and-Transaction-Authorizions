defmodule Authorizer.Transaction.Checker do
  alias Authorizer.{Account, Transaction}

  @spec verify(Transaction.t(), list()) :: list()
  def verify(%Transaction{} = transaction, violations) do
    violations
    |> initialized_account()
    |> active_card(transaction)
    |> excess_amount_limit(transaction)
    |> high_frequency_small_interval(transaction)
  end

  defp initialized_account(violations) do
    %{active: active_accounts} = DynamicSupervisor.count_children(Authorizer.DynamicSupervisor)

    if active_accounts == 0,
      do: append_violation(violations, "account-not-initialized"),
      else: violations
  end

  ## THINK nil case
  defp active_card(violations, transaction)
  defp active_card(violations, %Transaction{account_pid: nil}), do: violations

  defp active_card(violations, %Transaction{} = transaction) do
    active_card? = Account.get(transaction.account_pid, :active_card)

    if not active_card?,
      do: append_violation(violations, "​card-not-active"),
      else: violations
  end

  defp excess_amount_limit(violations, transaction)
  defp excess_amount_limit(violations, %Transaction{amount: nil}), do: violations

  defp excess_amount_limit(violations, %Transaction{} = transaction) do
    available_limit = Account.get(transaction.account_pid, :available_limit)

    if transaction.amount > available_limit,
      do: append_violation(violations, "insufficient-limit"),
      else: violations
  end

  defp high_frequency_small_interval(violations, transaction)
  defp high_frequency_small_interval(violations, %Transaction{time: nil}), do: violations

  defp high_frequency_small_interval(violations, %Transaction{} = transaction) do
    [one, _two, three] = get_last_trhee_transactions(transaction)

    if DateTime.diff(three.time, one.time) <= 120,
      do: append_violation(violations, "high-frequency-small-interval"),
      else: violations
  end

  defp get_last_trhee_transactions(%Transaction{} = transaction) do
    transaction |> Map.get(:account_pid) |> Account.get(:transactions) |> Enum.take(-3)
  end

  defp append_violation(violations, violation), do: List.insert_at(violations, -1, violation)
end
