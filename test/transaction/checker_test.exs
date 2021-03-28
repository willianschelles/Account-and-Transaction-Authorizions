defmodule Authorizer.Transaction.CheckerTest do
  use ExUnit.Case, async: true
  alias Authorizer.Transaction
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
  end
end
