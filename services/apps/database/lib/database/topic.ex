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
    [ (topic)-[f:fact]->(o) | [ f.id, f.content, o.id, o.label ]] as facts
  """
  def fetch(%Id{} = id) do
    Database.query(@fetch, %{
      id: to_string(id)
    })
    |> case do
      { :ok, [] }        -> nil
      { :ok, [ record ]} ->
        topic = %__MODULE__{ id: id, label: record["topic.label"] }
        facts = record["facts"]
          |> Stream.map(fn [ f_id, f_content, o_id, o_label ] ->
              other_topic = %__MODULE__{ id: Database.Id.new(o_id), label: o_label }
              %Fact{
                id: Database.Id.new(f_id),
                content: f_content,
                topics: MapSet.new([topic, other_topic])
              }
            end)
          |> Enum.into(MapSet.new())
        %{ topic: topic, facts: facts }
      { :error, cause }  -> { :error, cause }
    end
  end

end
