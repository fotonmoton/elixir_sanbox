defmodule Intra do
  use GenServer

  @type t :: %__MODULE__{
          students: list(),
          projects: list()
        }
  defstruct students: [], projects: []

  def new() do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  @spec init(any) :: {:ok, Intra.t()}
  def init(_) do
    {:ok, %Intra{students: [], projects: []}}
  end
end
