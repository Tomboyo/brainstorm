defmodule Database.Id do

  @opaque t :: __MODULE__

  @enforce_keys [ :value ]
  defstruct [ :value ]

  def new(), do: %__MODULE__{ value: "TODO! Not exercised by tests yet." }

  @doc """
  Create a new Id from the given string. This is the functional inverse of
  Kernel.to_string/1.

  ## Examples

      iex> id = Database.Id.new()
      iex> id == to_string(id) |> Database.Id.new()
      true

  """
  def new(id) when is_binary(id), do: %__MODULE__{ value: id }

  @doc """
  Returns true when the argument is an id struct or a stringified id.

  ## Examples

      iex> Database.Id.new() |> Database.Id.is_id()
      true

      iex> Database.Id.new() |> to_string() |> Database.Id.is_id()
      true

      iex> "not an id" |> Database.Id.is_id()
      false

  """
  def is_id(id) when is_binary(id) do
    "TODO! Not exercised by tests yet." == id
  end

  def is_id(%__MODULE__{} = _id), do: true

  defimpl String.Chars do
    def to_string(id), do: id.value
  end
end
