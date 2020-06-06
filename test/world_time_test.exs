defmodule WorldTimeTest do
  use ExUnit.Case

  test "starts the WorldTime agent without issues" do
    {:ok, _} = WorldTime.start(1)
  end

  test "WorldTime.now/0 does not throw" do
    {:ok, _} = WorldTime.start(1)
    _time = WorldTime.now()
  end

  test "WorldTime agent rejects negative multipliers" do
    {:error, :badarg} = WorldTime.start(0)
    {:error, :badarg} = WorldTime.start(-1)
  end
  
  test "WorldTime agent correctly applies multiplier" do
    Enum.map(1..5, fn multiplier ->
        {:ok, _} = WorldTime.start(multiplier)
        Process.sleep(1000)
        assert NaiveDateTime.add(WorldTime.epoch, multiplier) == WorldTime.now
        WorldTime.stop
      end)
  end
end
