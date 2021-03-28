defmodule AccountTest do
  use ExUnit.Case, async: true

  alias Authorizer.Account

  setup do
    account_attrs = [active_card: true, available_limit: 100]
    {:ok, pid} = Account.start_link(account_attrs)
    {:ok, %{pid: pid}}
  end

  describe "default attributes" do
    test "builds a struct %Account{}" do
      assert %Account{active_card: nil, available_limit: nil} = %Account{}
    end
  end

  describe "create/1" do
    test "creates an Account process with given state and returns its PID" do
      {:ok, account_pid} = Account.start_link(name: :some_other_account)
      assert is_pid(account_pid)
    end
  end

  describe "get/1" do
    test "returns a value given key", %{pid: pid} do
      expected_attrs = %{active_card: true, available_limit: 100}
      assert Account.get(pid, :active_card) == expected_attrs.active_card
      assert Account.get(pid, :available_limit) == expected_attrs.available_limit
    end
  end

  describe "update/2" do
    test "updates an account state", %{pid: pid} do
      default_attrs = %{active_card: true, available_limit: 100}
      assert Account.get(pid, :active_card) == default_attrs.active_card
      assert Account.get(pid, :available_limit) == default_attrs.available_limit

      Account.update(pid, :active_card, false)
      Account.update(pid, :available_limit, 20)

      expected = %{active_card: false, available_limit: 20}
      assert Account.get(pid, :active_card) == expected.active_card
      assert Account.get(pid, :available_limit) == expected.available_limit
      Agent.stop(Account)
    end
  end
end
