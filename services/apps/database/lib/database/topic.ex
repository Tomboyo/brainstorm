defmodule Database.Topic do
  alias Database.{ Id, Lucene }

  @type t :: %__MODULE__{
    id:    Database.Id.t,
    label: String.t
  }

  @enforce_keys [:id, :label]
  defstruct [ :id, :label ]

  @callback new(String.t) :: __MODULE__.t
  @doc """
  Create a new topic with the given label and a new id.

  ## Examples

      iex> topic = Database.Topic.new("my label!")
      iex> topic.label
      "my label!"
      iex> topic.id |> Database.Id.is_id()
      true
  """
  def new(label), do: %__MODULE__{
    id:    Id.new(),
    label: label
  }

  @callback new(
    id    :: String.t,
    label :: String.t
  ) :: t
  def new(id, label)
  when is_binary(id) and is_binary(label)
  do
    %__MODULE__{ id: Database.Id.new(id), label: label }
  end

  @callback persist(__MODULE__.t) :: :ok | { :error, any }
  @persist """
  CREATE (:topic { id: $id, label: $label })
  """
  def persist(%__MODULE__{} = topic) do
    Database.query(@persist, %{
      id:    to_string(topic.id),
      label: topic.label
    })
    |> case do
      { :ok, _response } -> :ok
      { :error, cause }  -> { :error, cause }
    end
  end

  @callback find(String.t) :: MapSet.t(__MODULE__.t)
  @find """
  CALL db.index.fulltext.queryNodes(
    "topic_label",
    $search_term)
  YIELD node
  RETURN node.id as id, node.label as label
  """
  def find(search_term) when is_binary(search_term) do
    Database.query(@find, %{ "search_term" => Lucene.escape(search_term) })
    |> case do
      { :ok, topics } ->
        for %{ "id" => id, "label" => label } <- topics,
          into: MapSet.new(),
          do: %__MODULE__{ id: Id.new(id), label: label }
      { :error, cause } -> { :error, cause }
    end
  end

  @callback delete(Id.t) :: :ok | :enoent | { :error, any }
  @delete """
  MATCH (n:topic { id: $id })
  DETACH DELETE (n)
  """
  def delete(%Id{} = id) do
    Database.query(@delete, %{ "id" => to_string(id) })
    |> case do
      { :ok, %{ stats: %{ "nodes-deleted" => 1 }}} -> :ok
      { :ok, %{ stats: nil }} -> :enoent
      { :error, cause } -> { :error, cause }
    end
  end

end
