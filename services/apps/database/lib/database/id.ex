defmodule Database.Id do

  @enforce_keys [ :value ]
  defstruct [ :value ]

  def new(), do: %__MODULE__{ value: "TODO! Not exercised by tests yet." }
  def new(id), do: %__MODULE__{ value: id }

  defimpl String.Chars do
    def to_string(id), do: id.value
  end
end
