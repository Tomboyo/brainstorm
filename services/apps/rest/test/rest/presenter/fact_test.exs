defmodule Rest.Presenter.FactTest do
  use ExUnit.Case
  alias Rest.Presenter.Fact


  describe "POST / (when given a fact)" do
    test "json-encodes the given fact" do
      fact = Database.Fact.from(Database.Id.new(), "content", [ "topic" ])

      assert { :ok, Jason.encode!(fact) } == Fact.present({ :post, "/" }, fact)
    end
  end

  describe "POST / (when given partial topic matches)" do
    test "json-encodes the partially-matched topics" do
      matches = %{ "search term" => Database.Topic.new("similar label") }
      assert { :ok, Jason.encode!(matches) } ==
        Fact.present({ :post, "/" }, matches)
    end
  end
end
