defimpl Jason.Encoder, for: Database.Topic do
  import Jason.Encode

  def encode(topic, opts) do
    map(Map.take(topic, [ :label ]), opts)
  end
end
