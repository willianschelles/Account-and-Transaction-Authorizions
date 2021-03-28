defmodule Authorizer.Transaction.CheckerTest do
  use ExUnit.Case, async: true
  alias Authorizer.Transaction
  alias Authorizer.Transaction.Checker, as: TransactionChecker

  describe "verify/2" do
    test "returns empty violation list" do
      transaction = %Transaction{}
      violations = []
      assert [] = TransactionChecker.verify(transaction, violations)

    end

    # test "returns filled violation list when Transaction already intialized" do
    #   {:ok, supervisor_pid} =
    #     DynamicSupervisor.start_child(
    #       Authorizer.DynamicSupervisor,
    #       {Transaction, [name: :transaction_checker_test]}
    #     )

    #   transaction = {}
    #   violations = []
    #   assert ["Transaction-already-initialized"] = TransactionChecker.verify(transaction, violations)
    #   DynamicSupervisor.stop(supervisor_pid)
    # end
  end
end
