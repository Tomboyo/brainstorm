defmodule Rest.Presenter.FactTest do
  use ExUnit.Case
  alias Rest.Presenter.Fact


  describe "POST /" do
    test "json-encodes the given fact" do
      fact = Database.Fact.from(Database.Id.new(), "content", [ "topic" ])

      assert { :ok, Jason.encode!(fact) } == Fact.present({ :post, "/" }, fact)
    end
  end
end
