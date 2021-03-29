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

    end
  end
end
