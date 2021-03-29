defmodule Authorizer.Transaction.CheckerTest do
  use ExUnit.Case, async: true
  alias Authorizer.{Account, Transaction}
  alias Authorizer.Transaction.Checker, as: TransactionChecker

  describe "verify/2 returns empty violation list" do
    test "when no violation occurs" do
      account_attrs = [name: :card_inactive, active_card: true, available_limit: 100]

      {:ok, account_pid} =
        DynamicSupervisor.start_child(Authorizer.DynamicSupervisor, {Account, account_attrs})

      {:ok, datetime_one, _} = DateTime.from_iso8601("2019-02-13T10:00:00.000Z")

      transaction = %Transaction{
        account_pid: account_pid,
        amount: 99,
        time: datetime_one,
        merchant: "Dina Pizza"
      }

      violations = []
      assert [] = TransactionChecker.verify(transaction, violations)
      DynamicSupervisor.terminate_child(Authorizer.DynamicSupervisor, account_pid)
    end
  end

  describe "verify/2 returns filled violation list" do
    test "when account is not properly initialized" do
      transaction = %Transaction{}
      violations = []
      assert ["account-not-initialized"] = TransactionChecker.verify(transaction, violations)
    end

    test "when card is not active" do
      account_attrs = [name: :card_inactive, active_card: false]

      {:ok, account_pid} =
        DynamicSupervisor.start_child(Authorizer.DynamicSupervisor, {Account, account_attrs})

      transaction = %Transaction{account_pid: account_pid}
      violations = []
      assert ["​card-not-active"] = TransactionChecker.verify(transaction, violations)
      DynamicSupervisor.terminate_child(Authorizer.DynamicSupervisor, account_pid)
    end

    test "when transaction amount exceed available limit of account" do
      amount = 100
      exceeded_amount = amount + 1
      account_attrs = [name: :amount_exceed, available_limit: amount, active_card: true]

      {:ok, account_pid} =
        DynamicSupervisor.start_child(Authorizer.DynamicSupervisor, {Account, account_attrs})

      transaction = %Transaction{account_pid: account_pid, amount: exceeded_amount}
      violations = []

      assert ["insufficient-limit"] == TransactionChecker.verify(transaction, violations)
      DynamicSupervisor.terminate_child(Authorizer.DynamicSupervisor, account_pid)
    end

    test "when be more than 3 transactions on a 2 minutes interval" do
      {:ok, datetime_one, _} = DateTime.from_iso8601("2019-02-13T10:00:00.000Z")
      {:ok, datetime_two, _} = DateTime.from_iso8601("2019-02-13T10:01:00.000Z")
      {:ok, datetime_three, _} = DateTime.from_iso8601("2019-02-13T10:02:00.000Z")

      account_attrs = [name: :high_frequency, active_card: true]

      {:ok, account_pid} =
        DynamicSupervisor.start_child(Authorizer.DynamicSupervisor, {Account, account_attrs})

      transaction = %Transaction{
        account_pid: account_pid,
        time: datetime_one,
        merchant: "some_merchant"
      }

      Account.update(account_pid, :transactions, transaction)

      transaction = %Transaction{
        account_pid: account_pid,
        time: datetime_two,
        merchant: "another_merchant"
      }

      Account.update(account_pid, :transactions, transaction)

      transaction = %Transaction{
        account_pid: account_pid,
        time: datetime_three,
        merchant: "third_one_merchant"
      }

      Account.update(account_pid, :transactions, transaction)

      violations = []

      assert ["high-frequency-small-interval"] ==
               TransactionChecker.verify(transaction, violations)

      DynamicSupervisor.terminate_child(Authorizer.DynamicSupervisor, account_pid)
    end

    test "when there be same amount and merchant in a 2 minutes interval" do
      account_attrs = [name: :doubled_transaction, active_card: true]

      {:ok, account_pid} =
        DynamicSupervisor.start_child(Authorizer.DynamicSupervisor, {Account, account_attrs})

      {:ok, datetime_one, _} = DateTime.from_iso8601("2019-02-13T10:00:00.000Z")
      {:ok, datetime_two, _} = DateTime.from_iso8601("2019-02-13T10:02:00.000Z")

      merchant = "Dom Camilo"
      amount = 76

      transaction = %Transaction{
        account_pid: account_pid,
        time: datetime_one,
        merchant: merchant,
        amount: amount
      }

      Account.update(account_pid, :transactions, transaction)

      transaction = %Transaction{
        account_pid: account_pid,
        time: datetime_two,
        merchant: merchant,
        amount: amount
      }

      Account.update(account_pid, :transactions, transaction)

      violations = []

      assert ["doubled-transaction"] ==
               TransactionChecker.verify(transaction, violations)

      DynamicSupervisor.terminate_child(Authorizer.DynamicSupervisor, account_pid)
    end
  end
end
