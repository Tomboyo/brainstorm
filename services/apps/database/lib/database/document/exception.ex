defmodule Database.Document.Exception do

  @type t :: %__MODULE__{}

  defexception [ :reason ]

  @impl true
  def exception({ :not_found, id }) do
    %__MODULE__{ reason: { :not_found, id }}
  end

  @impl true
  def message(%__MODULE__{ reason: { :not_found, id }}) do
    "Could not generate a document because no topic with the id `#{id}` exists."
  end
end
