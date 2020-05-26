defmodule Student do
  use GenServer

  @type t :: %__MODULE__{
          name: String.t(),
          projects: list(),
          event_manager: pid()
        }
  @enforce_keys [:name, :event_manager]
  defstruct [:name, :event_manager, projects: []]

  defmodule Repr do
    @type t :: %__MODULE__{
            pid: pid()
          }
    @enforce_keys [:pid]
    defstruct [:pid]
  end

  defmodule Event do
    use GenServer

    @type t :: %__MODULE__{
            subscribers: list(pid())
          }
    defstruct subscribers: []

    # client side

    def new() do
      GenServer.start_link(__MODULE__, :ok)
    end

    def subscribe(student_repr, pid) do
      {:ok, event_manager} = Student.event_manager(student_repr)
      GenServer.call(event_manager, {:subscribe, pid})
    end

    def dispatch(student, event) do
      GenServer.cast(student.event_manager, event)
    end

    # server side
    @impl true
    @spec init(any) :: {:ok, Student.Event.t()}
    def init(_) do
      {:ok, %Event{}}
    end

    @impl true
    def handle_call({:subscribe, pid}, _from, %Event{subscribers: subscribers}) do
      {:reply, :ok, %Event{subscribers: [pid | subscribers]}}
    end

    @impl true
    def handle_cast(event, state) do
      Enum.each(state.subscribers, fn pid -> send(pid, event) end)
      {:noreply, state}
    end
  end

  # client side
  @spec new(String.t()) :: :ignore | {:error, any} | {:ok, Student.Repr.t()}
  def new(name) do
    case GenServer.start_link(__MODULE__, name) do
      {:ok, pid} -> {:ok, %Student.Repr{pid: pid}}
      error -> error
    end
  end

  @spec name(Student.Repr.t()) :: {:error, :noproc | :not_student} | {:ok, charlist()}
  def name(%Student.Repr{pid: pid}) do
    if Process.alive?(pid) do
      {:ok, GenServer.call(pid, :name)}
    else
      {:error, :noproc}
    end
  end

  def name(_student), do: {:error, :not_student}

  @spec projects(any) :: {:error, :noproc | :not_student} | {:ok, list(Project.t())}
  def projects(%Student.Repr{pid: pid}) do
    if Process.alive?(pid) do
      {:ok, GenServer.call(pid, :projects)}
    else
      {:error, :noproc}
    end
  end

  def projects(_student), do: {:error, :not_student}

  @spec subscribe(Student.Repr.t(), Project.t()) :: {:error, :noproc | :not_student} | {:ok}
  def subscribe(%Student.Repr{pid: pid}, project) do
    if Process.alive?(pid) do
      GenServer.call(pid, {:subscribe, project})
    else
      {:error, :noproc}
    end
  end

  def subscribe(_student, _project), do: {:error, :not_student}

  @spec unsubscribe(Student.Repr.t(), Project.t()) :: {:error, :noproc | :not_subscribed} | {:ok}
  def unsubscribe(%Student.Repr{pid: pid}, project) do
    if Process.alive?(pid) do
      GenServer.call(pid, {:unsubscribe, project})
    else
      {:error, :noproc}
    end
  end

  def unsubscribe(_student, _project), do: {:error, :not_student}

  def event_manager(%Student.Repr{pid: pid}) do
    GenServer.call(pid, :event_manager)
  end

  # server side

  @impl true
  @spec init(String.t()) :: {:ok, %Student{}}
  def init(name) do
    # XXX: handle error
    {:ok, event_manager} = Student.Event.new()
    {:ok, %Student{name: name, event_manager: event_manager, projects: []}}
  end

  @impl true
  def handle_call(:name, _from, student) do
    {:reply, student.name, student}
  end

  @impl true
  def handle_call(:projects, _from, student) do
    {:reply, student.projects, student}
  end

  @impl true
  def handle_call({:subscribe, project}, _from, student) do
    Student.Event.dispatch(student, {:subscribed_to_project, student, project})

    {:reply, :ok,
     %Student{
       student
       | name: student.name,
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
       student
       | name: student.name,
         projects: Enum.filter(student.projects, fn p -> p != project end)
     }}
  end

  @impl true
  def handle_call(:event_manager, _from, student) do
    {:reply, {:ok, student.event_manager}, student}
  end
end
