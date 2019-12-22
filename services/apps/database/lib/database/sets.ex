defmodule Database.Sets do
  @moduledoc """
  Some helper functions for working with MapSet. This should be extracted.
  """

  def is_singleton(mapset) do
    MapSet.size(mapset) == 1
  end

  @spec get_any(MapSet.t(any)) :: any
  def get_any(mapset) do
    MapSet.to_list(mapset)
    |> List.first()
  end

end
