defmodule Database.Id do

  @opaque t :: persistent | transient
  @opaque persistent :: %__MODULE__{}
  @opaque transient  :: %__MODULE__{}

  @enforce_keys [ :value ]
  defstruct [ :value ]

  @doc """
  Create a new and globally unique Id. This relies on the global uniqueness of
  UUIDs.

  ## Examples

      iex> Database.Id.new() == Database.Id.new()
      false

  """
  @spec new() :: transient
  def new() do
    %__MODULE__{
      value: UUID.uuid4()
    }
  end

  @doc """
  Create a new Id from the given string. This is the functional inverse of
  Kernel.to_string/1.

  ## Examples

      iex> id = Database.Id.new()
      iex> id == to_string(id) |> Database.Id.from()
      true

  """
  @spec from(String.t) :: persistent
  def from(id) when is_binary(id), do: %__MODULE__{ value: id }

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
    match?(
      <<_::bytes-size(8), "-",
        _::bytes-size(4), "-",
        _::bytes-size(4), "-",
        _::bytes-size(4), "-",
        _::bytes-size(12)>>,
      id)
  end
  def is_id(%__MODULE__{} = _id), do: true

  defimpl String.Chars do
    def to_string(id), do: id.value
  end
end
