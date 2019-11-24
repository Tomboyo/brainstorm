defmodule Database.Topic do
  alias Database.{ Fact, Id }

  @type t :: __MODULE__

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


  # TODO: this is concerned with topics AND facts, now. Move?
  @callback fetch(Id.t) ::
    nil
  | (document :: %{ topic: t, facts: MapSet.t(Database.Fact.t) })
  | { :error, any }
  @fetch """
  MATCH (topic :topic { id: $id })
  RETURN
    topic.label,
    [ (topic)-[f:fact]->(t) | [ f.id, f.content, t.id, t.label ]] as facts
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
    topic = %__MODULE__{ id: id, label: record["topic.label"] }
    facts = record["facts"]
      |> Stream.map(fn [ f_id, f_content, t_id, t_label ] ->
          topics = [ topic, new(t_id, t_label) ]
          Fact.new(f_id, f_content, topics)
        end)
      |> Enum.into(MapSet.new())

    %{ topic: topic, facts: facts }
  end

end
