defmodule Database.Case do
  @moduledoc """
  Support for data-driven test cases.
  """

  @truncate """
  MATCH (a)
  DETACH DELETE a
  """

  @doc """
  Deletes all data from the database before each test.
  """
  defmacro __using__(_options) do
    quote do
      setup do
        { :ok, _ } = Database.query(unquote(@truncate))
      end
    end
  end
end
