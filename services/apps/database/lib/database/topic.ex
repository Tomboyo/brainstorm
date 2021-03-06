defmodule Database.Topic do
  alias Database.{ Id, Lucene, Sets }

  @opaque t :: persistent | transient
  @opaque persistent :: %__MODULE__{
    id:    Database.Id.t,
    label: String.t
  }
  @opaque transient :: persistent

  @enforce_keys [:id, :label]
  defstruct [ :id, :label ]

  @callback new(String.t) :: transient
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

  @callback from(
    id    :: Database.Id.t,
    label :: String.t
  ) :: persistent
  def from(id = %Id{}, label) when is_binary(label) do
    %__MODULE__{ id: id , label: label }
  end

  @callback persist(__MODULE__.t) :: :ok
  @persist """
  CREATE (:topic { id: $id, label: $label })
  """
  def persist(%__MODULE__{} = topic) do
    Database.query!(@persist, %{
      id:    to_string(topic.id),
      label: topic.label
    })
    :ok
  end

  @callback find(String.t) :: MapSet.t(persistent)
  @find """
  CALL db.index.fulltext.queryNodes(
    "topic_label",
    $search_term)
  YIELD node
  RETURN node.id as id, node.label as label
  """
  def find(search_term) when is_binary(search_term) do
    topics = Database.query!(@find, %{
      "search_term" => Lucene.escape(search_term)
    })

    for %{ "id" => id, "label" => label } <- topics,
      into: MapSet.new(),
      do: %__MODULE__{ id: Id.from(id) , label: label }
  end

  @callback resolve_ids(String.t) :: %{
    id: MapSet.t(Database.Id.t),
    match: %{ String.t => MapSet.t(t) }
  }
  def resolve_ids(terms) do
    resolutions = Enum.map(terms, &resolve_id/1)

    ids = resolutions
      |> Stream.filter(&match?({ :id, _ }, &1))
      |> Enum.into(MapSet.new(), &elem(&1, 1))

    matches = resolutions
      |> Stream.filter(&match?({ :match, _ }, &1))
      |> Stream.map(&elem(&1, 1))
      |> Enum.reduce(%{}, &Map.merge/2)

    %{ id: ids, match: matches }
  end

  @callback resolve_id(String.t) ::
      { :id, Database.Id.t }
    | { :match, %{ String.t => MapSet.t(t) }}
  def resolve_id(term) do
    if Id.is_id(term) do
      case term do
        %Id{} = term -> { :id, term }
        _ -> { :id, Id.from(term) }
      end
    else
      terms = find(term)
      if Sets.is_singleton(terms),
        do:   { :id, Sets.get_any(terms).id },
        else: { :match, %{ term => terms }}
    end
  end

  @callback delete(Id.t) :: :ok | :enoent
  @delete """
  MATCH (n:topic { id: $id })
  DETACH DELETE (n)
  """
  def delete(%Id{} = id) do
    Database.query!(@delete, %{ "id" => to_string(id) })
    |> case do
      %{ stats: %{ "nodes-deleted" => 1 }} -> :ok
      %{ stats: nil } -> :enoent
    end
  end

end
