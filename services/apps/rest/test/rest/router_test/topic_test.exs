defmodule Rest.RouterTest.TopicTest do
  use ExUnit.Case
  use Plug.Test

  import Mox

  alias Rest.Router
  alias Database.{ Id, Topic }

  @opts Router.init([])

  setup :verify_on_exit!

  describe "Given an existing topic id to DELETE /topic/:id" do
    setup do
      expected_id = Id.new("topic-id")
      Database.TopicMock
      |> expect(:delete, fn ^expected_id -> :ok end)

      conn =
        conn(:delete, "/topic/topic-id", nil)
        |> Router.call(@opts)

      [ conn: conn ]
    end

    test "returns 204", %{ conn: conn } do
      assert 204 == conn.status
    end
  end

  describe "Given a nonexistant topic id to DELETE /topic/:id" do
    setup do
      expected_id = Id.new("topic-id")
      Database.TopicMock
      |> expect(:delete, fn ^expected_id -> :enoent end)

      conn =
        conn(:delete, "/topic/topic-id", nil)
        |> Router.call(@opts)

      [ conn: conn ]
    end

    test "returns 404", %{ conn: conn } do
      assert 404 == conn.status
    end
  end

  describe "Given a JSON request containing a topic label to POST /topic" do
    setup do
      label = "my label"

      topic = %Topic{ id: Id.new("mock topic id"), label: label }
      Database.TopicMock
      |> expect(:new, fn ^label -> topic end)
      |> expect(:persist, fn ^topic -> :ok end)

      conn =
        conn(:post, "/topic", "{ \"label\": \"#{label}\" }")
        |> put_req_header("content-type", "application/json")
        |> Router.call(@opts)

      [ conn: conn, topic: topic ]
    end

    test "returns the new topic id as a string", %{
      conn: conn,
      topic: topic
    } do
      assert topic.id |> to_string() == conn.resp_body
    end

    test "responds with a 201", %{
      conn: conn
    } do
      assert 201 == conn.status
    end
  end
end
