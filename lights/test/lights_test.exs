defmodule LightsTest do
  use ExUnit.Case
  doctest Lights

  test "greets the world" do
    assert Lights.hello() == :world
  end
end
