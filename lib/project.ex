defmodule Project do
  @type t :: %__MODULE__{
          name: String.t()
        }
  @enforce_keys [:name]
  defstruct [:name]

  @spec new(String.t()) :: %Project{}
  def new(name) do
    %Project{name: name}
  end
end
