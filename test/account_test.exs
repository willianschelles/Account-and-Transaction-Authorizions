defmodule AccountTest do
  # improve speed of tests when async
  use ExUnit.Case, async: true

  alias Account

  describe "default attributes" do
    test "builds a struct %Account{}" do
      assert %Account{active_card: nil, available_limit: nil} = %Account{}
    end
  end
end
