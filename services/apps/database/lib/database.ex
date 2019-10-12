defmodule Database do

  defdelegate start_link(opts \\ []), to: Bolt.Sips

  @spec query(binary, map) ::
    {:ok, response :: [ %{} ]}
  | { :error, cause :: term }
  def query(query, parameters \\ %{}) do
    Bolt.Sips.query(
      Bolt.Sips.conn(),
      query,
      parameters)
  end

end
