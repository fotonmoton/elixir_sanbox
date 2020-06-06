defmodule WorldTime do
  use Agent

  @unit_epoch ~N[2016-11-16 08:42:00]

  @type t :: %__MODULE__{
          multiplier: number(),
          start: NaiveDateTime.t()
        }
  @enforce_keys [:multiplier, :start]
  defstruct [:multiplier, :start]

  # TODO: Upper limit should be defined as well.
  def start(multiplier) when multiplier <= 0, do: {:error, :badarg}

  def start(multiplier) do
    start = NaiveDateTime.utc_now
    Agent.start_link(fn ->
      %WorldTime{multiplier: multiplier, start: start}
    end, name: __MODULE__)
  end

  def stop do
    Agent.stop(__MODULE__)
  end

  def now() do
    now = NaiveDateTime.utc_now
    Agent.get(__MODULE__, fn %WorldTime{multiplier: m, start: s} ->
      NaiveDateTime.add(@unit_epoch, NaiveDateTime.diff(now, s) * m)
    end)
  end

  def epoch, do: @unit_epoch
end
