defmodule Student do
  use GenServer

  @spec new(String.t()) :: :ignore | {:error, any} | {:ok, pid}
  def new(name) do
    GenServer.start_link(__MODULE__, name)
  end

  @impl true
  @spec init(String.t()) :: {:ok, %{name: String.t(), projects: []}}
  def init(name) do
    {:ok, %{name: name, projects: []}}
  end
end
