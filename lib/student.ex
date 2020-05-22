defmodule Student do
  use GenServer

  def new(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def name(student) when is_pid(student) do
    try do
      {:ok, GenServer.call(student, :name)}
    catch
      :exit, {:noproc, _} -> {:error, :noproc}
    end
  end

  def name(student) do
    {:error, :notpid}
  end

  @impl true
  def init(name) do
    { :ok, %{ name: name, projects: [] } }
  end

  @impl true
  def handle_call(:name, _from, state) do
    {:reply, state[:name], state}
  end
end
