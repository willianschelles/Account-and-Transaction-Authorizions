defmodule TransactionTest do
  use ExUnit.Case, async: true

  describe "default attributes" do
    test "builds a struct %Transaction{}" do
      assert %Transaction{merchant: nil, amount: nil, time: nil} = %Transaction{}
    end
  end

end
