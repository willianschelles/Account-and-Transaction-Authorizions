defmodule Authorizer.Transaction.CheckerTest do
  use ExUnit.Case, async: true
  alias Authorizer.{Account, Transaction}
  alias Authorizer.Transaction.Checker, as: TransactionChecker

  describe "verify/2 returns empty violantion list" do
    # test "when no violation occurs" do
    #   {:ok, supervisor_pid} =
    #     DynamicSupervisor.start_child(
    #       Authorizer.DynamicSupervisor,
    #       {Account, [name: :transaction_checker_test]}
    #     )

    #   transaction = %Transaction{}
    #   violations = []

    #   transaction = %Transaction{}
    #   violations = []
    #   assert [] = TransactionChecker.verify(transaction, violations)
    # end
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

    # # There should not be more than 3 transactions on a 2 minute interval:
    # # high-frequency-small-interval
    # test "when be more than 3 transactions on a 2 minute interval" do
    #   account_attrs = [name: :high_frequency]

    #   {:ok, account_pid} =
    #     DynamicSupervisor.start_child(Authorizer.DynamicSupervisor, {Account, account_attrs})

    #   transaction = %Transaction{account_pid: account_pid, amount: exceeded_amount}
    #   violations = []

    #   assert ["high-frequency-small-interval"] == TransactionChecker.verify(transaction, violations)
    #   DynamicSupervisor.terminate_child(Authorizer.DynamicSupervisor, account_pid)

    #   # "time":
    #   # "2019-02-13T10:00:00.000Z"}
    # end
  end
end
