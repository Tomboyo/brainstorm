defmodule Database.Fact do

  @type t :: __MODULE__
  @enforce_keys [ :id, :topics, :content ]
  defstruct [ :id, :topics, :content ]

  @callback new([ Id.t ], String.t) :: { :ok, t }
  def new(_topics, _content), do: { :error, "not yet implemented" }

  @callback persist(t) :: :ok | { :error, any }
  def persist(%__MODULE__{}), do: { :error, "not yet implemented" }
end
