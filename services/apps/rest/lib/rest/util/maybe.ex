defmodule Rest.Util.Maybe do
  @opaque t :: %__MODULE__{}
  defstruct [ :functions ]

  @doc """
  Begin a maybe pipeline with the given supplier function. This function will
  produce the initial state of the Maybe when produce/0 is invoked.
  """
  def of(supplier) do
    %__MODULE__{ functions: [ supplier ]}
  end

  @doc """
  Defaults the expected_tag argument of map/4 to :ok. Equivalent to
  `map(maybe, :ok, function, error_tag)`.
  """
  def map(maybe, function, error_tag) do
    map(maybe, :ok, function, error_tag)
  end

  @doc """
  Register a mapping function which will consume the current state of the Maybe
  and return the new state of the Maybe. All mappings are executed in the order
  given.

  If the mapping returns a value of the form `{ ^expected_tag, v }`, then the
  state of the Maybe becomes `v`. Otherwise, the state becomes an error tuple
  `{ ^error_tag, state, error }`, where `state` is the state of the Maybe given
  to the failed mapping and `error` is the resolved value of the failed mapping.

  Mappings are applied only when `produce/0` is invoked.
  """
  def map(maybe, expected_tag, function, error_tag) do
    lifted_function = lift_function(expected_tag, function, error_tag)
    %__MODULE__{ functions: [ lifted_function ] ++ maybe.functions }
  end

  defp lift_function(expected_tag, function, error_tag) do
    fn state ->
      case tuple = function.(state) do
        { ^expected_tag, value } -> { :ok, value }
        _ -> { :error, { error_tag, state, tuple }}
      end
    end
  end

  @doc """
  Like map/4, register a mapping function which will consume the current state
  of the Maybe and return the new state of the Maybe. Unlike map/4, the function
  is assumed to never return an error, so the value is taken verbatim as the new
  state of the Maybe.

  As in map/4, the registered function is executed in the order given once
  produce/4 is invoked.
  """
  def replace(maybe, function) do
    lifted_function = fn state -> { :ok, function.(state) } end

    %__MODULE__{ functions: [ lifted_function ] ++ maybe.functions }
  end

  @doc """
  Apply all registered functions in the order registered. In particular:
  1. The supplier registered via `of` is applied to obtain the initial Maybe
     state.
  2. Each mapping registered via `map` or `replace` is applied to the state in
     turn, replacing the state. If any mapping fails, evaluation terminates
     immediately (no other mappings are evaluated).
  3. The final state is returned. If all mappings resolved normally, the result
     is an `{ :ok, value }` tuple. If any mapping failed, then the result is the
     error evaluation of the first such mapping.
  """
  def produce(maybe) do
    [ initial_value | mappings ] = Enum.reverse(maybe.functions)
    produce(initial_value.(), hd(mappings), tl(mappings))
  end

  defp produce(state, function, [] = _functions) do
    # this is in the form { :ok, v }
    function.(state)
  end

  defp produce(state, function, functions) do
    case function.(state) do
      { :ok, value } -> produce(value, hd(functions), tl(functions))
      { :error, error_tag } -> { :error, error_tag }
    end
  end
end
