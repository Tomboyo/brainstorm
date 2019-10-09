defmodule Database do

  defdelegate start_link(opts \\ []), to: Bolt.Sips

  def query(query, parameters \\ %{}) do
    Bolt.Sips.query(
      Bolt.Sips.conn(),
      query,
      parameters)
  end

end
