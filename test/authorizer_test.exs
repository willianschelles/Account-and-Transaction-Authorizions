defmodule AuthorizerTest do
  use ExUnit.Case
  doctest Authorizer

  describe "authorize/1 account" do
    @account_payload %{account: %{"active-card" => true, "available-limit" => 100}}

    test "returns output with an account state and empty violations when no violation occurs" do
      expected_acount = %Authorizer.Account{active_card: true, available_limit: 100}
      expected_violations = []

      assert %Output{account: ^expected_acount, violations: ^expected_violations} =
               Authorizer.run(@account_payload)

      [{_, pid, _, _}] = DynamicSupervisor.which_children(Authorizer.DynamicSupervisor)
      DynamicSupervisor.terminate_child(Authorizer.DynamicSupervisor, pid)
    end
  end

  describe "authorize/1 transaction" do
    @transaction_payload %{
      transaction: %{
        "merchant" => "Burger King",
        "amount" => 37,
        "time" => "2019-02-13T10:00:00.000Z"
      }
    }

    test "returns output with an account state and empty violations when no violation occurs" do
      account_attrs = [name: :whatfork, active_card: true, available_limit: 213]

      DynamicSupervisor.start_child(
        Authorizer.DynamicSupervisor,
        {Authorizer.Account, account_attrs}
      )

      current_available_limit = Keyword.get(account_attrs, :available_limit)
      transaction_amount = @transaction_payload.transaction["amount"]
      available_limit_after_transaction = current_available_limit - transaction_amount

      expected_acount = %Authorizer.Account{
        active_card: true,
        available_limit: available_limit_after_transaction
      }

      expected_violations = []

      assert %Output{account: ^expected_acount, violations: ^expected_violations} =
               Authorizer.run(@transaction_payload)
    end
  end
end
