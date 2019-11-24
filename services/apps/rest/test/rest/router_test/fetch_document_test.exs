defmodule Rest.RouterTest.FetchTopicTest do
  use ExUnit.Case
  use Plug.Test
  import Mox
  alias Rest.Router
  alias Database.{ Id, Fact, Topic }

  @opts Router.init([])

  setup :verify_on_exit!

  defp setup_topic(_context) do
    id = Id.new("topic id")
    topic = %Topic{ id: id, label: "topic label" }
    [ id: id, topic: topic ]
  end

  defp setup_fact(%{ topic: topic }) do
    fact = Fact.new("fact id", "fact content", [ topic ])
    [ fact: fact ]
  end

  defp setup_document(%{ topic: topic, fact: fact }) do
    [ document: Database.Document.new(topic, [ fact ]) ]
  end

  describe "given a request to GET /document/:id for a persistent topic id" do
    setup :setup_topic
    setup :setup_fact
    setup :setup_document

    setup %{ id: id, document: document } do
      Database.DocumentMock
      |> expect(:fetch, fn ^id -> document end)

      conn =
        conn(:get, "/document/#{id}", nil)
        |> Router.call(@opts)

      [ conn: conn ]
    end

    test "it returns the document as json", %{
      conn: conn,
      topic: topic,
      fact: fact
    } do
      { :ok, expected } = Jason.decode("""
        {
          "topic": {
            "id":    "#{topic.id |> to_string()}",
            "label": "#{topic.label}"
          },
          "facts": [{
            "id":      "#{fact.id |> to_string()}",
            "content": "#{fact.content}",
            "topics": [{
              "id":    "#{topic.id |> to_string()}",
              "label": "#{topic.label}"
            }]
          }]
        }
      """)

      assert expected == Jason.decode!(conn.resp_body)
    end

    test "the response has a 200 status code", %{
      conn: conn
    } do
      assert 200 == conn.status
    end

    test "the response sets the content-header to application/json", %{
      conn: conn
    } do
      assert conn.resp_headers
        |> Enum.member?({ "content-type", "application/json" })
    end
  end
end
