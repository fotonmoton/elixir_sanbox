defmodule Student do
  use GenServer

  @type t :: %__MODULE__{
          name: String.t(),
          projects: list()
        }
  @enforce_keys [:name]
  defstruct [:name, projects: []]

  defmodule Repr do
    @type t :: %__MODULE__{
            pid: pid()
          }
    @enforce_keys [:pid]
    defstruct [:pid]
  end

  @spec new(String.t()) :: :ignore | {:error, any} | {:ok, Student.Repr.t()}
  def new(name) do
    case GenServer.start_link(__MODULE__, name) do
      {:ok, pid} -> {:ok, %Student.Repr{pid: pid}}
      error -> error
    end
  end

  def name(%Student.Repr{pid: pid}) do
    if Process.alive?(pid) do
      {:ok, GenServer.call(pid, :name)}
    else
      {:error, :noproc}
    end
  end

  def name(_student), do: {:error, :not_student}

  def projects(%Student.Repr{pid: pid}) do
    if Process.alive?(pid) do
      {:ok, GenServer.call(pid, :projects)}
    else
      {:error, :noproc}
    end
  end

  def projects(_student), do: {:error, :not_student}

  def subscribe(%Student.Repr{pid: pid}, project) do
    if Process.alive?(pid) do
      GenServer.call(pid, {:subscribe, project})
    else
      {:error, :noproc}
    end
  end

  def subscribe(_student, _project), do: {:error, :not_student}

  def unsubscribe(%Student.Repr{pid: pid}, project) do
    if Process.alive?(pid) do
      GenServer.call(pid, {:unsubscribe, project})
    else
      {:error, :noproc}
    end
  end

  def unsubscribe(_student, _project), do: {:error, :not_student}

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
     }}
  end

  @impl true
  def handle_call({:unsubscribe, project}, _from, student) do
    response =
      if Enum.member?(student.projects, project) do
        :ok
      else
        {:error, :not_subscribed}
      end

    {:reply, response,
     %Student{
       name: student.name,
       projects: Enum.filter(student.projects, fn p -> p != project end)
     }}
  end
end
