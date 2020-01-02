defmodule Rest.Util.Maybe do
  @type t :: { :ok, term } | { :error, term }

  @doc """
  Create a Maybe from the given value.

  # Examples

      iex> Rest.Util.Maybe.of(:value)
      { :ok, :value }

  """
  def of(value), do: { :ok, value }

  @doc """
  Given a maybe and a maybe-returning function, apply that function to the state
  of the maybe and return the function result under the following conditions:

  * If the resulting maybe is an error tuple, return a new error of the form
    `{ :error, { error_tag, initial_state, error }}`, where `initial_state` is
    the state of the first argument to flat_map and `error` is the unwrapped
    error component of the maybe returned by the function.
  * Otherwise when the resulting maybe is an ok tuple, return it unmodified.

  Note that the maybe result of the given function may take the form of either
  `{ :ok, :error }` or `{ :ok, nil }`, if desired.

  # Examples

      iex> maybe = { :ok, :initial_state }
      iex> Rest.Util.Maybe.flat_map(
      ...>   maybe,
      ...>   fn _ -> { :error, :result } end,
      ...>   :tag)
      { :error, { :tag, :initial_state, :result }}

      iex> maybe = { :ok, :initial_state }
      iex> Rest.Util.Maybe.flat_map(
      ...>   maybe,
      ...>   fn _ -> { :ok, :result } end,
      ...>   :unused_tag)
      { :ok, :result }

      iex> maybe = { :ok, :initial_state }
      iex> Rest.Util.Maybe.flat_map(
      ...>   maybe,
      ...>   fn _ -> { :ok, :error } end,
      ...>   :unused_tag)
      { :ok, :error }

  """
  def flat_map(maybe, function, error_tag)

  def flat_map({ :ok, state }, function, error_tag) do
    case function.(state) do
      { :ok, result }    -> { :ok, result }
      { :error, result } -> error(error_tag, state, result)
    end
  end

  def flat_map(e = { :error, _ }, _function, _error_tag) do
    e
  end

  defp error(error_tag, initial_state, result) do
    { :error, { error_tag, initial_state, result }}
  end

  @doc """
  Given a maybe and a function, apply that function to the state of the maybe
  and return a maybe based on the following conditions:

  * If the maybe is an error tuple, it is returned unchanged.

  * If `function.(state)` is equal to `:error` or `nil`, then an error tuple of
    the form `{ :error, { error_tag, initial_state, result }}` is returned. This
    is consistent with the format of flat_map.

  * Otherwise, an ok tuple is returned with the form
    `{ :ok, function.(state) }`.

  Note that a maybe may take the form of either `{ :ok, :error }` or
  `{ :ok, nil }`, though this function can never produce one. If this is
  desired, use a helper function and flat_map/3.

  # Examples

      iex> maybe = { :error, nil }
      iex> Rest.Util.Maybe.map(maybe, fn _ -> :result end, :tag)
      { :error, nil }

      iex> maybe = { :ok, :initial_state }
      iex> Rest.Util.Maybe.map(maybe, fn _ -> :error end, :tag)
      { :error, { :tag, :initial_state, :error }}

      iex> maybe = { :ok, :initial_state }
      iex> Rest.Util.Maybe.map(maybe, fn _ -> nil end, :tag)
      { :error, { :tag, :initial_state, nil }}

      iex> maybe = { :ok, 1 }
      iex> Rest.Util.Maybe.map(maybe, fn x -> x + 1 end, :tag)
      { :ok, 2 }
  """
  def map(maybe, function, error_tag)

  def map({ :ok, state }, function, error_tag) do
    case function.(state) do
      x when x in [ :error, nil ] -> error(error_tag, state, x)
      result -> { :ok, result }
    end
  end

  def map(e = { :error, _ }, _function, _error_tag), do: e

  @doc """
  Like map/3, this applies a mapping function to the state of the given maybe.
  Unlike map/3, that function is not allowed to return nil or :error, and map!/2
  will raise an exception if this ever happens.
  """
  def map!(maybe, function)

  def map!({ :ok, state }, function) do
    case function.(state) do
      x when x in [ :error, nil ] ->
        raise "Maybe mapping returned :error in map!/2"
      result -> { :ok, result }
    end
  end

  def map!(e = { :error, _ }, _function), do: e

end
