defmodule AccountTest do
  use ExUnit.Case, async: true

  alias Account

  setup do
    account_attrs = [active_card: true, available_limit: 100]
    Account.create(account_attrs)
    :ok
  end

  describe "default attributes" do
    test "builds a struct %Account{}" do
      assert %Account{active_card: nil, available_limit: nil} = %Account{}
    end
  end

  describe "create/1" do
    test "creates an Account process with given state and returns its PID" do
      {:ok, account_pid} = Account.create(account_id: :some_other_account)
      assert is_pid(account_pid)
    end
  end

  describe "get/1" do
    test "returns a value given key" do
      expected_attrs = %{active_card: true, available_limit: 100}
      assert Account.get(:active_card) == expected_attrs.active_card
      assert Account.get(:available_limit) == expected_attrs.available_limit
    end
  end

  describe "update/2" do
    test "updates an account state" do
      default_attrs = %{active_card: true, available_limit: 100}
      assert Account.get(:active_card) == default_attrs.active_card
      assert Account.get(:available_limit) == default_attrs.available_limit

      Account.update(:active_card, false)
      Account.update(:available_limit, 20)

      expected = %{active_card: false, available_limit: 20}
      assert Account.get(:active_card) == expected.active_card
      assert Account.get(:available_limit) == expected.available_limit
    end
  end
end
