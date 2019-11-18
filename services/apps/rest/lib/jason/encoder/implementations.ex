import Jason.Encode

defimpl Jason.Encoder, for: Database.Topic do
  def encode(topic, opts) do
    map(Map.take(topic, [ :id, :label ]), opts)
  end
end

defimpl Jason.Encoder, for: Database.Id do
  def encode(id, opts) do
    string(to_string(id), opts)
  end
end

defimpl Jason.Encoder, for: MapSet do
  def encode(set, opts) do
    set |> Enum.into([]) |> list(opts)
  end
end
