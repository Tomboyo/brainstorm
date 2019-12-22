defmodule Rest.Presenter.DocumentTest do
  use ExUnit.Case
  alias Rest.Presenter.Document

  describe "GET /:id (when given a document)" do
    test "json-encodes the document" do
      document = Database.Document.new(
        Database.Topic.new("label"),
        [ Database.Fact.new("content", [ Database.Id.new() ])])

      assert { :ok, Jason.encode!(document) } ==
        Document.present({ :get, "/:id" }, document)
    end
  end
end
