defmodule IntraTest do
  use ExUnit.Case

  test "Intra creates without an error" do
    {:ok, pid} = Intra.new()
  end
end
