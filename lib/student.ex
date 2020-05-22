defmodule Student do
  use GenServer

  def new(name) do
    GenServer.start_link(__MODULE__, name)
  end

  @impl true
  def init(name) do
    { :ok, %{ name: name, projects: [] } }
  end
end
