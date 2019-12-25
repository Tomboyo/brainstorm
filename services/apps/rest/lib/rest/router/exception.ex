defmodule Rest.Router.Exception do
  @type t :: %__MODULE__{}

  defexception [ :reason ]

  @impl true
  def exception(e = { :unhandled_case, _any }) do
    %__MODULE__{ reason: e }
  end

  @impl true
  def message(%__MODULE__{ reason: { :unhandled_case, any }}) do
    "Unhandled case: #{inspect(any)}"
  end

end
