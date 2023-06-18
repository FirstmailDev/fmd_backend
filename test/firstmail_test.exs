defmodule FirstmailTest do
  use ExUnit.Case
  doctest Firstmail

  test "greets the world" do
    assert Firstmail.hello() == :world
  end
end
