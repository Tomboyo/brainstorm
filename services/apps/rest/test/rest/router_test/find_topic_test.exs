defmodule Rest.RouterTest.FindTopicTest do
  use ExUnit.Case
  use Plug.Test
  import Mox
  alias Rest.Router
  alias Database.{ Id, Topic }

  @opts Router.init([])

  setup :verify_on_exit!

  describe "Given a search query to GET /topic" do
    setup do
      topics = MapSet.new([ %Topic{ id: Id.new("topic id"), label: "label" } ])
      Database.TopicMock |> expect(:find, fn "search term" -> topics end)

      conn =
        conn(:get, "topic?search=search%20term", nil)
        |> Router.call(@opts)

      [ conn: conn, topics: topics ]
    end

    test "it returns a 200", %{ conn: conn } do
      assert 200 == conn.status
    end

    test "it returns a json list of matching topics", %{
      conn: conn,
      topics: topics
    } do
      { :ok, json } = Jason.encode(topics)
      assert json == conn.resp_body
    end
  end
end
