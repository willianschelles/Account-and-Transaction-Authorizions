defmodule Authorizer.Account.CheckerTest do
  use ExUnit.Case, async: true
  alias Authorizer.Account
  alias Authorizer.Account.Checker, as: AccountChecker

  describe "verify/2" do
    test "returns empty violation list" do
      account = %Account{}
      violations = []
      assert [] = AccountChecker.verify(account, violations)
    end

    test "returns filled violation list when account already intialized" do
      {:ok, supervisor_pid} =
        DynamicSupervisor.start_child(
          Authorizer.DynamicSupervisor,
          {Account, [name: :account_checker_test]}
        )

      account = %Account{}
      violations = []
      assert ["account-already-initialized"] = AccountChecker.verify(account, violations)
      DynamicSupervisor.stop(supervisor_pid)
    end
  end
end
