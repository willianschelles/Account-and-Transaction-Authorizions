defmodule AuthorizerTest do
  use ExUnit.Case
  doctest Authorizer

  describe "authorize/1 account" do
    @account_payload %{account: %{"active-card" => true, "available-limit" => 100}}

    test "returns output with an account state and empty violations" do
      expected_acount = %Authorizer.Account{active_card: true, available_limit: 100}
      expected_violations = []

      assert %Output{account_state: ^expected_acount, violations: ^expected_violations} =
               Authorizer.run(@account_payload)

      # DynamicSupervisor.terminate_child(Authorizer.DynamicSupervisor, account_pid)
    end
  end
end

# input
# {"account": {"active-card": true, "available-limit": 100}} ...
# {"account": {"active-card": true, "available-limit": 350}}

# output
# {"account": {"active-card": true, "available-limit": 100}, "violations": []}
# ...
# {"account": {"active-card": true, "available-limit": 100}, "violations": ["account-already-initialized" ]}
