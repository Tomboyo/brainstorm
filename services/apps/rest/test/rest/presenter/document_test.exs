defmodule Rest.Presenter.DocumentTest do
  use ExUnit.Case
  alias Rest.Presenter.Document

  test "presents documents" do
    document = Database.Document.new(
      Database.Topic.new("label"),
      [ Database.Fact.new("content", [ Database.Id.new() ])])

    assert { :ok, Jason.encode!(%{ "document" => document }) } ==
      Document.present({ :get, "/:id" }, document)
  end

  test "presents missing document errors" do
    assert { :ok, Jason.encode!(
      "Could not generate document: No topic with id `id` exists.")
    } == Document.present(
      { :get, "/:id" },
      { :document_error, "id", :enoent }
    )
  end

  test "presents matched search terms" do
    matches = %{ "term" => MapSet.new() }
    assert { :ok, Jason.encode!(%{ "match" => matches }) } ==
      Document.present({ :get, "/:id" }, { :matched_search_terms, matches })
  end
end
