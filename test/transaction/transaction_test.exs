defmodule TransactionTest do
  use ExUnit.Case, async: true

  describe "default attributes" do
    test "builds a struct %Transaction{}" do
      assert %Authorizer.Transaction{merchant: nil, amount: nil, time: nil} = %Authorizer.Transaction{}
    end
  end
end
