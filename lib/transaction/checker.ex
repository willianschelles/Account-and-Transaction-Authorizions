defmodule Authorizer.Transaction.Checker do
  alias Authorizer.{Account, Transaction}

  @spec verify(Transaction.t(), list()) :: list()
  def verify(%Transaction{} = transaction, violations) do
    violations
    |> initialized_account()
    |> active_card(transaction)
    |> excess_amount_limit(transaction)
    |> high_frequency_small_interval(transaction)
    |> doubled_transaction(transaction)
  end

  defp initialized_account(violations) do
    %{active: active_accounts} = DynamicSupervisor.count_children(Authorizer.DynamicSupervisor)

    if active_accounts == 0,
      do: append_violation(violations, "account-not-initialized"),
      else: violations
  end

  defp active_card(violations, transaction)
  defp active_card(violations, %Transaction{account_pid: nil}), do: violations

  defp active_card(violations, %Transaction{} = transaction) do
    active_card = Account.get(transaction.account_pid, :active_card)

    if not active_card,
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
    latest_transactions = take_latest_transactions(transaction.account_pid, 2)

    with true <- length(latest_transactions) >= 2,
         [one, _two] <- latest_transactions,
         true <- is_less_than_two_minutes?(one.time, transaction.time) do
      append_violation(violations, "high-frequency-small-interval")
    else
      _ -> violations
    end
  end

  defp doubled_transaction(violations, %Transaction{} = transaction) do
    latest_transactions = take_latest_transactions(transaction.account_pid, 1)

    with true <- length(latest_transactions) >= 1,
         [one] <- latest_transactions,
         true <- is_less_than_two_minutes?(one.time, transaction.time),
         true <- is_same_merchant_and_amount?(one, transaction) do
      append_violation(violations, "doubled-transaction")
    else
      _ -> violations
    end
  end

  defp is_less_than_two_minutes?(time_one, time_two),
    do: DateTime.diff(time_two, time_one) <= 120

  defp take_latest_transactions(nil, _amount), do: []

  defp take_latest_transactions(account_pid, amount) do
    account_pid |> Account.get(:transactions) |> Enum.take(amount * -1)
  end

  defp is_same_merchant_and_amount?(transaction_one, transaction_two) do
    transaction_one.merchant == transaction_two.merchant and
      transaction_one.amount == transaction_two.amount
  end

  defp append_violation(violations, violation), do: List.insert_at(violations, -1, violation)
end
