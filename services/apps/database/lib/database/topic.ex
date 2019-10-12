defmodule Database.Topic do

  alias Database.Id

  @enforce_keys [:id, :label]
  defstruct [ :id, :label ]

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
      { :error, error }  -> { :error, error }
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
      { :error, error } -> { :error, error }
    end
  end

  defp to_topic(%{ "id" => id, "label" => label }) do
    %__MODULE__{
      id:    Id.new(id),
      label: label
    }
  end

end
