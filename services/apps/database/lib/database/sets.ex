defmodule Database.Sets do
  @moduledoc """
  Some helper functions for working with MapSet. This should be extracted.
  """

  @empty_set MapSet.new()
  @doc """
  An empty MapSet which can be used in pattern matches.

  # Examples

      iex> match?(Database.Sets.empty_set(), MapSet.new())
      true

  """
  defmacro empty_set do
    quote do
      unquote(Macro.escape(@empty_set))
    end
  end

  def is_singleton(mapset) do
    MapSet.size(mapset) == 1
  end

  @spec get_any(MapSet.t(any)) :: any
  def get_any(mapset) do
    MapSet.to_list(mapset)
    |> List.first()
  end

end
