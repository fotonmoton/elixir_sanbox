defmodule Student do
  use GenServer

  @type t :: %__MODULE__{
          name: String.t(),
          projects: list()
        }
  @enforce_keys [:name]
  defstruct [:name, projects: []]

  @spec new(String.t()) :: :ignore | {:error, any} | {:ok, pid}
  def new(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def name(student) when is_pid(student) do
    try do
      {:ok, GenServer.call(student, :name)}
    catch
      :exit, {:noproc, _} -> {:error, :noproc}
      :exit, {:normal, _} -> {:error, :normal}
    end
  end

  def name(_student) do
    {:error, :not_student}
  end

  def projects(student) when is_pid(student) do
    try do
      {:ok, GenServer.call(student, :projects)}
    catch
      :exit, {:noproc, _} -> {:error, :noproc}
      :exit, {:normal, _} -> {:error, :normal}
    end
  end

  def projects(_student) do
    {:error, :not_student}
  end

  def subscribe(student, project) when is_pid(student) do
    try do
      GenServer.call(student, {:subscribe, project})
    catch
      :exit, {:noproc, _} -> {:error, :noproc}
      :exit, {:normal, _} -> {:error, :normal}
    end
  end

  def unsubscribe(student, project) when is_pid(student) do
    try do
      GenServer.call(student, {:unsubscribe, project})
    catch
      :exit, {:noproc, _} -> {:error, :noproc}
      :exit, {:normal, _} -> {:error, :normal}
    end
  end

  @impl true
  @spec init(String.t()) :: {:ok, %Student{}}
  def init(name) do
    {:ok, %Student{name: name, projects: []}}
  end

  @impl true
  @spec handle_call(:name, any(), %Student{}) :: {:reply, String.t(), %Student{}}
  def handle_call(:name, _from, student) do
    {:reply, student.name, student}
  end

  @impl true
  def handle_call(:projects, _from, student) do
    {:reply, student.projects, student}
  end

  @impl true
  def handle_call({:subscribe, project}, _from, student) do
    {:reply, :ok,
      %Student{
        name: student.name,
        projects: [project | student.projects]
      }
    }
  end

  @impl true
  def handle_call({:unsubscribe, project}, _from, student) do
    response = if Enum.member?(student.projects, project) do
                :ok
               else
                {:error, :not_subscribed}
               end
    {:reply, response,
      %Student{
        name: student.name,
        projects: Enum.filter(student.projects, fn p -> p != project end)
      }
    }
  end
end
