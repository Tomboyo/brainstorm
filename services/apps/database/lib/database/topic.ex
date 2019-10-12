defmodule Database.Topic do

  alias Database.Id

  @type t :: __MODULE__

  @enforce_keys [:id, :label]
  defstruct [ :id, :label ]

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


  @fetch """
  MATCH (topic :topic { id: $id })
  RETURN topic
  """
  def fetch(%Id{} = id) do
    Database.query(@fetch, %{
      id: to_string(id)
    })
    |> case do
      { :ok, [] }       -> nil
      { :ok, [ one ]}   -> one["topic"].properties |> to_topic()
      { :error, cause } -> { :error, cause }
    end
  end

  defp to_topic(%{ "id" => id, "label" => label }) do
    %__MODULE__{
      id:    Id.new(id),
      label: label
    }
  end

end
