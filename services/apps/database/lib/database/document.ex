defmodule Database.Document do
  @moduledoc """
  A document contains a topic ("document root" and all the facts related to that
  topic. It also contains those topics thereby related to the document root.

  This structure is meant to invoke the concept of a paper document, where the
  document root is the subject matter of the document and its content is the
  accumulation of those facts associated with the document root.
  """

  alias Database.{ Fact, Id, Topic }

  @type t :: %__MODULE__{
    topic: Database.Topic.t,
    facts: MapSet.t(Database.Fact.t)
  }
  @enforce_keys [ :topic, :facts ]
  defstruct [ :topic, :facts ]

  @callback new(
    topic :: Database.Topic.t,
    facts ::
        [ Database.Fact.t ]
      | MapSet.t(Database.Fact.t)
  ) :: t
  def new(topic, facts) do
    %__MODULE__{
      topic: topic,
      facts: MapSet.new(facts)
    }
  end

  @callback fetch(Id.t) ::
  # TODO: { :ok, t } to avoid capturing error structs
    nil
  | __MODULE__.t
  | { :error, any }
  @fetch """
  MATCH (topic :topic { id: $id })
  RETURN
    topic.label,
    [ (topic)-[f:fact]-(t) | [ f.id, f.content, t.id, t.label ]] as facts
  """
  def fetch(%Id{} = id) do
    Database.query(@fetch, %{
      id: to_string(id)
    })
    |> case do
      { :ok, [] }        -> nil
      { :ok, [ record ]} -> to_document(id, record)
      { :error, cause }  -> { :error, cause }
    end
  end

  defp to_document(id, record) do
    topic = %Topic{ id: id, label: record["topic.label"] }

    facts = record["facts"]
      |> Stream.map(fn [ f_id, f_content, t_id, t_label ] ->
          topics = [ topic, Topic.from(Id.from(t_id), t_label) ]
          Fact.from(Id.from(f_id), f_content, topics)
        end)
      |> Enum.into(MapSet.new())

    new(topic, facts)
  end

end
