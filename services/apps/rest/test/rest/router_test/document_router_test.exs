defmodule Rest.DocumentRouterTest do
  use ExUnit.Case
  use Plug.Test
  import Mox
  alias Rest.Router
  alias Database.{ Document, Fact, Topic }

  @opts Router.init([])

  describe "When :id is a persistent topic id, GET /document/:id" do
    setup do
      topic = Topic.new("topic-id", "topic label")
      fact = Fact.new("fact-id", "fact content", [ topic ])
      document = Document.new(topic, [ fact ])

      topic_id = topic.id
      Database.DocumentMock
      |> expect(:fetch, fn ^topic_id -> document end)

      conn =
        conn(:get, "/document/#{topic_id}", nil)
        |> Router.call(@opts)

      [ conn: conn, document: document ]
    end

    test "generates a document from the given persistent topic id" do
      Mox.verify!()
    end

    test "returns the json-encoded document", %{
      conn: conn,
      document: document
    } do
      { :ok, expected } = Jason.encode(document)
      assert expected == conn.resp_body
    end

    test "responds with a 200 status code", %{
      conn: conn
    } do
      assert 200 == conn.status
    end

    test "responds with an application/json content-type", %{
      conn: conn
    } do
      assert conn.resp_headers
        |> Enum.member?({ "content-type", "application/json" })
    end
  end
end
