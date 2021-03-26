defmodule AccountTest do
  # improve speed of tests when async
  use ExUnit.Case, async: true

  alias Account

  describe "default attributes" do
    test "builds a struct %Account{}" do
      assert %Account{active_card: nil, available_limit: nil} = %Account{}
    end
  end

  describe "create/1" do
    test "creates an Account process with given state and returns its PID" do
      account_attrs = [active_card: true, available_limit: 100]
      {:ok, account_pid} = Account.create(account_attrs)
      assert is_pid(account_pid)
    end
  end
end
