defmodule Intra do
  use GenServer

  @type t :: %__MODULE__{
          students: list(),
          projects: list()
        }
  defstruct students: [], projects: []

  @spec new :: :ignore | {:error, any} | {:ok, pid}
  def new() do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  @spec init(any) :: {:ok, Intra.t()}
  def init(_) do
    {:ok, %Intra{students: [], projects: []}}
  end

  @spec students(pid()) :: list(Student.t())
  def students(pid) do
    GenServer.call(pid, :students)
  end

  @spec projects(pid()) :: list(Project.t())
  def projects(pid) do
    GenServer.call(pid, :projects)
  end

  @impl true
  @spec handle_call(term(), GenServer.from(), Intra.t()) ::
          {:reply, list(Student.t()) | list(Project.t()), Intra.t()}
  def handle_call(:students, _from, state) do
    {:reply, state.students, state}
  end

  @impl true
  def handle_call(:projects, _from, state) do
    {:reply, state.projects, state}
  end
end
