defmodule Rest.Presenter.FactTest do
  use ExUnit.Case
  alias Rest.Presenter.Fact

  describe "POST /" do
    test "json-encodes fact id's" do
      fact = Database.Fact.from(Database.Id.new(), "content", [ "topic" ])

      assert { :ok, Jason.encode!(fact.id) } ==
        Fact.present({ :post, "/" }, fact)
    end

    test "json-encodes unresolved match results" do
      matches = %{ "search term" => Database.Topic.new("similar label") }
      assert { :ok, Jason.encode!(%{ "match" => matches}) } ==
        Fact.present({ :post, "/" }, { :match, matches })
    end
  end
end
