defmodule ElixirSanboxTest do
  use ExUnit.Case
  doctest ElixirSanbox

  test "greets the world" do
    assert ElixirSanbox.hello() == :world
  end
end
