defmodule AuthorizerTest do
  use ExUnit.Case
  doctest Authorizer

  test "greets the world" do
    assert Authorizer.hello() == :world
  end
end
