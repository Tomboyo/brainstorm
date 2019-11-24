defmodule Database.Fact do
  alias Database.Id

  @type t :: %__MODULE__{
    id:      Datbase.Id.t,
    content: String.t,
    topics:  [ Database.Id.t ] | [ Database.Topic.t ]
  }

  @enforce_keys [ :id, :topics, :content ]
  defstruct [ :id, :topics, :content ]

  @callback new([ Id.t ], String.t) :: t
  @doc """
  Create a fact for the given topics with the given content and a new Id. Facts
  may relate one or two nodes; three or more is unsupported.

  ## Examples

      iex> topic_id = Database.Id.new("topic-id")
      iex> fact = Database.Fact.new([ topic_id ], "fact content")
      iex> fact.topics == [ topic_id ]
      true
      iex> fact.content == "fact content"
      true
      iex> fact.id |> Database.Id.is_id()
      true
  """
  def new(topics, content) do
    %__MODULE__{
      id: Id.new(),
      topics: topics,
      content: content
    }
  end

  @callback new(
    id      :: String.t,
    content :: String.t,
    topics  :: [ Topic.t ]
  ) :: t
  def new(id, content, topics)
  when is_binary(id) and is_binary(content)
  do
    %__MODULE__{
      id:      Database.Id.new(id),
      content: content,
      topics:  MapSet.new(topics)
    }
  end

  @callback persist(t) :: :ok | { :error, term }
  def persist(fact = %__MODULE__{}) do
    fact.topics
      |> Enum.map(&to_string/1)
      |> case do
        [ id ]       -> persist(fact.id, [ id, id ], fact.content)
        [ id1, id2 ] -> persist(fact.id, [ id1, id2 ], fact.content)
      end
  end

  @persist """
  MATCH (from:topic), (to:topic)
  WHERE from.id = $from AND to.id = $to
  CREATE (from)-[fact:fact { id: $id, content: $content }]->(to)
  """
  defp persist(id, [ from, to ], content) do
    case Database.query(@persist, %{
      "from"    => from,
      "to"      => to,
      "id"      => id |> to_string(),
      "content" => content
    }) do
      { :ok, _ } -> :ok
      { :error, reason } -> { :error, reason }
    end
  end

end
