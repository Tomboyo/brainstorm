defmodule Rest.Presenter.DocumentTest do
  use ExUnit.Case
  alias Rest.Presenter.Document

  describe "GET /:id" do
    test "json-encodes the document" do
      document = Database.Document.new(
        Database.Topic.new("label"),
        [ Database.Fact.new("content", [ Database.Id.new() ])])

      assert { :ok, Jason.encode!(document) } ==
        Document.present({ :get, "/:id" }, document)
    end
  end

  describe "GET /:id (when given a missing-document error)" do
    test "json-encodes an error message" do
      assert {
        :ok,
        "Could not generate document: No topic with id `id` exists."
      } == Document.present(
        { :get, "/:id" },
        { :document_error, "id", :enoent }
      )
    end
  end
end
