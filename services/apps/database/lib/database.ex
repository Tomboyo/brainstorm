defmodule Database do

  defdelegate start_link(opts \\ []), to: Bolt.Sips

  @spec query(String.t, %{}) ::
      { :ok, term }
    | { :error, term }
  def query(query, parameters \\ %{}) do
    Bolt.Sips.query(
      Bolt.Sips.conn(),
      query,
      parameters)
  end

  def query!(query, parameters \\ %{}) do
    Bolt.Sips.query!(
      Bolt.Sips.conn(),
      query,
      parameters)
  end

end
